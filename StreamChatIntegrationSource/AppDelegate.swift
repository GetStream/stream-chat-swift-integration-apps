//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import UIKit
import StreamChat
import StreamChatUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Logger
        setupLogger()
        
        // Client
        let credentials = UserCredentials.default
        setupChatClient(with: credentials)
        
        // UI
        let channelList = ChannelListVC()
        let query = ChannelListQuery(filter: .containMembers(userIds: [credentials.id]))
        channelList.controller = ChatClient.shared.channelListController(query: query)

        /// Embed in navigation controller
        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: channelList)
        window?.makeKeyAndVisible()
        
        return true
    }
        
    private func setupChatClient(with userCredentials: UserCredentials) {
        let config = ChatClientConfig(apiKey: .init(apiKey))

        /// create an instance of ChatClient and share it using the singleton
        ChatClient.shared = ChatClient(config: config)

        /// connect to chat
        ChatClient.shared.connectUser(
            userInfo: UserInfo(
                id: userCredentials.id,
                name: userCredentials.name,
                imageURL: userCredentials.avatarURL
            ),
            token: userCredentials.token
        )
    }
    
    private func setupLogger() {
        LogConfig.formatters = [
            PrefixLogFormatter(prefixes: [.info: "ℹ️", .debug: "🛠", .warning: "⚠️", .error: "🚨"])
        ]
        LogConfig.showThreadName = false
        LogConfig.showDate = false
        LogConfig.showFunctionName = false
        
        LogConfig.level = .warning
    }
}
