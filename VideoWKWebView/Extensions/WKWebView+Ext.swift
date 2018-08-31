//
//  WKWebView+Ext.swift
//  VideoWKWebView
//
//  Created by Shingo Fukuyama on 2018/08/16.
//  Copyright © 2018 Shingo Fukuyama. All rights reserved.
//

import WebKit

var webViewProcessPool: WKProcessPool = WKProcessPool()

extension WKWebView: TargetedExtensionCompatible {}
extension TargetedExtension where Base: WKWebView {

    static var keyPathCanGoBack: String {
        return NSStringFromSelector(#selector(getter: WKWebView.canGoBack))
    }

    static var keyPathCanGoForward: String {
        return NSStringFromSelector(#selector(getter: WKWebView.canGoForward))
    }

    static var keyPathTitle: String {
        return NSStringFromSelector(#selector(getter: WKWebView.title))
    }

    static func create(with configuration: WKWebViewConfiguration, delegate: WKScriptMessageHandler) -> WKWebView {

        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        // this property causes some video related issues on some sites
        // configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.allowsInlineMediaPlayback = true
        configuration.processPool = webViewProcessPool

        let userScript = WKUserScript(source: JavaScriptManager.videoPlayHook, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        userContentController.add(delegate, name: JavaScriptManager.messageDidGetVideoURL)
        configuration.userContentController = userContentController

        return WKWebView(frame: .zero, configuration: configuration)
    }

    func close(completion: (() -> Void)? = nil) {
        let script = ";window.close();"
        base.evaluateJavaScript(script, completionHandler: { (_, _) in
            completion?()
        })
    }

}
