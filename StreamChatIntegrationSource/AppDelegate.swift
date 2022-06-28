//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import UIKit
import StreamChat
import StreamChatUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    private let chat = StreamChatWrapper()
    private let pushNotifications = PushNotifications()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Handle push notifications
        handlePushNotificationResponse()
        chat.onRemotePushRegistration = { [weak self] in
            self?.pushNotifications.registerForPushNotifications()
        }

        // Setup & connect to Chat
        chat.setUpChat()

        // Connect default user
        let userCredentials = UserCredentials.default
        chat.connectUser(with: userCredentials)

        // UI
        let channelList = chat.makeChannelListViewController(with: userCredentials)

        /// Embed in navigation controller
        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: channelList)
        window?.makeKeyAndVisible()
 
        return true
    }
}

// MARK: Push Notifications

extension AppDelegate {


    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Registers current device for push notifications on Stream backend
        chat.registerForPushNotifications(with: deviceToken)
    }

    func handlePushNotificationResponse() {
        pushNotifications.onNotificationResponse = { response in
            guard case UNNotificationDefaultActionIdentifier = response.actionIdentifier else {
                return
            }

            print("Received notification: \(response.notification)")
        }
    }

}
