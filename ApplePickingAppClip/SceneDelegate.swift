//
//  SceneDelegate.swift
//  ApplePickingAppClip
//
//  Created by Eli Zhang on 4/13/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // Create our game view controller - use the same one from your main app
        let gameViewController = AppClipGameViewController()
        
        window.rootViewController = gameViewController
        self.window = window
        window.makeKeyAndVisible()
        
        // Handle any invocation URL or activity
        handleContexts(connectionOptions)
    }
    
    func handleContexts(_ connectionOptions: UIScene.ConnectionOptions) {
        // Handle URL context if the app was launched from a link
        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
        
        // Handle activity if the app was launched from a QR code or NFC tag
        if let activity = connectionOptions.userActivities.first {
            handleUserActivity(activity)
        }
    }
    
    func handleIncomingURL(_ url: URL) {
        // Extract any parameters from URL
        // e.g., difficulty level, time limit, etc.
        print("App Clip launched with URL: \(url)")
    }
    
    func handleUserActivity(_ activity: NSUserActivity) {
        // Handle any context from user activity
        print("App Clip launched with activity: \(activity)")
    }
    
    // For handling App Clip card displayed at the bottom
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        handleUserActivity(userActivity)
    }
}
