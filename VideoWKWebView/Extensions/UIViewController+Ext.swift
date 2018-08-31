//
//  UIViewController+Ext.swift
//  VideoWKWebView
//
//  Created by Shingo Fukuyama on 2018/08/16.
//  Copyright © 2018 Shingo Fukuyama. All rights reserved.
//

import UIKit

extension UIViewController: TargetedExtensionCompatible {}
extension TargetedExtension where Base: UIViewController {

    func alertOK(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.base.view.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    func setupAppStateObservers(to selector: Selector) {
        let names: [Notification.Name] = [
            .UIApplicationWillEnterForeground,
            .UIApplicationDidBecomeActive,
            .UIApplicationWillResignActive,
            .UIApplicationDidEnterBackground,
            .UIApplicationWillTerminate
        ]
        for name in names {
            NotificationCenter.default.addObserver(self.base, selector: selector, name: name, object: nil)
        }
    }
}
