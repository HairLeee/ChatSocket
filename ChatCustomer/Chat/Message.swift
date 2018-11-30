//
//  Message.swift
//  ChatCustomer
//
//  Created by Fullname on 11/30/18.
//  Copyright © 2018 Fullname. All rights reserved.
//

import UIKit

enum MessageType {
    case text
    case image
    case icon
}

class Message : NSObject {

    var receiveId:String = ""
    var sendId:String = ""
    var roomId:String = ""
    var content:String = ""
    var type:MessageType
    var date: Date
    
    init(receiveId:String,sendId:String,roomId:String,content:String, type: MessageType,date: Date) {
        self.receiveId = receiveId
        self.sendId = sendId
        self.roomId = roomId
        self.content = content
        self.type = type
        self.date = date
    }
    

}
