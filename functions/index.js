const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const fetch = require("node-fetch"); // Make sure node-fetch v2 is installed: npm install node-fetch@2

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

        if (!zoneId || !serviceId) {
            console.log("⚠️ Missing zoneId or serviceId, skipping notification.");
            return;
        }

        const driversSnap = await db
            .collection("driver_users")
            .where("zoneIds", "array-contains", zoneId)
            .where("serviceId", "==", serviceId)
            .get();

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


//My Complete Function to test

// Helper function to send replies via Kommo API
async function sendKommoReply(chatId, text, cfg) {
    if (!chatId || !text || !cfg.domain || !cfg.integration_id || !cfg.token) {
        console.error("🚨 [sendKommoReply] Missing parameters.");
        return;
    }
    const url = `${cfg.domain}api/v4/integrations/${cfg.integration_id}/send`;
    try {
        const body = JSON.stringify({ chat_id: chatId.toString(), text: text });
        console.log(`[sendKommoReply] Sending to ${url}, body: ${body}`);
        const response = await fetch(url, {
            method: "POST",
            headers: { Authorization: `Bearer ${cfg.token}`, "Content-Type": "application/json" },
            body: body,
        });
        if (!response.ok) {
            console.error(`🚨 [sendKommoReply] Kommo API error: ${response.status}`, await response.text());
        } else {
            console.log("✅ [sendKommoReply] Kommo reply sent successfully.");
        }
    } catch (err) {
        console.error("🔥 [sendKommoReply] Error:", err);
    }
}

// Helper function to fetch the latest location message from Kommo
async function getLatestLocationMessage(leadId, cfg) {
    // IMPORTANT: You'll need to find the correct Kommo API endpoint and parameters.
    // This is a placeholder for the logic. Common endpoints are for talks or lead messages.
    // Let's assume you need the 'talks' related to the lead to get messages.
    // This might require multiple API calls: 1. Get talks for lead, 2. Get messages for a talk.
    // Or, if a direct chat_id is available from the webhook, that's better.

    console.log(`[getLatestLocationMessage] Fetching messages for leadId: ${leadId}`);
    // Example: First, find talks associated with the lead
    const talksUrl = `${cfg.domain}api/v4/leads/${leadId}/talks`; // This endpoint might not be exact
    let messagesUrl = '';

    try {
        console.log(`[getLatestLocationMessage] Fetching talks from: ${talksUrl}`);
        const talksResponse = await fetch(talksUrl, {
            headers: { Authorization: `Bearer ${cfg.token}` },
        });
        if (!talksResponse.ok) {
            console.error(`🚨 [getLatestLocationMessage] Error fetching talks: ${talksResponse.status}`, await talksResponse.text());
            return null;
        }
        const talksData = await talksResponse.json();
        console.log(`[getLatestLocationMessage] Talks data: ${JSON.stringify(talksData)}`);

        // Assuming the most recent talk is the relevant one, and it has an ID
        // You might need more sophisticated logic to find the correct chat/talk
        if (talksData?._embedded?.talks && talksData._embedded.talks.length > 0) {
            // Sort talks by last message timestamp if available, or take the first/last one.
            // For simplicity, let's take the first talk. In reality, you'd want the most recent WhatsApp chat.
            const talkId = talksData._embedded.talks[0].id; // Adjust based on actual API response
            messagesUrl = `${cfg.domain}api/v4/talks/${talkId}/messages?limit=10`; // Get last 10 messages
            console.log(`[getLatestLocationMessage] Fetching messages from: ${messagesUrl}`);
        } else {
            console.log("[getLatestLocationMessage] No talks found for lead.");
            return null;
        }

        const messagesResponse = await fetch(messagesUrl, {
            headers: { Authorization: `Bearer ${cfg.token}` },
        });

        if (!messagesResponse.ok) {
            console.error(`🚨 [getLatestLocationMessage] Error fetching messages: ${messagesResponse.status}`, await messagesResponse.text());
            return null;
        }

        const messagesData = await messagesResponse.json();
        console.log(`[getLatestLocationMessage] Received messages data: ${JSON.stringify(messagesData._embedded?.messages?.slice(0,3) || [])}`); // Log first 3 for brevity


        if (messagesData?._embedded?.messages) {
            // Kommo messages are usually ordered newest first (or oldest, check API)
            // We need the most RECENT location message.
            for (const message of messagesData._embedded.messages) {
                // The structure of a location message in Kommo API needs to be determined.
                // Common structures: message.type === 'location', or message.note_type,
                // or message.element_type with specific location details in message.text or a metadata field.
                // THIS IS A GUESS - YOU MUST CHECK KOMMO API RESPONSE FOR LOCATION MESSAGES
                if (message.type === 'location' || (message.metadata?.geo_position && message.metadata.geo_position.latitude)) {
                    console.log(`[getLatestLocationMessage] Found location message: ${JSON.stringify(message)}`);
                    // Adapt these paths based on actual Kommo API response structure for location messages
                    return {
                        latitude: message.metadata?.geo_position?.latitude || message.text?.latitude, // Adjust path
                        longitude: message.metadata?.geo_position?.longitude || message.text?.longitude, // Adjust path
                        address: message.metadata?.geo_position?.description || message.text?.address || message.text?.title || 'Address not found' // Adjust path
                    };
                }
                // Log other message types to help identify location message structure
                console.log(`[getLatestLocationMessage] Non-location message type: ${message.type}, note_type: ${message.note_type}, text: ${message.text?.substring(0,50)}`);

            }
        }
        console.log("[getLatestLocationMessage] No suitable location message found in recent messages.");
        return null;
    } catch (error) {
        console.error("🔥 [getLatestLocationMessage] Exception:", error);
        return null;
    }
}


exports.kommoRideBot = functions.https.onRequest(
    {
        secrets: ["KOMMO_DOMAIN", "KOMMO_INTEGRATION_ID", "KOMMO_TOKEN"],
        region: "us-central1",
    },
    async (req, res) => {
        console.log("--- [kommoRideBot] Function Invoked (Strategy 1) ---");
        console.log("[kommoRideBot] Request Body:", JSON.stringify(req.body));

        const cfg = { // Kommo API config
            domain: process.env.KOMMO_DOMAIN,
            integration_id: process.env.KOMMO_INTEGRATION_ID,
            token: process.env.KOMMO_TOKEN,
        };

        let sessionId, leadId, contactId, phoneForReply; // Get chat_id if Kommo sends it

        try {
            sessionId = req.body?.session_id;
            leadId = req.body?.lead_id;
            contactId = req.body?.contact_id; // Assuming Kommo widget will send this
            // We need a phone number to reply to. Fetch it if not directly available.
            // Or use a chat_id if the webhook payload includes one from Kommo.
            // For now, let's assume we need to fetch the contact to get a phone.
            // This logic might need adjustment based on what the Kommo webhook *can* send.

            console.log("--- [kommoRideBot] Extracted IDs ---");
            console.log(`[kommoRideBot] sessionId: >${sessionId}<`);
            console.log(`[kommoRideBot] leadId: >${leadId}<`);
            console.log(`[kommoRideBot] contactId: >${contactId}<`);


            if (!cfg.domain || !cfg.integration_id || !cfg.token) {
                console.error("🚨 Missing Kommo configuration from secrets!");
                return res.status(500).send("Internal configuration error");
            }
            console.log("[kommoRideBot] Kommo config loaded.");

            if (!sessionId || !leadId) { // Removed contactId from immediate validation for now
                console.error("🚨 Validation Failed: Missing session_id or lead_id.", JSON.stringify(req.body));
                return res.status(200).send("ok (logged bad request)");
            }
            console.log("[kommoRideBot] Basic ID Validation Passed.");

            // Determine phoneForReply. Best if Kommo can send a chat_id or explicit reply_to_phone.
            // Fetching contact details to get a phone number:
            if (contactId) {
                const contactUrl = `${cfg.domain}api/v4/contacts/${contactId}`;
                console.log(`[kommoRideBot] Fetching contact details from: ${contactUrl}`);
                const contactRes = await fetch(contactUrl, { headers: { Authorization: `Bearer ${cfg.token}` } });
                if (contactRes.ok) {
                    const contactData = await contactRes.json();
                    // Find the phone number - Kommo contacts can have multiple.
                    // Look for one marked as WhatsApp or a primary one.
                    // This is a guess, check actual Kommo contact API response structure
                    if (contactData?.custom_fields_values) {
                        for (const field of contactData.custom_fields_values) {
                            if (field.field_name === 'Phone' || field.field_code === 'PHONE') { // Adjust field name/code
                                if (field.values && field.values.length > 0) {
                                    phoneForReply = field.values[0].value;
                                    console.log(`[kommoRideBot] Found phoneForReply from contact custom field: ${phoneForReply}`);
                                    break;
                                }
                            }
                        }
                    }
                    if (!phoneForReply && contactData?.name) { // Fallback if no specific phone field found
                        // This part is risky, the contact name might just be a name, not a phone
                        // phoneForReply = contactData.name;
                        // console.log(`[kommoRideBot] Using contact name as phoneForReply (fallback): ${phoneForReply}`);
                    }
                } else {
                    console.error(`🚨 Error fetching contact ${contactId}: ${contactRes.status}`, await contactRes.text());
                }
            }

            if (!phoneForReply) {
                console.error("🚨 Critical: Could not determine phone number for reply. Aborting.");
                 // Don't send a reply to Kommo webhook here, just log and exit gracefully.
                return res.status(200).send("ok (error, no phone for reply)");
            }


            const sessionDocId = sessionId.toString();
            const sessRef = db.collection("whatsapp_sessions").doc(sessionDocId);
            const snap = await sessRef.get();
            const session = snap.exists ? snap.data() : {};
            console.log(`[kommoRideBot] Session exists: ${snap.exists}, Data: ${JSON.stringify(session)}`);

            let replyText;

            if (!session.pickupAddr) {
                // ---- PICKUP STAGE ----
                console.log("[kommoRideBot] Handling Pickup Stage: Fetching latest location message...");
                const pickupLocData = await getLatestLocationMessage(leadId, cfg);

                if (pickupLocData && pickupLocData.latitude && pickupLocData.longitude) {
                    console.log(`[kommoRideBot] Successfully fetched pickup location: ${JSON.stringify(pickupLocData)}`);
                    const latNum = parseFloat(pickupLocData.latitude);
                    const lonNum = parseFloat(pickupLocData.longitude);

                    if (!isNaN(latNum) && !isNaN(lonNum)) {
                        const pickupGeo = new admin.firestore.GeoPoint(latNum, lonNum);
                        const pickupData = {
                            pickupAddr: pickupLocData.address || `Lat: ${latNum}, Lon: ${lonNum}`,
                            pickupGeo: pickupGeo,
                            timestamp: admin.firestore.FieldValue.serverTimestamp()
                        };
                        await sessRef.set(pickupData, { merge: true });
                        console.log(`[kommoRideBot] Pickup data saved to session: ${sessionDocId}`);
                        replyText = "📍 Got your pickup! Now please share your drop-off location.";
                    } else {
                        console.warn("[kommoRideBot] Fetched pickup location had invalid Lat/Lon values.");
                        replyText = "❓ Sorry, I couldn't understand the pickup location. Please try sharing it again using the 📎 attachment.";
                    }
                } else {
                    console.warn("[kommoRideBot] Could not fetch or parse pickup location from Kommo messages.");
                    replyText = "❓ Sorry, I couldn't get your pickup location. Please try sharing it again using the 📎 attachment.";
                }
                await sendKommoReply(phoneForReply, replyText, cfg);

            } else {
                // ---- DROPOFF STAGE ----
                console.log("[kommoRideBot] Handling Dropoff Stage: Fetching latest location message...");
                const dropoffLocData = await getLatestLocationMessage(leadId, cfg);

                if (dropoffLocData && dropoffLocData.latitude && dropoffLocData.longitude) {
                    console.log(`[kommoRideBot] Successfully fetched dropoff location: ${JSON.stringify(dropoffLocData)}`);
                    const latNum = parseFloat(dropoffLocData.latitude);
                    const lonNum = parseFloat(dropoffLocData.longitude);

                    if (!isNaN(latNum) && !isNaN(lonNum)) {
                        const dropoffGeo = new admin.firestore.GeoPoint(latNum, lonNum);
                        const pickupAddr = session.pickupAddr;
                        const pickupGeo = session.pickupGeo; // This should be a GeoPoint from session

                        if (!pickupAddr || !pickupGeo) {
                            console.error("🚨 Critical error: Pickup data missing from session for dropoff stage.");
                            replyText = "😥 Something went wrong with your previous pickup. Please start over.";
                            await sessRef.delete(); // Clear bad session
                        } else {
                            const order = {
                                sourceLocationName: pickupAddr,
                                destinationLocationName: dropoffLocData.address || `Lat: ${latNum}, Lon: ${lonNum}`,
                                sourceLocationLatLng: pickupGeo, // Already a GeoPoint
                                destinationLocationLatLng: dropoffGeo,
                                userId: leadId.toString(), // Or contactId
                                status: "Ride Placed",
                                createdDate: admin.firestore.FieldValue.serverTimestamp(),
                                // serviceId: null, // You'll need logic for this
                                // zoneId: null,    // And this
                            };
                            console.log(`[kommoRideBot] Creating order: ${JSON.stringify(order)}`);
                            const docRef = await db.collection("orders").add(order);
                            replyText = `✅ Ride booked! Your Ride ID is: *${docRef.id}*. A driver will contact you shortly.`;
                            await sessRef.delete();
                            console.log(`[kommoRideBot] Order created, session deleted: ${sessionDocId}`);
                        }
                    } else {
                        console.warn("[kommoRideBot] Fetched dropoff location had invalid Lat/Lon values.");
                        replyText = "❓ Sorry, I couldn't understand the drop-off location. Please try sharing it again using the 📎 attachment.";
                    }
                } else {
                    console.warn("[kommoRideBot] Could not fetch or parse dropoff location from Kommo messages.");
                    replyText = "❓ Sorry, I couldn't get your drop-off location. Please try sharing it again using the 📎 attachment.";
                }
                await sendKommoReply(phoneForReply, replyText, cfg);
            }

            return res.status(200).send("ok");

        } catch (err) {
            console.error("🔥 kommoRideBot Uncaught Error:", err);
            // Attempt to send a generic error message if possible
            if (phoneForReply && cfg.domain) {
                await sendKommoReply(phoneForReply, "😥 Oops! Something went wrong on our end. Please try again.", cfg);
            }
            return res.status(500).send("Internal Server Error");
        } finally {
            console.log("--- [kommoRideBot] Function Execution Finished ---");
        }
    }
);



//My Complete FUnction down here

// 📩 2) HTTPS Webhook for Kommo → KommoRideBot (WITH ADDED LOGGING FOR GEOPOINT)
// 📩 2) HTTPS Webhook for Kommo → KommoRideBot (MORE PRE-VALIDATION LOGGING)
// 📩 2) HTTPS Webhook for Kommo → KommoRideBot (PARSING STRINGIFIED JSON FROM KEY-VALUE)
// 📩 2) HTTPS Webhook for Kommo → KommoRideBot (MATCHING ACTUAL RECEIVED STRUCTURE)
//exports.kommoRideBot = functions.https.onRequest(
//    {
//        secrets: ["KOMMO_DOMAIN", "KOMMO_INTEGRATION_ID", "KOMMO_TOKEN"],
//        region: "us-central1",
//    },
//    async (req, res) => {
//        console.log("--- [kommoRideBot] Function Invoked ---");
//        console.log("[kommoRideBot] Request Body:", JSON.stringify(req.body));
//
//        let sessionId, leadId, phone, loc, msgText; // Declare variables
//
//        try {
//            // --- Extract based on keys Kommo actually sends ---
//            sessionId = req.body?.session_id;        // Expecting top-level string (will be placeholder)
//            leadId = req.body?.lead_id;              // Expecting top-level string/number (seems to work)
//            const contactObj = req.body?.contact_json; // Expecting top-level OBJECT (with placeholder inside)
//            loc = req.body?.location_json;           // Expecting top-level OBJECT (with placeholders inside)
//            msgText = (req.body?.text || "").trim(); // Optional text field (will be placeholder)
//
//            // Extract phone from the received contact object
//            phone = contactObj?.whatsapp_phone;     // Will be the placeholder {{contact.whatsapp_phone}} or ""
//
//            console.log("--- [kommoRideBot] Values After Extraction ---");
//            console.log(`[kommoRideBot] Extracted sessionId: >${sessionId}< (Type: ${typeof sessionId})`);
//            console.log(`[kommoRideBot] Extracted leadId: >${leadId}< (Type: ${typeof leadId})`);
//            console.log(`[kommoRideBot] Extracted contact_json object: ${JSON.stringify(contactObj)}`); // Log the object
//            console.log(`[kommoRideBot] Extracted phone from contact_json: >${phone}< (Type: ${typeof phone})`);
//            console.log(`[kommoRideBot] Extracted location_json object (assigned to loc): ${JSON.stringify(loc)}`);
//            if(loc) {
//                console.log(`[kommoRideBot] Extracted loc.latitude: >${loc.latitude}< (Type: ${typeof loc.latitude})`); // Will be placeholder
//                console.log(`[kommoRideBot] Extracted loc.longitude: >${loc.longitude}< (Type: ${typeof loc.longitude})`);// Will be placeholder
//                console.log(`[kommoRideBot] Extracted loc.address: >${loc.address}< (Type: ${typeof loc.address})`);    // Will be placeholder
//            } else {
//                 console.log("[kommoRideBot] No location_json object received.");
//            }
//            console.log("--- [kommoRideBot] End Extraction Values ---");
//
//
//            // --- Validation ---
//            // NOTE: This validation might PASS now if placeholders are received,
//            // because placeholder strings are not 'falsy' like an empty string was.
//             if (!sessionId || !leadId || !phone || phone === '{{contact.whatsapp_phone}}' || sessionId === '{{session.id}}') { // Added checks for placeholders
//                console.error(`🚨 [kommoRideBot] Validation Failed! Details: sessionId='${sessionId}', leadId='${leadId}', phone='${phone}'`);
//                console.error("🚨 [kommoRideBot] Failing fields check: !sessionId=" + (!sessionId) + ", !leadId=" + (!leadId) + ", !phone=" + (!phone) + ", phoneIsPlaceholder=" + (phone === '{{contact.whatsapp_phone}}') + ", sessionIdIsPlaceholder=" + (sessionId === '{{session.id}}'));
//                console.error("🚨 [kommoRideBot] Full payload causing validation failure:", JSON.stringify(req.body));
//                return res.status(200).send("ok (logged bad request)");
//            }
//            console.log("[kommoRideBot] Basic Validation Passed.");
//
//
//            // --- Rest of function logic ---
//            // EXPECT ERRORS HERE when parseFloat tries " {{message.location.latitude}} "
//            // or when Kommo reply uses " {{contact.whatsapp_phone}} " as chat_id
//            const sessionDocId = sessionId.toString();
//            const sessRef = db.collection("whatsapp_sessions").doc(sessionDocId);
//            // ... (rest of the code remains the same, using 'loc', 'phone', 'leadId') ...
//            // ... GeoPoint creation will fail with NaN ...
//            // ... Kommo reply will fail with invalid chat_id ...
//
//            // ... [ The existing logic for GeoPoint creation, Firestore, Kommo reply ] ...
//            // ... [ This part WILL fail because 'loc.latitude' etc. are still placeholders ] ...
//
//            // Example of expected failure point:
//            let geoPointForPickup = null;
//            if (loc?.latitude && loc?.longitude) {
//                 console.log(`[kommoRideBot] Attempting to create GeoPoint for PICKUP. Lat: ${loc.latitude}, Lon: ${loc.longitude}`); // Will log placeholders
//                 const latNum = parseFloat(loc.latitude); // This will likely become NaN
//                 const lonNum = parseFloat(loc.longitude); // This will likely become NaN
//                 if (!isNaN(latNum) && !isNaN(lonNum)) { // This condition will be FALSE
//                     // ... code to create GeoPoint ...
//                 } else {
//                      console.warn("[kommoRideBot] Failed to parse latitude/longitude as numbers for PICKUP."); // EXPECT THIS LOG
//                 }
//            }
//            // ... rest of logic ...
//
//
//        } catch (err) {
//            console.error("🔥 kommoRideBot Uncaught Error:", err);
//            return res.status(500).send("Internal Server Error");
//        } finally {
//            console.log("--- [kommoRideBot] Function Execution Finished ---");
//        }
//    }
//);