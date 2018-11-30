//
//  ProviderTopViewCell.swift
//  RSAMobile
//
//  Created by Nguyen Van Trung on 5/5/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class ProviderTopViewCell: UITableViewCell {

    @IBOutlet weak var status: UIView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var providerPrice: UILabel!
    //@IBOutlet weak var parentFee: UILabel!
//    @IBOutlet weak var childName: UILabel!
    //@IBOutlet weak var childFee: UILabel!
   // @IBOutlet weak var adjFee: UILabel!
    //@IBOutlet weak var adj: UILabel!
   // @IBOutlet weak var fee: UILabel!
   // @IBOutlet weak var total: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        status.layer.cornerRadius = status.frame.size.width / 2
        status.clipsToBounds = true
//        childName.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
