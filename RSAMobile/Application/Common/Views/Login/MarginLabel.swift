//
//  MarginLabel.swift
//  RSAMobile
//
//  Created by LinhTY on 4/19/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import Foundation


class MarginLabel : UILabel {
    var margin = UIEdgeInsets(top: 2.0, left: 5.0, bottom: 2.0, right: 2.0) {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    var bgColor : UIColor = UIColor.clear {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var backgroundColor: UIColor? {
        set {
            if newValue != nil { self.bgColor = newValue! }
        }
        get {
            return UIColor.clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.numberOfLines = 0
        self.sizeToFit()
    }
    
    override func drawText(in rect: CGRect) {
        // Draw the background if have
        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: self.layer.cornerRadius)
        path.addClip()
        self.bgColor.set()
        //path.fill()
        context?.fill(rect)
        
        super.drawText(in: UIEdgeInsetsInsetRect(rect, margin))
    }
    
    // Override -intrinsicContentSize: for Auto layout code
    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + margin.left + margin.right
        let heigth = superContentSize.height + margin.top + margin.bottom
        return CGSize(width: width, height: heigth)
    }
    
    // Override -sizeThatFits: for Springs & Struts code
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let width = superSizeThatFits.width + margin.left + margin.right
        let heigth = superSizeThatFits.height + margin.top + margin.bottom
        return CGSize(width: width, height: heigth)
    }
    
}
