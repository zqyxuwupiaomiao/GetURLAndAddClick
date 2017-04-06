//
//  ZQYTapLabbel.swift
//  GetURLAndAddClick
//
//  Created by zqy on 2017/3/20.
//  Copyright © 2017年 zqy. All rights reserved.
//

import UIKit

class ZQYTapLabbel: UILabel {
    typealias tapOnLabel = (CGPoint) -> ()
    var block : tapOnLabel?
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override init(frame: CGRect) {
         super.init(frame: frame)

        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapped))
        self.addGestureRecognizer(tapGesture)
        
        addClickHandler()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapped))
        self.addGestureRecognizer(tapGesture)
        
        addClickHandler()
    }
    
    func addClickHandler() {
        self.block = { [weak self] (pt) in
            let attributes = self?.textAttributesAtPoint(pt)
            let actionStyle = attributes?["WPAttributedStyleAction"] as? WPAttributedStyleAction
            if actionStyle != nil {
                actionStyle?.action!()
            }
        }
    }
    func textAttributesAtPoint(_ point:CGPoint) -> NSDictionary {
        var pt = point
        
        var dictionary = NSDictionary()
        
        //创建coreText framestter
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText!)
        
        let framePath = CGMutablePath()
        
        framePath.addRect(CGRect(x: 0,y: 0,width: self.bounds.size.width,height: self.bounds.size.height))
        let currentRange = CFRangeMake(0, 0)
        let frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, nil)
        let linesCount = CFArrayGetCount(CTFrameGetLines(frameRef))
        var lineOrigins = [CGPoint](repeating: CGPoint(x:0,y:0), count:linesCount)

        CTFrameGetLineOrigins(frameRef, CFRangeMake(0, linesCount), &lineOrigins)
        
        var line:CTLine
        var lineOrigin = CGPoint(x: 0,y: 0)
        var bottom = self.frame.size.height
        
        for  i  in 0...linesCount - 1 {
            lineOrigins[i].y = self.frame.size.height - lineOrigins[i].y
            bottom = lineOrigins[i].y
        }
        pt.y -= (self.frame.size.height - bottom)/2

        for i  in 0...linesCount - 1 {
            line = unsafeBitCast(CFArrayGetValueAtIndex(CTFrameGetLines(frameRef), i),to: CTLine.self)
            lineOrigin = lineOrigins[i]
            var descent:CGFloat = 0.0
            var ascent:CGFloat = 0.0
            let width = CTLineGetTypographicBounds(line, &ascent, &descent, nil)
            
            if(pt.y < (floor(lineOrigin.y) + floor(descent))) {
                
                if (self.textAlignment == .center) {
                    pt.x -= CGFloat((Float(self.bounds.size.width) - Float(width)) / Float(2.0))
                } else if (self.textAlignment == .right) {
                    pt.x -= CGFloat(Float(self.bounds.size.width) - Float(width))
                }
                
                pt.x -= lineOrigin.x
                pt.y -= lineOrigin.y
                
                let i = CTLineGetStringIndexForPosition(line, pt)
                
                let glyphRuns = CTLineGetGlyphRuns(line)
                let runCount = CFArrayGetCount(glyphRuns)
                for  run in 0...runCount - 1 {
                    let glyphRun = unsafeBitCast(CFArrayGetValueAtIndex(glyphRuns,run),to: CTRun.self)

                    let range = CTRunGetStringRange(glyphRun)
                    if (i >= range.location && i <= range.location+range.length) {
                        dictionary = CTRunGetAttributes(glyphRun)
                        break
                    }
                }
                if (dictionary.count > 0) {
                    break
                }
            }
        }
        return dictionary
    }
    func tapped(gesture:UITapGestureRecognizer){
        
        if (gesture.state == .recognized) {
            let pt:CGPoint = gesture.location(in: self);
            if ((self.block) != nil) {
                self.block!(pt)
            }
        }
    }

}
