//
//  LeftMenuTableViewCell.swift
//  RSAMobile
//
//  Created by LinhTY on 4/19/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import Foundation


class LeftMenuTableViewCell : UITableViewCell {
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var markLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.markLabel?.layer.cornerRadius = 2
        self.markLabel?.isHidden = true
    }
    
    func displayMarkLabel(content: String) -> Void {
        self.markLabel?.text = content

        self.markLabel?.isHidden = false
        self.markLabel.backgroundColor = .red
    }
}

class InforLeftMenuTableViewCell : UITableViewCell {
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var emailLabel : UILabel!
    @IBOutlet weak var avatarView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarView.makeRoundBorder(borderWidth: UIParameter.AvatarBorderWidth)
    }

}
