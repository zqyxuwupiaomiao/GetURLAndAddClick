//
//  ZQYWebViewController.swift
//  GetURLAndAddClick
//
//  Created by zqy on 2017/4/6.
//  Copyright © 2017年 zqy. All rights reserved.
//

import UIKit
import WebKit

class ZQYWebViewController: UIViewController {
    var webview = WKWebView()
    var url:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "webView"
        if (url?.hasPrefix("http"))! {
            
        }else{
            url = "http://" + url!
        }
        let webview = WKWebView(frame: self.view.bounds)
        let request = NSURLRequest(url:NSURL(string :url!)! as URL)
        webview.load(request as URLRequest)
        self.view.addSubview(webview)
        
//        webview.navigationDelegate = self as? WKNavigationDelegate
//        webview.uiDelegate = self as? WKUIDelegate
        
//        webview.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            self.title = webview.title
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
