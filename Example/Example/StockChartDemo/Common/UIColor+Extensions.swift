//
//  UIColor+Extensions.swift
//  SafetyBoot
//
//  Created by Jacob Sikorski on 2017-03-23.
//  Copyright © 2017 Tamarai. All rights reserved.
//

import Foundation

import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xff)
        let green = CGFloat((hex >> 8) & 0xff)
        let blue = CGFloat(hex & 0xff)
        
        self.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    convenience init?(hexString: String) {
        var cString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return nil
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    func lighter(by percentage:CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat = 30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)) {
            let red = min(r + percentage/100, 1.0)
            let green = min(g + percentage/100, 1.0)
            let blue = min(b + percentage/100, 1.0)
            
            return UIColor(red: red, green: green, blue: blue, alpha: a)
        } else {
            return nil
        }
    }
}
