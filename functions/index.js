const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const geofire = require("geofire-common");
const { v4: uuidv4 } = require("uuid");
const booleanPointInPolygon = require('@turf/boolean-point-in-polygon').default;
const { point, polygon: turfPolygon } = require('@turf/helpers');
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
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
                       title: "New Case Request",
                       body: "A new legal case is available for review. Open the app to view the details.",
                   },
            data: {
                orderId,
                type: "city_order",
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
    console.log("📥 [Webhook] Payload:", JSON.stringify(data));

    if (
      !data?.source?.latitude ||
      !data?.source?.longitude ||
      !data?.destination?.latitude ||
      !data?.destination?.longitude ||
      !data?.username ||
      !data?.phone_number ||
      !data?.selected_service
    ) {
      console.warn("❌ Missing required fields");
      return res.status(400).send("Missing required fields.");
    }

    const sourceLat = data.source.latitude;
    const sourceLng = data.source.longitude;
    const sourcePoint = [sourceLng, sourceLat];

    const rideId = uuidv4();
    const geoHash = geofire.geohashForLocation([sourceLat, sourceLng]);
    const geoPoint = new admin.firestore.GeoPoint(sourceLat, sourceLng);

    // Match Zone
    const zonesSnap = await db.collection("zone").get();
    let matchedZone = null;

    for (const doc of zonesSnap.docs) {
      const zone = doc.data();
      const area = zone.area;
      const zoneId = doc.id;

      const polygon = (Array.isArray(area) ? area : []).map((pt) =>
        pt._latitude && pt._longitude
          ? [pt._longitude, pt._latitude]
          : pt.latitude && pt.longitude
          ? [pt.longitude, pt.latitude]
          : null
      ).filter(Boolean);

      if (polygon.length >= 3) {
        if (polygon[0][0] !== polygon.at(-1)[0] || polygon[0][1] !== polygon.at(-1)[1]) {
          polygon.push(polygon[0]);
        }

        if (booleanPointInPolygon(point(sourcePoint), turfPolygon([polygon]))) {
          matchedZone = { id: zoneId, ...zone };
          break;
        }
      }
    }

    if (!matchedZone) {
      console.error("❌ No zone match for:", sourcePoint);
      return res.status(400).send("No suitable zone found.");
    }

    const SERVICE_ID_MAP = {
      1: "jR1XPIgw07G6BfDK2hyP",
      2: "XkIwHouQV5jWJfxIgFuw",
      3: "ARTK899vm5OENMDivH5g",
    };

    const selectedServiceId = SERVICE_ID_MAP[Number(data.selected_service)];
    if (!selectedServiceId) {
      return res.status(400).send("Invalid selected_service.");
    }

    const serviceDoc = await db.collection("service").doc(selectedServiceId).get();
    if (!serviceDoc.exists) {
      return res.status(400).send("Service not found.");
    }

    const selectedService = { id: serviceDoc.id, ...serviceDoc.data() };

    // Get or create user
    let authUser;
    try {
      authUser = await admin.auth().getUserByPhoneNumber(data.phone_number);
    } catch (err) {
      if (err.code === "auth/user-not-found") {
        authUser = await admin.auth().createUser({
          phoneNumber: data.phone_number,
          displayName: data.username,
        });

        await db.collection("users").doc(authUser.uid).set({
          id: authUser.uid,
          fullName: data.username,
          phoneNumber: data.phone_number,
          email: "",
          fcmToken: "",
          isActive: true,
          loginType: "phone",
          profilePic: null,
          walletAmount: "0",
          reviewsCount: "0.0",
          reviewsSum: "0.0",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        console.error("Auth error:", err);
        return res.status(500).send("User account error.");
      }
    }

    // Filter drivers
    const driversSnap = await db
      .collection("driver_users")
      .where("zoneIds", "array-contains", matchedZone.id)
      .where("serviceId", "==", selectedService.id)
      .where("isOnline", "==", true)
      .get();

    const matchedDrivers = driversSnap.docs.map((d) => ({
      id: d.id,
      ...d.data(),
    }));

    // ✅ Create ride object with full fields
    const newRide = {
      id: rideId,
      customerName: data.username,
      phoneNumber: data.phone_number,
      userId: authUser.uid,
      createdDate: admin.firestore.FieldValue.serverTimestamp(),
      updateDate: null,
      // Save as a map for client-side consumption
      sourceLocationLatLng: {
          latitude: sourceLat,
          longitude: sourceLng
      },
      // Save as a map for client-side consumption
      destinationLocationLatLng: {
          latitude: data.destination.latitude,
          longitude: data.destination.longitude
      },
//      sourceLocationLatLng: geoPoint,
//      destinationLocationLatLng: new admin.firestore.GeoPoint(data.destination.latitude, data.destination.longitude),
      sourceLocationName: "Source via WhatsApp",
      destinationLocationName: "Destination via WhatsApp",
      status: "Case Placed",
      driverId: null,
      acceptedDriverId: null,
      rejectedDriverId: null,
      finalRate: null,
      offerRate: "0",
      distance: "0.0",
      distanceType: "Km",
      paymentType: "cash",
      paymentStatus: false,
      otp: Math.floor(1000 + Math.random() * 9000).toString(),
      position: {
        geohash: geoHash,
        geopoint: geoPoint,
      },
      driverLocation: null,
      notifyUserIfDriverIsNotMovingEvenRideActive: false,
      customerIsWatchingLiveTracking: false,
      serviceId: selectedService.id,
      service: selectedService,
      zoneId: matchedZone.id,
      zone: matchedZone,
      adminCommission: selectedService.adminCommission || {},
      taxList: [],
    };

    await db.collection("orders").doc(rideId).set(newRide);
    console.log("✅ Ride created:", rideId);

    return res.status(200).send({
      message: "Ride created",
      rideId,
      matchedDrivers: matchedDrivers.map((d) => ({
        id: d.id,
        name: d.fullName || "",
        fcmToken: d.fcmToken || "",
      })),
      user: {
        uid: authUser.uid,
        phoneNumber: data.phone_number,
        displayName: authUser.displayName || data.username,
      },
    });

  } catch (err) {
    console.error("❌ Error in createRideFromWebhook:", err);
    return res.status(500).send("Internal server error.");
  }
});

exports.deleteUser = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'The function must be called while authenticated.'
        );
    }
    try {
        await admin.auth().deleteUser(data.uid);
        return { result: 'User successfully deleted' };
    } catch (error) {
        console.error('Error deleting user:', error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});

