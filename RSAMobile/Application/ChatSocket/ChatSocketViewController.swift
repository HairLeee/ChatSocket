//
//  ChatSocketViewController.swift
//  RSAMobile
//
//  Created by Tcsytems on 11/27/18.
//  Copyright © 2018 TCSVN. All rights reserved.
//

import UIKit
//import FontAwesome_swift


class ChatSocketViewController: UIViewController {

    @IBOutlet weak var tfChatContent: UITextField!
    @IBOutlet weak var imgButtonCamera: UIImageView!
    @IBOutlet weak var imgButtonSend: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SocketIOManager.sharedInstance.connection()

        
        NotificationCenter.default.addObserver(forName: Notification.Name("sendMessage"), object: nil, queue: nil, using: updateUser)
        
    }
    
    func updateUser(_ notification: Notification) {
        DispatchQueue.main.async {
           print("HAhahahaa")
        }
    }
    

    @IBAction func btnSendClicked(_ sender: Any) {
        print("Kakaka")
        SocketIOManager.sharedInstance.sendMessage(roomId: "roomId!", sendId: "sendId!", reciveId: "reciveId!", content: "self.tfMessage.text!", type: "1")
    }
    
    @IBAction func btnCameraClicked(_ sender: Any) {
        
    }
}
