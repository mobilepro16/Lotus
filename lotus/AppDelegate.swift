//
//  AppDelegate.swift
//  lotus
//
//  Created by Robert Grube on 1/2/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit
import FacebookCore
import PKHUD
import SendBirdSDK
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        _ = Profile.load()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        SBDMain.initWithApplicationId(SendBirdConstants.AppID)
        UIApplication.shared.applicationIconBadgeNumber = 0
        
//        notificationsIntegrate()
        FirebaseApp.configure()
        Auth.auth().signInAnonymously { authResult, error in
            guard let user = authResult?.user else { return }
        }
        guard let profile = Globals.sharedInstance.myProfile else {
            print("NO PROFILE")
            return true
        }
        
        let pushManager = PushNotificationManager(userID: profile.userId)
        pushManager.registerForPushNotifications()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
