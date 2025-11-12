//
//  SceneDelegate.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // If using a storyboard, the window is set up automatically.
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard scene is UIWindowScene else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Release resources for this scene if needed.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restart tasks paused while inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Pause ongoing tasks or disable timers.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Undo changes made on entering background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save data or release shared resources.
    }
}
