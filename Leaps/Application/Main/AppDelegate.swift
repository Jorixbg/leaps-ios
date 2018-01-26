//
//  AppDelegate.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/13/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import HockeySDK
import GoogleMaps
import GooglePlaces
import Firebase
import Messages
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var shared: AppDelegate!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        AppDelegate.shared = self
        
        //MARK: Hockey
        BITHockeyManager.shared().configure(withIdentifier: "AIzaSyDscXTHheBQsBdupg0dGZrGzpkNB3OnGPk")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()

        //MARK: GoogleMaps
        GMSServices.provideAPIKey("AIzaSyA9uJLwGxJb9K_kehkefxvRv_022LxQRYs")
        
        //MARK: Firebase & Firebase Messaging
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        //MARK: Push Notifications
        application.registerForRemoteNotifications()
        requestNotificationAuthorization(application: application)
        
        //MARK: Facebook
        StyleManager.applyDefaultStyle()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = "801378930759-m9jc5cgovq4hc76r6feaigqgmkq3qdhn.apps.googleusercontent.com"
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookHandled = FBSDKApplicationDelegate.sharedInstance().application(app,
                                                              open: url as URL,
                                                              sourceApplication: options[.sourceApplication] as? String,
                                                              annotation: options[.annotation])
        let googleHandled = GIDSignIn.sharedInstance().handle(url,
                                                              sourceApplication: options[.sourceApplication] as? String,
                                                              annotation: options[.annotation])
        return facebookHandled || googleHandled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    func requestNotificationAuthorization(application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // iOS10+, called when presenting notification in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        NSLog("[UserNotificationCenter] willPresentNotification: \(userInfo)")
        //TODO: Handle foreground notification
        completionHandler([.alert])
    }
    
    // iOS10+, called when received response (default open, dismiss or custom action) for a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NSLog("[UserNotificationCenter] didReceiveResponse: \(userInfo)")
        //TODO: Handle background notification
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NSLog("[RemoteNotification] didReceiveRegistrationToken: \(fcmToken)")
        registerFCMTokenToDatabase(token: fcmToken)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        NSLog("[RemoteNotification] didRefreshRegistrationToken: \(fcmToken)")
        registerFCMTokenToDatabase(token: fcmToken)
    }
    
    func registerFCMTokenToDatabase(token: String) {
        if UserManager.shared.isLoggedIn, let id = UserManager.shared.userID, let name = UserManager.shared.userName {
            let user = ["id": id,
                        "name": name,
                        "device_token": token]
            Database.database().reference().child("users").child(id).setValue(user)
        }
        else {
            UserManager.shared.setFcmToken(token: token)
        }
    }
    
    // iOS9, called when presenting notification in foreground
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("[RemoteNotification] applicationState: didReceiveRemoteNotification for iOS9: \(userInfo)")
        if UIApplication.shared.applicationState == .active {
            //TODO: Handle foreground notification
        } else {
            //TODO: Handle background notification
        }
    }
}
