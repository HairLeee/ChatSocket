//
//  LeftChatViewCell.swift
//  ChatCustomer
//
//  Created by Fullname on 11/30/18.
//  Copyright © 2018 Fullname. All rights reserved.
//

import UIKit

class LeftChatViewCell: UITableViewCell {


    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 5.0
    @IBInspectable var rightInset: CGFloat = 5.0
    
    @IBOutlet var imvLeftAvatar: UIImageView!
    @IBOutlet var view: UIView!
    @IBOutlet weak var lbMessage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        lbMessage.layer.cornerRadius = 8
        lbMessage.layer.masksToBounds = true
        lbMessage.backgroundColor = .grayBlue
      
        lbMessage.numberOfLines = 0;
        lbMessage.adjustsFontSizeToFitWidth = true
        
        imvLeftAvatar.layer.cornerRadius = 16
        imvLeftAvatar.layer.masksToBounds = true
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
