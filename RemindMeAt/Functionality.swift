//
//  File.swift
//  RemindMeAt
//
//  Created by David on 2/19/18.
//  Changed by Artem Rieznikov on 2/21/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    struct Maps {
        static var circleFill: UIColor  { return UIColor(red:0.85, green:0.95, blue:0.86, alpha:0.7) }
        static var circleStroke: UIColor { return UIColor(red:0.59, green:0.59, blue:0.59, alpha:0.7) }
        static var addLocationButton : UIColor { return UIColor(red:0.57, green:0.74, blue:0.98, alpha:0.84) }
    }
    
    struct Screens {
        static var tabBarTintColor : UIColor { return UIColor(red:0.99, green:0.56, blue:0.09, alpha:1.0) }
        static var navigationBarTintColor : UIColor { return UIColor(red:0.83, green:0.83, blue:0.82, alpha:1.0) } // UIColor(red: 20.0/255.0, green:20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        static var searchBarTintColor : UIColor { return UIColor(red:0.83, green:0.83, blue:0.82, alpha:1.0) } // UIColor(red: 20.0/255.0, green:20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        static var searchBarBackgroundColor : UIColor { return UIColor(red:0.83, green:0.83, blue:0.82, alpha:1.0) } // UIColor.gray
    }
    
    /** Hex string of a UIColor instance, fails to empty string. */
    public func hexString() -> String  {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        guard r >= 0 && r <= 1 && g >= 0 && g <= 1 && b >= 0 && b <= 1 else {
            return ""
        }
        
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    /**
     The UIColor from Hex string, fails to UIColor.clear
     - parameter hexString: representation of color in String HEX form #RRGGBB
     */
    public static func fromHexString(_ hexString: String) -> UIColor {
        var result = UIColor.clear
        guard hexString.hasPrefix("#") else {
            return result
        }
        
        let hexString: String = String(hexString[String.Index.init(encodedOffset: 1)...])
        var hexValue:  UInt32 = 0
        
        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            return result
        }
        
        let divisor = CGFloat(255)
        let red     = CGFloat((hexValue & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hexValue & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hexValue & 0x0000FF       ) / divisor
        result = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        return result
    }
    
}

extension Double {
    mutating func roundTo(_ places: Int) {
        let multiplier = pow(10, Double(places))
        self = Darwin.round(self * multiplier) / multiplier
    }
    
}

