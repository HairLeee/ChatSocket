//
//  ButtonView.swift
//  RSAMobile
//
//  Created by tanchong on 4/19/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

protocol ButtonDelegate {
    func chooseService(buttonView: ButtonView)
}
class ButtonView: UIView {

    var delegate: ButtonDelegate!
    var caseType: CaseTypeObject!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonView: UIButton!
    
    
    @IBAction func tapedButton(_ sender: Any) {
        delegate?.chooseService(buttonView: self)
        //buttonView.backgroundColor = UIColor.lightGray
    }
    
    func viewSetting() {
        buttonView.setTitle(caseType.getName(), for: .normal)
        (URLSession(configuration: URLSessionConfiguration.default)).dataTask(with: URL(string: URLBase + caseType.getIcon()!)!, completionHandler: { (imageData, response, error) in
            if let data = imageData {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data:data)
                }
            }
        }).resume()
    }
    
    func getCaseType()-> CaseTypeObject {
        return caseType
    }
    
    func getImage()->UIImage {
        return imageView.image!
    }
}
