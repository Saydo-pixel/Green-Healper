//
//  AppDelegate.swift
//  EcoShop
//
//  Created by BP-36-201-06 on 30/11/2024.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        let secondaryOptions = FirebaseOptions(googleAppID: "1:409841563321:ios:5b70bff9e95eb6d1830d68", gcmSenderID: "409841563321")
        secondaryOptions.apiKey = "AIzaSyAlMSFBfBgRSFLrrVa0HL4PSXxHoF2objI"
        secondaryOptions.storageBucket = "tesla-clone-a0f5d.appspot.com"
        FirebaseApp.configure(name: "secondary", options: secondaryOptions)
        // Enable Firestore debug logging during development
        let db = Firestore.firestore()
        let settings = db.settings
        // Use the simpler persistence setting
        settings.isPersistenceEnabled = true
        db.settings = settings
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Cleanup Firestore connections
        let db = Firestore.firestore()
        db.terminate { _ in
            print("Firestore connection terminated cleanly")
        }
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
