//
//  extensions.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 3/30/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit

// returns true if color is light, false if it is dark
extension UIColor {
    func isLight() -> Bool {
        let components = self.cgColor.components!
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000

        if brightness < 0.5 {
            return false
        } else {
            return true
        }
    }
}

extension UIImage {
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func imageWithSize(_ size: CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth : CGFloat = size.width / self.size.width
        let aspectHeight : CGFloat = size.height / self.size.height
        let aspectRatio : CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
