//
//  RightChatViewCell.swift
//  ChatCustomer
//
//  Created by Fullname on 11/30/18.
//  Copyright © 2018 Fullname. All rights reserved.
//

import UIKit

class RightChatViewCell: UITableViewCell {


    @IBOutlet weak var lbMessage: PaddingLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        lbMessage.layer.cornerRadius = 8
        lbMessage.layer.masksToBounds = true
        lbMessage.backgroundColor = UIColor.init(hexString: "BEDBFF")
        
        lbMessage.numberOfLines = 0;
        lbMessage.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with message: Message) {
        switch message.type {
        case MessageType.text:
            lbMessage.text = message.content
            
            break
        default:
            break
        }
    }
    
}
