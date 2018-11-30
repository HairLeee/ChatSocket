//
//  PaddingTextFiled.swift
//  RSAMobile
//
//  Created by tanchong on 3/31/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class PaddingTextFiled: UITextField {

    var bottomLineColor : UIColor = UIColor.white {
        didSet {
            bottomLineView.backgroundColor = bottomLineColor
        }
    }
    let padding = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 5)
    let bottomLineView : UIView = UIView()
    var autoAdjustWidth : Bool = false
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        addBottomLine()
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addBottomLine()
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.borderStyle = .none
        addBottomLine()
    }
    
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    func addBottomLine () {
        
        self.bottomLineView.backgroundColor = bottomLineColor
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(self.bottomLineView)
        
        self.bottomLineView.addConstraint(NSLayoutConstraint(
            item: self.bottomLineView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: 1
            )
        )
        
        addConstraint(NSLayoutConstraint(
            item: self.bottomLineView,
            attribute: .left,
            relatedBy: .equal,
            toItem: self,
            attribute: .left,
            multiplier: 1,
            constant: 0
            )
        )
        
        addConstraint(NSLayoutConstraint(
            item: self.bottomLineView,
            attribute: .right,
            relatedBy: .equal,
            toItem: self,
            attribute: .right,
            multiplier: 1,
            constant: 0
            )
        )
        
        addConstraint(NSLayoutConstraint(
            item: self.bottomLineView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 10
            )
        )
        
        
    }


}
