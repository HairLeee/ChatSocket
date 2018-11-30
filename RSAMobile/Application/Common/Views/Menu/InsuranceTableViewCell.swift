//
//  InsuranceTableViewCell.swift
//  RSAMobile
//
//  Created by tanchong on 4/13/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class InsuranceTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var buttonDown: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
