//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import StreamChatUI
import UserNotifications
import UIKit

final class StreamChatWrapper {

    // This closure is called once the SDK is ready to register for remote push notifications
    var onRemotePushRegistration: (() -> Void)?

    // Chat client
    private var client: ChatClient?

    // ChatClient config
    var config: ChatClientConfig = {
        var config = ChatClientConfig(apiKeyString: apiKey)
        config.applicationGroupIdentifier = applicationGroupIdentifier
        return config
    }()

    // Instantiates chat client
    func setUpChat() {
        guard client == nil else {
            log.error("Client was already instantiated")
            return
        }

        // Set the log level
        setupLogger()

        // Create Client
        client = ChatClient(config: config)
    }

    func makeChannelListViewController(with userCredentials: UserCredentials) -> ChatChannelListVC {
        guard let client = self.client else {
            fatalError("Call `setUpChat` prior this call")
        }

        // UI
        let query = ChannelListQuery(filter: .containMembers(userIds: [userCredentials.id]))
        let controller = client.channelListController(query: query)
        let channelList = ChatChannelListVC.make(with: controller)
        return channelList
    }
}

// MARK: User Authentication

extension StreamChatWrapper {
    func connectUser(with userCredentials: UserCredentials) {
        guard let client = self.client else {
            fatalError("Call `setUpChat` prior this call")
        }

        /// connect to chat
        client.connectUser(
            userInfo: UserInfo(
                id: userCredentials.id,
                name: userCredentials.name,
                imageURL: userCredentials.avatarURL
            ),
            token: userCredentials.token) { [weak self] error in
                if let error = error {
                    log.warning(error.localizedDescription)
                } else {
                    // Register for push notification after succesful login
                    self?.onRemotePushRegistration?()
                }
            }
    }

    func logOut() {
        guard let client = self.client else {
            logClientNotInstantiated()
            return
        }
        let currentUserController = client.currentUserController()
        if let deviceId = currentUserController.currentUser?.currentDevice?.id {
            currentUserController.removeDevice(id: deviceId) { error in
                if let error = error {
                    log.warning("removing the device failed with an error \(error)")
                }
            }
        }

        client.disconnect()
        self.client = nil
    }
}

// MARK: Logging

extension StreamChatWrapper {

    private func setupLogger() {
        LogConfig.formatters = [
            PrefixLogFormatter(prefixes: [.info: "ℹ️", .debug: "🛠", .warning: "⚠️", .error: "🚨"])
        ]
        LogConfig.showThreadName = false
        LogConfig.showDate = false
        LogConfig.showFunctionName = false

        LogConfig.level = .warning
    }

    // Client not instantiated
    private func logClientNotInstantiated() {
        guard client != nil else {
            print("⚠️ Chat client is not instantiated")
            return
        }
    }
}

// MARK: Push Notifications

extension StreamChatWrapper {
    func registerForPushNotifications(with deviceToken: Data) {
        client?.currentUserController().addDevice(.apn(token: deviceToken, providerName: "APN-Configuration-Two")) {
            if let error = $0 {
                log.error("adding a device failed with an error \(error)")
            }
        }
    }

    func notificationInfo(for response: UNNotificationResponse) -> ChatPushNotificationInfo? {
        try? ChatPushNotificationInfo(content: response.notification.request.content)
    }
}
