import UIKit
import Flutter
import flutter_local_notifications
import flutter_callkit_incoming
import PushKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GMSServices.provideAPIKey("AIzaSyAnr6SJ3dA0QTwpFyi3srFPIjWWDbbnyes")

        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        GeneratedPluginRegistrant.register(with: self)

        // Register VoIP push notifications
        registerForVoIPPushes()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func registerForVoIPPushes() {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }

    // Handle VoIP token update
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print("PushKit Token: \(token)")
    }

    // Handle incoming VoIP push
    func pushRegistry(
        _ registry: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for type: PKPushType,
        withCompletionHandler completion: @escaping () -> Void
    ) {
        let dictionary = payload.dictionaryPayload

        if let uuidString = dictionary["uuid"] as? String,
           let callerName = dictionary["callerName"] as? String,
           let handle = dictionary["handle"] as? String {

            let params: [String: Any] = [
                "id": uuidString,
                "nameCaller": callerName,
                "appName": "GoFlow",
                "avatar": "",
                "handle": handle,
                "type": 0, // 0 for audio call, 1 for video call
                "duration": 30000,
                "textAccept": "Accept",
                "textDecline": "Decline",
                "textMissedCall": "Missed call",
                "textCallback": "Call back",
                "extra": ["userId": handle],
                "android": [
                    "isCustomNotification": true,
                    "ringtonePath": "system_ringtone_default",
                    "backgroundColor": "#0955fa",
                    "actionColor": "#4CAF50"
                ],
                "ios": [
                    "iconName": "CallKitLogo"
                ]
            ]

            // Convert the dictionary to JSON Data
//            if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []) {
//                SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(jsonData as Foundation.Data, fromPushKit: true)
//            } else {
//                print("Error converting params to JSON Data")
//            }
        }

        completion()
    }

    // Handle rejected/missed call event
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("PushKit token invalidated")
    }
}