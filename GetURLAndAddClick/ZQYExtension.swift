//
//  ZQYExtension.swift
//  GetURLAndAddClick
//
//  Created by zqy on 2017/3/27.
//  Copyright © 2017年 zqy. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableString{

    private func replaceFirstTagToArray(array:NSMutableArray) -> Bool{
    
        let openTagRange = self.range(of: "<")
        
        if openTagRange.length == 0 {
            return false
        }
        let closeTagRange = self.range(of: ">", options: .caseInsensitive, range: NSRange(location: openTagRange.location + openTagRange.length, length: self.length - (openTagRange.location + openTagRange.length)))
        
        if closeTagRange.length == 0 {
            return false
        }
        
        let range = NSRange(location:openTagRange.location, length:closeTagRange.location - openTagRange.location + 1)
        let tag = self.substring(with: range) as NSString
        self.replaceCharacters(in: range, with: "")
        let isEndTag = tag.range(of: "</").length == 2
        if isEndTag {
            let openTag = tag.replacingOccurrences(of: "</", with: "<")
            let count = array.count
            for i in count - 1 ... 0 {
                let dict = array[i] as! NSDictionary
                let dtag = dict["loc"] as! String
                if (dtag.isEqual(openTag)) {
                    let loc = dict["loc"] as! Int
                    
                    if loc < range.location {
                        array.removeObject(at: i)
                        let strippedTag = (openTag as NSString).substring(with: NSRange(location: 1, length: (openTag as NSString).length - 2))
                        array.add(["loc":loc,"tag":strippedTag,"endloc":range.location])
                    }
                    break
                }
                
            }
            
        }else{
            array.add(["loc":range.location,"tag":tag])
        }
        
        return true;
    }
    public func replaceAllTagsIntoArray(array:NSMutableArray){
    
        while self.replaceFirstTagToArray(array: array) {
            
        }
    }
}

  let kWPAttributedMarkupLinkName = "WPAttributedMarkupLinkName"

  let kWPAttributedSendUrlFromeText = "WPAttributedSendUrlFromeText"


extension String{
    
    public func attributedStringWithStyleBook(fontbook:NSDictionary) -> NSAttributedString {
        let tags = NSMutableArray()
        let mString:NSMutableString = (self as NSString).mutableCopy() as! NSMutableString
        
        mString.replacingOccurrences(of: "<br>", with: "\n", options: .caseInsensitive, range: NSRange(location:0,length:mString.length))
        mString.replacingOccurrences(of: "<br />", with: "\n", options: .caseInsensitive, range: NSRange(location:0,length:mString.length))
        mString.replaceAllTagsIntoArray(array: tags)
        let attributedString = NSMutableAttributedString(string: mString as String)
        attributedString.setAttributes([NSUnderlineStyleAttributeName:NSNumber(value:0)], range: NSRange(location:0,length:attributedString.length))
        let bodySty = fontbook["body"]
        if let bodySty = bodySty as? NSObject {
            self.styleAttributedString(attributeString: attributedString, range: NSRange(location:0,length:attributedString.length), style: bodySty, styleBook: fontbook)
        }
        tags.forEach { (tag) in
            if let tag = tag as? NSDictionary{
                let t = tag["tag"]
                let loc = tag["loc"]
                let endLoc = tag["endloc"]
                if let loc = loc as? NSNumber {
                    if let endLoc = endLoc as? NSNumber{
                    
                        let range = NSRange(location:loc.intValue,length:endLoc.intValue - loc.intValue)
                        let style = fontbook[t!]
                        if let style = style as? NSObject{
                        self.styleAttributedString(attributeString: attributedString, range: range, style: style, styleBook: fontbook)
                        }
                    }
                }
            }
        }
        return attributedString
    }
    
    //MARK:获取文本中的URL
    func attributedWithStyleBook() -> NSAttributedString {
        let mStr = (self as NSString).mutableCopy()
        let attributeString = NSMutableAttributedString(string:mStr as! String)
        do {
            let regulaStr = "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
            let regex = try NSRegularExpression(pattern: regulaStr, options:.caseInsensitive)
            let arrayOfAllMatches = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location:0,length:(self as NSString).length))
            arrayOfAllMatches.forEach({ (match) in
                let subStringForMatch = (self as NSString).substring(with: match.range)
                let styleDic = ["body":UIFont(name:"HelveticaNeue",size:20.0)!,
                                subStringForMatch:WPAttributedStyleAction.styledActionWithAction {
                                    NotificationCenter.default.post(name:NSNotification.Name(rawValue: "sendInfoToVC"), object: subStringForMatch, userInfo: nil)
                    },
                                "link":UIColor.orange
                ] as [String : Any]
                let bodyStyle = styleDic["body"]
                if let bodyStyle = bodyStyle as? NSObject{
                    self.styleAttributedString(attributeString: attributeString, range: NSRange(location: 0, length: attributeString.length), style: bodyStyle, styleBook: styleDic as NSDictionary)
                }
                
                if let style = styleDic[subStringForMatch] as? NSObject{
                    self.styleAttributedString(attributeString: attributeString, range: match.range, style: style, styleBook: styleDic as NSDictionary)
                }
            })
        } catch  {
            
        }
        return attributeString;
    }
    

    private func styleAttributedString(attributeString:NSMutableAttributedString, range:NSRange, style:NSObject, styleBook:NSDictionary) {
        
        if let style = style as? NSArray {
            style.forEach({ (subStyle) in
                self.styleAttributedString(attributeString: attributeString, range: range, style: subStyle as! NSObject, styleBook: styleBook)
            })
        }else if let style = style as? NSDictionary {
            self.setStyleAndRangeAndAttributeString(style: style, range: range, attributeString: attributeString)
        }else if let style = style as? UIFont{
            self.setFontAndRangeAndAttributeString(font: style, range: range, attributeString: attributeString)
        }else if let style = style as? UIColor{
            self.setTextColorAndRangeAndAttributeString(color: style, range: range, attributeString: attributeString)
        }else if let style = style as? NSString{
            self.styleAttributedString(attributeString: attributeString, range: range, style: styleBook[style] as! NSObject , styleBook: styleBook)
        }else if let style = style as? NSURL{
            self.setLinkAndRangeAndAttributeString(url: style, range: range, attributeString: attributeString)
        }else if let style = style as? UIImage{
            print(style)
        }
    }
    
    private func setStyleAndRangeAndAttributeString(style:NSDictionary, range:NSRange, attributeString:NSMutableAttributedString) {
        style.allKeys.forEach { (element) in
            self.setTextStyleAndValueAndRangeAndAttributeString(styleName: element as! String, value: style[element] as! NSObject, range: range, attributeString: attributeString)
        }
    }
    private func setFontAndRangeAndAttributeString(font:UIFont, range:NSRange, attributeString:NSMutableAttributedString) {
        self.setFontNameAndSizeAndRangeAndAttributeString(fontName: font.fontName, size: font.pointSize, range: range, attributeString: attributeString)
    }
    private func setFontNameAndSizeAndRangeAndAttributeString(fontName:String, size:CGFloat, range:NSRange, attributeString:NSMutableAttributedString) {
        let aFont:CTFont? = CTFontCreateWithName(fontName as CFString?, size, nil)
        if (aFont != nil) {
            attributeString.removeAttribute(kCTFontAttributeName as String, range: range);
            attributeString.addAttribute(kCTFontAttributeName as String, value: aFont!, range: range)
        }
    }

    private func setTextColorAndRangeAndAttributeString(color:UIColor, range:NSRange, attributeString:NSMutableAttributedString) {
        attributeString.removeAttribute(NSForegroundColorAttributeName, range: range)
        attributeString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
    }
    private func setTextStyleAndValueAndRangeAndAttributeString(styleName:String, value:NSObject, range:NSRange, attributeString:NSMutableAttributedString) {
        attributeString.removeAttribute(styleName, range: range)
        attributeString.addAttribute(styleName, value: value, range: range)
    }
    private func setLinkAndRangeAndAttributeString(url:NSURL, range:NSRange, attributeString:NSMutableAttributedString) {
        attributeString.removeAttribute(kWPAttributedMarkupLinkName, range: range)
        attributeString.addAttribute(kWPAttributedMarkupLinkName, value: url.absoluteString!, range: range)
    }
    
}








