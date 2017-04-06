//
//  WPAttributedStyleAction.swift
//  GetURLAndAddClick
//
//  Created by zqy on 2017/4/6.
//  Copyright © 2017年 zqy. All rights reserved.
//

import UIKit

class WPAttributedStyleAction: NSObject {
    
    typealias selfAction = () -> ()
    
    var action : selfAction?

    init(_ action1: @escaping selfAction) {
        self.action = action1;
    }
    
    public class func styledActionWithAction(action1: @escaping () -> ()) -> NSArray {
        let container = WPAttributedStyleAction(action1)
        return container.styledAction();
    }
    private func styledAction() -> NSArray{
        return [["WPAttributedStyleAction":self],"link"]
    }
}
