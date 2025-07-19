const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const geofire = require("geofire-common");
const inside = require("point-in-polygon");
const { v4: uuidv4 } = require("uuid");
const fetch = require("node-fetch"); // Make sure node-fetch v2 is installed: npm install node-fetch@2
const booleanPointInPolygon = require('@turf/boolean-point-in-polygon').default;
const { point, polygon: turfPolygon } = require('@turf/helpers');

// Firestore trigger (v2)
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

// Messaging API (v1) - Note: This is v1 messaging, okay if needed, but v2 has alternatives
const { getMessaging } = require("firebase-admin/messaging");

// Ensure admin SDK is initialized only once
if (!admin.apps.length) {
    admin.initializeApp();
}
const db = admin.firestore();

// 🚖 1) Firestore Trigger — Notify drivers on new ride (Already correct v2 syntax)
exports.onRideCreated = onDocumentCreated(
    { // Options object first
        document: "orders/{orderId}",
        region: "us-central1",
    },
    async (event) => { // Handler function second
        // --- Start of your existing onRideCreated logic ---
        const newRide = event.data?.data();
        if (!newRide) {
            console.log("🚨 No ride data found.");
            return;
        }

        const orderId = event.params.orderId;
        const { zoneId, serviceId } = newRide;

        console.log("🛫 New ride data:", newRide);
        console.log("🔍 zoneId:", zoneId, typeof zoneId);
        console.log("🔍 serviceId:", serviceId, typeof serviceId);





        if (!zoneId || !serviceId) {
            console.log("⚠️ Missing zoneId or serviceId, skipping notification.");
            return;
        }

        const driversSnap = await db
            .collection("driver_users")
            .where("zoneIds", "array-contains", zoneId)
            .where("serviceId", "==", serviceId)
            .get();
      console.log("👀 Drivers matching zone and service:", driversSnap.size);
        if (driversSnap.empty) {
            console.log("❌ No drivers found for zone:", zoneId);
            return;
        }

        const tokens = [];
        const drivers = [];

        driversSnap.forEach((doc) => {
            const d = doc.data();
            if (d.fcmToken) {
                tokens.push(d.fcmToken);
                drivers.push({ id: doc.id, token: d.fcmToken });
            }
        });

        if (tokens.length === 0) {
            console.log("⚠️ Drivers found, but none have FCM tokens.");
            return;
        }

        const msg = {
            notification: {
                title: "🚖 New Ride Available",
                body: `Order ${orderId}: a customer needs a ride.`,
            },
            data: {
                orderId,
                type: "new_ride",
            },
            android: { priority: "high" },
            apns: { payload: { aps: { contentAvailable: true } } },
            tokens,
        };

        const resp = await getMessaging().sendEachForMulticast(msg);
        console.log(`📢 Notifications: ${resp.successCount}/${tokens.length} succeeded`);

        resp.responses.forEach(async (r, i) => {
            // Using includes for potentially more robust error checking
            if (!r.success && (r.error.message.includes("not found") || r.error.code === 'messaging/registration-token-not-registered')) {
                const badDriver = drivers[i];
                console.warn("Removing invalid token for driver", badDriver.id);
                try {
                    await db.collection("driver_users").doc(badDriver.id).update({ fcmToken: "" });
                } catch (updateError) {
                     console.error("Error removing token for driver", badDriver.id, updateError);
                }
            } else if (!r.success) {
                 console.warn(`Failed to send notification to token index ${i}: ${r.error.code} - ${r.error.message}`);
            }
        });
        // --- End of your existing onRideCreated logic ---
    }
);

exports.createRideFromWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const data = req.body;
    console.log("📥 [Webhook] Received payload:", JSON.stringify(data));

    if (
      !data?.source?.latitude ||
      !data?.source?.longitude ||
      !data?.destination?.latitude ||
      !data?.destination?.longitude ||
      !data?.username ||
      !data?.phone_number
    ) {
      console.warn("❌ Missing required fields");
      return res.status(400).send("Missing required fields.");
    }

    const sourcePoint = [data.source.longitude, data.source.latitude];
    console.log("📌 Source Point:", sourcePoint);

    // 🔍 Load all zones
    const zonesSnap = await db.collection("zone").get();
    console.log(`📦 Loaded ${zonesSnap.size} zones`);

    let matchedZone = null;
    const checkedZoneIds = [];

    for (const doc of zonesSnap.docs) {
      const zone = doc.data();
      const area = zone.area;
      const zoneId = doc.id;
      checkedZoneIds.push(zoneId);

      if (!Array.isArray(area) || area.length < 3) {
        console.warn(`⚠️ Zone ${zoneId} skipped due to invalid area`);
        continue;
      }

      console.log(`📍 Zone ID: ${zoneId}, Name: ${zone.name}, Area points: ${area.length}`);

      const polygon = area.map((pt, idx) => {
        let lat, lng;
        if (pt._latitude !== undefined && pt._longitude !== undefined) {
          lat = pt._latitude;
          lng = pt._longitude;
        } else if (pt.latitude !== undefined && pt.longitude !== undefined) {
          lat = pt.latitude;
          lng = pt.longitude;
        } else {
          console.warn(`⚠️ Zone ${zoneId} has malformed point`, pt);
          return null;
        }
        console.log(`   🔹 Point ${idx}: [lng: ${lng}, lat: ${lat}]`);
        return [lng, lat];
      }).filter(Boolean);

      if (polygon.length < 3) {
        console.warn(`⚠️ Zone ${zoneId} has insufficient valid points`);
        continue;
      }

      // ✅ Ensure polygon is closed
      const closedPolygon = [...polygon];
      if (
        polygon[0][0] !== polygon[polygon.length - 1][0] ||
        polygon[0][1] !== polygon[polygon.length - 1][1]
      ) {
        closedPolygon.push(polygon[0]);
        console.log(`🔁 Polygon closed by adding starting point again`);
      }

      console.log(`🧭 Checking zone ${zoneId}, Polygon:`, JSON.stringify(closedPolygon));

      const turfPoly = turfPolygon([closedPolygon]);
      const turfPoint = point(sourcePoint);

      if (booleanPointInPolygon(turfPoint, turfPoly)) {
        matchedZone = { id: zoneId, ...zone };
        console.log(`✅ Match found in zone: ${zoneId}`);
        break;
      } else {
        console.log(`[❌ No Match] Point not in zone ${zoneId}`);
      }
    }

    if (!matchedZone) {
      console.error("❌ ❌ ❌ No suitable zone found for point:", sourcePoint);
      console.log("🗺️ Processed zone IDs:", JSON.stringify(checkedZoneIds));
      return res.status(500).send("No suitable zone found.");
    }

   // ✅ Fetch default service (by ID or fallback to enabled one)
   let defaultService = null;

   // Try to fetch by known default ID
   const DEFAULT_SERVICE_ID = "jR1XPIgw07G6BfDK2hyP";
   const serviceDoc = await db.collection("service").doc(DEFAULT_SERVICE_ID).get();

   if (serviceDoc.exists) {
     defaultService = { id: serviceDoc.id, ...serviceDoc.data() };
     console.log("✅ Default service found by ID:", DEFAULT_SERVICE_ID);
   } else {
     // Fallback: find first service with enable === true
     const servicesSnap = await db.collection("service").get();
     const allServices = servicesSnap.docs.map((d) => ({ id: d.id, ...d.data() }));
     defaultService = allServices.find((s) => s.enable === true);

     if (defaultService) {
       console.warn("⚠️ Default service ID not found. Fallback to first enabled service:", defaultService.id);
     }
   }

   if (!defaultService) {
     console.error("❌ No default service found.");
     return res.status(500).send("No default service found.");
   }


    // 📦 Create ride object
    const rideId = uuidv4();
    const newRide = {
      id: rideId,
      customerName: data.username,
      phoneNumber: data.phone_number,
      sourceLocationLatLng: new admin.firestore.GeoPoint(data.source.latitude, data.source.longitude),
      destinationLocationLatLng: new admin.firestore.GeoPoint(data.destination.latitude, data.destination.longitude),
      sourceLocationName: "Source via WhatsApp",
      destinationLocationName: "Destination via WhatsApp",
      createdDate: admin.firestore.FieldValue.serverTimestamp(),
      status: "Ride Placed",
      paymentStatus: false,
      paymentType: "cash",
      offerRate: "0",
      otp: Math.floor(1000 + Math.random() * 9000).toString(),
      customerIsWatchingLiveTracking: false,
      notifyUserIfDriverIsNotMovingEvenRideActive: false,
      userId: data.phone_number,
      zoneId: matchedZone.id,
      serviceId: defaultService.id,
      adminCommission: defaultService.adminCommission || {},
      taxList: [],
    };

    await db.collection("orders").doc(rideId).set(newRide);
    console.log(`✅ Ride created with ID: ${rideId}`);

    return res.status(200).send({ message: "Ride created", rideId });
  } catch (err) {
    console.error("❌ Error in createRideFromWebhook:", err);
    return res.status(500).send("Internal Server Error");
  }
});
