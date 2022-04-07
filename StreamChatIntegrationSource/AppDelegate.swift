//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import UIKit
import StreamChat
import StreamChatUI
import Atlantis

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Logger
        setupLogger()
        
        // Client
        setupChatClient()
        
        // UI
        let channelList = ChannelListVC()
        let query = ChannelListQuery(filter: .containMembers(userIds: ["tim"]))
        channelList.controller = ChatClient.shared.channelListController(query: query)

        /// Embed in navigation controller
        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: channelList)
        window?.makeKeyAndVisible()
        
        return true
    }
        
    private func setupChatClient() {
        Atlantis.start()

        var config = ChatClientConfig(apiKey: .init("uykdzqamca7z"))
//        config.baseURL = BaseURL(url: URL(string: "chat-edge-frankfurt-ce1.stream-io-api.com")!)

        /// create an instance of ChatClient and share it using the singleton
        ChatClient.shared = ChatClient(config: config)

        /// connect to chat
        ChatClient.shared.connectUser(
            userInfo: UserInfo(
                id: "tim",
                name: "tim",
                imageURL: nil
            ),
            token: try! Token(rawValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidGltIn0.kKN6tKi0OeLb_yM8yLX9ZcoT02NhPPkNybsPAhrYtek")
        ) { error in
            if let error = error {
                print("Connection failed with: \(error)")
            }

        }
    }
    
    private func setupLogger() {
        LogConfig.formatters = [
            PrefixLogFormatter(prefixes: [.info: "ℹ️", .debug: "🛠", .warning: "⚠️", .error: "🚨"])
        ]
        LogConfig.showThreadName = false
        LogConfig.showDate = false
        LogConfig.showFunctionName = false
        
        LogConfig.level = .debug
    }
}
