//
//  IBDesignables.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 4/19/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit

@IBDesignable
class ButtonWithBorder : UIButton {
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            setBorderWidth()
        }
    }
    
    @IBInspectable var borderColor : UIColor? {
        didSet {
            setBorderColor()
        }
    }
    
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            setCornerRadius()
        }
    }
    
    func setBorderWidth() {
        layer.borderWidth = borderWidth
    }
    
    func setBorderColor() {
        layer.borderColor = borderColor?.cgColor
    }
    
    func setCornerRadius() {
        layer.cornerRadius = cornerRadius
    }
    
    func selectButton() {
        self.backgroundColor = UIColor.flatWhite()!.withAlphaComponent(1)
        self.setTitleColor(UIColor.black, for: .normal)
        self.layer.borderColor = (UIColor(hexString: "E1E1E1")!.withAlphaComponent(0.7)).cgColor
        self.titleLabel!.font = .systemFont(ofSize: 10, weight: .semibold)
    }
    
    func deselectButton() {
        self.backgroundColor = UIColor.clear
        self.setTitleColor(UIColor(hexString: "E1E1E1"), for: .normal)
        self.layer.borderColor = UIColor(hexString: "E1E1E1")!.cgColor
        self.titleLabel!.font = .systemFont(ofSize: 10, weight: .regular)
    }
}
