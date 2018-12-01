//
//  AppDelegate.swift
//  Inphoto
//
//  Created by liuding on 2018/11/25.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Photos
import Armchair
import JZLocationConverterSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Armchair.appID(APP.appID)
        
        PHPhotoLibrary.checkAuthorization { (authorized) in
            var viewController: UIViewController
            if !authorized {
                viewController = R.storyboard.welcome().instantiateInitialViewController()!
            } else {
                viewController = R.storyboard.main().instantiateInitialViewController()!
            }
            // 无效果，暂不明原因
            UIApplication.shared.keyWindow?.rootViewController = viewController
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        }
        
        JZLocationConverter.start { (error) in
            if let err = error {
                print(err)
            }
        }
        
        return true
    }
    
    @objc func photoLibarayAuthChanged() {
        
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

