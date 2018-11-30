//
//  ServiceDetail.swift
//  RSAMobile
//
//  Created by Nguyen Van Trung on 5/9/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class ServiceDetail: UIView, UITextViewDelegate {

    @IBOutlet weak var parentServiceName: UILabel!
    @IBOutlet weak var parentServiceFee: UILabel!
    
    @IBOutlet weak var childServiceName: UILabel!
    @IBOutlet weak var childServiceFee: UILabel!

    @IBOutlet weak var AdjName: UILabel!
    @IBOutlet weak var adjFee: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var noteTextView: UITextView!
    
    var delegate: ServiceDelegate?
    
    
    func setupView() {
        noteTextView.delegate = self
        noteTextView.layer.cornerRadius = 5.0
        noteTextView.layer.borderWidth = 1.0
        
        noteTextView.layer.borderColor = UIColor.init(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0).cgColor
        
        cancelButton.layer.cornerRadius = 25.0
    }
    @IBAction func tapedCancel(_ sender: Any) {
        guard delegate != nil else {
            return
        }
        
        delegate?.cancelService()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textDidEditTing()
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textDidEndEditing()
    }
    
    
   
}

public protocol ServiceDelegate {
    func cancelService()
    func textDidEditTing()
    func textDidEndEditing()
}
