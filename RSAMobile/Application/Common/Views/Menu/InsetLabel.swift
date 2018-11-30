//
//  InsetLabel.swift
//  RSAMobile
//
//  Created by Nguyen Van Trung on 5/5/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {

    let topInset = CGFloat(2)
    let bottomInset = CGFloat(2)
    let leftInset = CGFloat(2)
    let rightInset = CGFloat(2)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }

}
