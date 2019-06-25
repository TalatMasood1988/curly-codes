//
//  DetailViewController.swift
//  NyTimes
//
//  Created by Maseeh Ahmed on 5/15/19.
//  Copyright © 2019 talat. All rights reserved.
//

import UIKit
import WebKit
import RSLoadingView

class DetailViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!
    var article:MArticle!
    let loadingView = RSLoadingView(effectType: RSLoadingView.Effect.twins)
    
    func configureView() {
        // Update the user interface for the detail item.
        self.navigationItem.title = article.articleTitle
        self.webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: article.articleUrl ?? "")!))

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingView.show(on: self.view) // Loading activity indicator
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.hide()
        
    }
}

