//
//  WebViewUIManager.swift
//  VideoWKWebView
//
//  Created by Shingo Fukuyama on 2018/08/14.
//  Copyright © 2018 Shingo Fukuyama. All rights reserved.
//

import WebKit

protocol WebViewUIManagerProtocol: class {
    func open(webView: WKWebView)
    func close(webView: WKWebView)
}

class WebViewUIManager: NSObject {

    weak var viewController: (WebViewUIManagerProtocol & UIViewController)?

    init(with viewController: WebViewUIManagerProtocol & UIViewController) {
        self.viewController = viewController
        super.init()
    }

}

extension WebViewUIManager: WKUIDelegate {

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        guard let viewController = viewController,
            viewController.presentedViewController == nil else {
            completionHandler()
            return
        }
        let title: String? = webView.url?.host ?? nil
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        DispatchQueue.main.async {
            viewController.view.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        guard let viewController = viewController,
            viewController.presentedViewController == nil else {
            completionHandler(false)
            return
        }
        let title: String? = webView.url?.host ?? nil
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        DispatchQueue.main.async {
            viewController.view.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        guard let viewController = viewController,
            viewController.presentedViewController == nil else {
            completionHandler(nil)
            return
        }
        let title: String? = webView.url?.host ?? nil
        let alert = UIAlertController.init(title: title, message: prompt, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            if let text = alert.textFields?.first?.text {
                completionHandler(text)
            }
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
            completionHandler(nil)
        }))
        DispatchQueue.main.async {
            viewController.view.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    func webViewDidClose(_ webView: WKWebView) {
        viewController?.close(webView: webView)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let viewController = viewController else {
            return nil
        }
        let subWebView = WKWebView(frame: webView.bounds, configuration: configuration)
        viewController.open(webView: subWebView)
        return subWebView
    }

/*
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {

    }

    func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {

    }

    func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {

    }
 */

}
