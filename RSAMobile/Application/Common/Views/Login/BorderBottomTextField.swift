//
//  BorderBottomTextField.swift
//  TCMapProj
//
//  Created by Trần Thị Yến Linh on 7/20/16.
//  Copyright © 2016 TCSystems. All rights reserved.
//

import Foundation
enum HighLightTextField {
    case HighLightBorder
    case HighLightPadding
}
class BorderBottomTextField : UITextField {
    let bottomLineView : UIView = UIView.init(frame: CGRect.zero)
    var autoAdjustWidth : Bool = false
    var highLightType: HighLightTextField = HighLightTextField.HighLightBorder
    var constantBottomConstraint: Double? {
        get {
            switch self.highLightType {
            case .HighLightPadding:
                return 10.0
            case .HighLightBorder:
                return 0.0
            }
        }
        set {
            switch self.highLightType {
            case .HighLightPadding:
                self.constantBottomConstraint = 10.0
                break
            case .HighLightBorder:
                self.constantBottomConstraint = 0.0
            }
        }
    }

    var bottomLineColor : UIColor = UIColor.white {
        didSet {
            bottomLineView.backgroundColor = bottomLineColor
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        addBottomLine()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        addBottomLine()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.borderStyle = .none
    }
    
    var padding :UIEdgeInsets?  {
        get {
            if self.highLightType == .HighLightPadding {
                return UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 5)
            }else {
                return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            }
        }
        set {
            switch self.highLightType {
            case .HighLightPadding:
                self.padding = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 5)
                break
            case .HighLightBorder:
                self.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            }
        }
    }
    func setPaddingForTextFeild() -> Void {
        switch self.highLightType {
        case .HighLightPadding:
            self.padding = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 5)
            break
        case .HighLightBorder:
            self.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, self.padding!)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, self.padding!)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, self.padding!)
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
            constant: CGFloat(self.constantBottomConstraint!)
            )
        )
        self.setNeedsUpdateConstraints()
        self.updateConstraints()

    }
    
}
