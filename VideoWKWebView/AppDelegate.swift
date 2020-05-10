//
//  AppDelegate.swift
//  VideoWKWebView
//
//  Created by Shingo Fukuyama on 2018/08/14.
//  Copyright © 2018 Shingo Fukuyama. All rights reserved.
//

import UIKit
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            let viewController = WebViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            window.rootViewController = navigationController
            window.backgroundColor = UIColor.white
            window.makeKeyAndVisible()
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Make it works with iOS 13.
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}

