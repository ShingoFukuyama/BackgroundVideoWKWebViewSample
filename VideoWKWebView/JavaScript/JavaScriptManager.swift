//
//  JavaScriptManager.swift
//  VideoWKWebView
//
//  Created by Shingo Fukuyama on 2018/08/16.
//  Copyright © 2018 Shingo Fukuyama. All rights reserved.
//

import UIKit

class JavaScriptManager {

    static let messageDidGetVideoURL = "didGetVideoURL"

    static func load(javascriptFile: String) -> String? {
        if let filepath = Bundle.main.path(forResource: javascriptFile, ofType: "js") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                return nil
            }
        }
        return nil
    }

    static var videoPlayHook: String {
        if let javascript = load(javascriptFile: "videoPlayHook") {
            return javascript
        }
        return ""
    }

}
