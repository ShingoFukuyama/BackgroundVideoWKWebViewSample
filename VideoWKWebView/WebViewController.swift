//
//  WebViewController.swift
//  VideoWKWebView
//
//  Created by Shingo Fukuyama on 2018/08/14.
//  Copyright © 2018 Shingo Fukuyama. All rights reserved.
//

import UIKit
import WebKit

private let defaultURLString = "https://www.google.co.jp/search?q=%E7%8C%AB&source=lnms&tbm=vid"

class WebViewController: UIViewController {

    private lazy var webView: WKWebView = {
        return WKWebView.ext.create(with: WKWebViewConfiguration(), delegate: self)
    }()

    private var subWebViews: [WKWebView] = [] {
        didSet {
            updateNavigationBar()
        }
    }

    private var currentWebView: WKWebView {
        return subWebViews.last ?? webView
    }

    private lazy var webViewUIManager = WebViewUIManager(with: self)

    fileprivate lazy var reloadButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reload(sender:)))
        barButton.width = 40
        return barButton
    }()

    fileprivate lazy var goBackButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "◀︎", style: .plain, target: self, action: #selector(self.goBack(sender:)))
        barButton.width = 40
        return barButton
    }()

    fileprivate lazy var goForwardButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "▶︎", style: .plain, target: self, action: #selector(self.goForward(sender:)))
        barButton.width = 40
        return barButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItems = [goBackButton, goForwardButton]
        navigationItem.rightBarButtonItem = reloadButton
        updateNavigationBar()

        setup(webView: webView)
        view.addSubview(webView)
        let url = URL(string: defaultURLString)!
        webView.load(URLRequest(url: url))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let superview = webView.superview {
            webView.frame = superview.bounds
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath,
            !keyPath.isEmpty else {
                return
        }
        guard let webView = object as? WKWebView,
            webView == currentWebView else {
                return
        }
        switch keyPath {
        case WKWebView.ext.keyPathCanGoBack:
            updateNavigationBar()
        case WKWebView.ext.keyPathCanGoForward:
            updateNavigationBar()
        case WKWebView.ext.keyPathTitle:
            navigationItem.title = currentWebView.title
        default:
            break
        }
    }

}

extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ext.alertOK(title: webView.url?.host, message: error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        ext.alertOK(title: webView.url?.host, message: error.localizedDescription)
    }

}

extension WebViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body: Any = message.body
        switch message.name {
        case JavaScriptManager.messageDidGetVideoURL:
            guard let urlString = body as? String,
                let url = URL(string: urlString),
                navigationController?.viewControllers.last == self else {
                    return
            }
            print("\(type(of: self)) \(#function)  video url:\(url)")
            let videoViewController = VideoViewController(with: url)
            navigationController?.pushViewController(videoViewController, animated: true)
        default:
            break
        }
    }

}

extension WebViewController: WebViewUIManagerProtocol {

    func open(webView: WKWebView) {
        setup(webView: webView)
        view.addSubview(webView)
        subWebViews.append(webView)
    }

    func close(webView: WKWebView) {
        for (index, subWebView) in subWebViews.enumerated() {
            if subWebView == webView {
                if webView.isLoading {
                    webView.stopLoading()
                }
                webView.removeObserver(self, forKeyPath: WKWebView.ext.keyPathCanGoBack)
                webView.removeObserver(self, forKeyPath: WKWebView.ext.keyPathCanGoForward)
                webView.removeObserver(self, forKeyPath: WKWebView.ext.keyPathTitle)
                webView.removeFromSuperview()
                subWebViews.remove(at: index)
                break
            }
        }
    }

}

fileprivate extension WebViewController {

    func updateNavigationBar() {
        if subWebViews.isEmpty {
            goBackButton.isEnabled = currentWebView.canGoBack
        } else {
            goBackButton.isEnabled = true
        }
        goForwardButton.isEnabled = currentWebView.canGoForward
        navigationItem.title = currentWebView.title
    }

    @objc func goBack(sender: Any) {
        if currentWebView.canGoBack {
            currentWebView.goBack()
            updateNavigationBar()
        } else if !subWebViews.isEmpty {
            currentWebView.ext.close { [weak self] in
                self?.updateNavigationBar()
            }
        }
    }

    @objc func goForward(sender: Any) {
        if currentWebView.canGoForward {
            currentWebView.goForward()
            updateNavigationBar()
        }
    }

    @objc func reload(sender: Any) {
        if currentWebView.isLoading {
            currentWebView.stopLoading()
        }
        currentWebView.reloadFromOrigin()
        reloadButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [weak self] in
            self?.reloadButton.isEnabled = true
        }
    }

    func setup(webView: WKWebView) {
        webView.addObserver(self, forKeyPath: WKWebView.ext.keyPathCanGoBack, options: [.new], context: nil)
        webView.addObserver(self, forKeyPath: WKWebView.ext.keyPathCanGoForward, options: [.new], context: nil)
        webView.addObserver(self, forKeyPath: WKWebView.ext.keyPathTitle, options: [.new], context: nil)

        webView.uiDelegate = webViewUIManager
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
    }

}
