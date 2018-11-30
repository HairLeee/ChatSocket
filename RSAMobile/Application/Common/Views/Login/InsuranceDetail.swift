//
//  InsuranceDetail.swift
//  RSAMobile
//
//  Created by tanchong on 4/17/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class InsuranceDetail: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var noDataText: UILabel!
    var isHidenNoView = true;
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var carNo: UILabel!
    @IBOutlet weak var coverageTitle: UILabel!
    @IBOutlet weak var expiryTitle: UILabel!
    @IBOutlet weak var makeTile: UILabel!
    @IBOutlet weak var modelTitle: UILabel!
    @IBOutlet weak var yearMakeTitle: UILabel!
    @IBOutlet weak var carNoContent: UILabel!
    @IBOutlet weak var coverageContent: UILabel!
    @IBOutlet weak var expiryContent: UILabel!
    @IBOutlet weak var makeContent: UILabel!
    @IBOutlet weak var modelContent: UILabel!
    @IBOutlet weak var yearContent: UILabel!
    @IBOutlet weak var noView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var review: UILabel!
    
    var colorBackgroud:UIColor = UIColor.green {
        didSet {
            colorView.backgroundColor = colorBackgroud
        }
    }
    
    func viewSetting() {
        //contentView.layer.shadowColor = UIColor.black.cgColor
        //contentView.layer.shadowOffset = CGSize.zero
        //contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowRadius = 0.5
        contentView.layer.cornerRadius = 5.0
        review.isHidden = true
        //contentView.layer.borderWidth = 0.5
        //contentView.layer.borderColor = UIColor.white.cgColor
        colorView.layer.cornerRadius = 5.0
        noView.isHidden = isHidenNoView
        contentView.isHidden = !isHidenNoView
    }
    
    func setNodataView() {
//        noView.layer.shadowColor = UIColor.black.cgColor
//        noView.layer.shadowOffset = CGSize.zero
//        noView.layer.shadowOpacity = 0.5
        noView.layer.shadowRadius = 3.0
        noView.layer.cornerRadius = 5.0
        noView.layer.borderWidth = 1.0
        noView.layer.borderColor = UIColor.white.cgColor
        noView.isHidden = isHidenNoView
        contentView.isHidden = !isHidenNoView
    }
    
    
    
}
