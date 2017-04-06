//
//  ViewController.swift
//  GetURLAndAddClick
//
//  Created by zqy on 2017/3/20.
//  Copyright © 2017年 zqy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "根视图"
        
        let label = ZQYTapLabbel(frame: CGRect(x: 50,y: 100,width: 300,height: 100));
        label.numberOfLines = 0;
        let string:NSString = "www.baidu.com，你猜这是啥，132343243.45t5t5猜对有奖啊，https://www.github.com";
        
        label.text = string as String;
        label.attributedText = label.text?.attributedWithStyleBook();
        self.view.addSubview(label);
        
        
        //接受通知监听
        NotificationCenter.default.addObserver(self, selector:#selector(didMsgRecv(notification:)),
                                               name: NSNotification.Name(rawValue: "sendInfoToVC"), object: nil)
    }
    func didMsgRecv(notification:NSNotification){

        let webView = ZQYWebViewController()
        webView.url = notification.object as? String
        self.navigationController?.pushViewController(webView, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

