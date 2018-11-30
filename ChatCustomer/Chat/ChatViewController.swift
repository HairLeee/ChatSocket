//
//  ChatViewController.swift
//  ChatCustomer
//
//  Created by Fullname on 11/30/18.
//  Copyright © 2018 Fullname. All rights reserved.
//

import UIKit
//import ReverseExtension

class ChatViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate
{
   
    

   
    @IBOutlet weak var tvChat: UITextView!
    @IBOutlet weak var tableView: UITableView!
    var messages = [Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup messages table view
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.re.delegate = self

        tableView.register(UINib(nibName: "RightChatViewCell", bundle: nil), forCellReuseIdentifier: "RightChatViewCell")
        tableView.register(UINib(nibName: "LeftChatViewCell", bundle: nil), forCellReuseIdentifier: "LeftChatViewCell")
        
        tableView.estimatedRowHeight = 56
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = .clear
        
        let gestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hide))
        self.view.addGestureRecognizer(gestureRecognizer)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @objc func hide() {
        self.tvChat?.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        self.isMenuHidden = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        let size: CGSize = textView.sizeThatFits(textView.bounds.size)
//        if let constraint: NSLayoutConstraint = self.constraint {
//            tvChat.removeConstraint(constraint)
//        }
//        self.constraint = textView.heightAnchor.constraint(equalToConstant: size.height)
//        self.constraint?.priority = UILayoutPriority.defaultHigh
//        self.constraint?.isActive = true
    }
    
    @IBAction func btnEnterChat(_ sender: Any) {
        
        if tvChat.text == "" {
            return
        }
        
        let message = Message(receiveId: "2", sendId: "1", roomId: "22", content: self.tvChat.text!, type: .text, date: Date())
        
        sendMessage(message)
    }
    
    func sendMessage(_ message: Message) {
        messages.append(message)
        tableView.beginUpdates()
//        tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .automatic)
          tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[messages.count - (indexPath.row + 1)]
        
        if message.sendId == "1" {
            //Right
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightChatViewCell", for: indexPath) as! RightChatViewCell
            cell.configure(with: message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeftChatViewCell", for: indexPath) as! LeftChatViewCell
            cell.configure(with: message)
            return cell
            
        } 
    }


}
