//
//  UIGradientView.swift
//  Translator
//
//  Created by IVAN CHERNOV on 13/09/15.
//  Copyright (c) 2015 IVAN CHERNOV. All rights reserved.
//

import UIKit

class UIGradientView: UIView {
    
    var startColor: CGColor?
    var endColor: CGColor?
    var image: UIImage?
    
    func setGradientColors(c1: UIColor, c2: UIColor) {
        self.startColor = c1.CGColor
        self.endColor = c2.CGColor
        self.setNeedsDisplay()
    }
    func setBackgroundImage(backgroundImage: UIImage) {
        self.image = backgroundImage
        self.setNeedsDisplay()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        if(self.startColor != nil && self.endColor != nil) {
            var colorSpace = CGColorSpaceCreateDeviceRGB();
            var locations = [ CGFloat(0.0), CGFloat(1.0) ];
            var colors: CFArray = [self.startColor!, self.endColor!]
            //NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
            var gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
            var startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
            var endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
            
            var context: CGContextRef = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            CGContextAddRect(context, rect);
            CGContextClip(context);
            CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
            CGContextRestoreGState(context);
        }
        
        if(self.image != nil) {
            image!.drawInRect(self.frame)
        }
    }
    

}
