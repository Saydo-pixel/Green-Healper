//
//  SceneDelegate.swift
//  EcoShop
//
//  Created by BP-36-201-06 on 30/11/2024.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Initialize the UIWindow with the windowScene
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Load the Main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Check if the user is logged in
        let isLoggedIn = checkUserLoggedIn()

        if isLoggedIn {
            // Load the TabBarController for logged-in users
            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "userTabBar") as? UITabBarController else {
                print("Error: Unable to instantiate MainTabBarController")
                return
            }
            window.rootViewController = tabBarController
        } else {
            // Load the LoginViewController for new users
            guard let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                print("Error: Unable to instantiate LoginViewController")
                return
            }
            window.rootViewController = loginViewController
        }

        // Make the window key and visible
        window.makeKeyAndVisible()
    }

    private func checkUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }




