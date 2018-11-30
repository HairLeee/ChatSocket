//
//  SocketIOManager.swift
//  RSAMobile
//
//  Created by Tcsytems on 11/27/18.
//  Copyright © 2018 TCSVN. All rights reserved.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
   // for swift 4
//    var manager = SocketManager(socketURL: URL(string: "http://10.1.5.91:6789")!)
    //    var manager = SocketManager(socketURL: URL(string: "http://35.187.243.177:6789")!)
//    lazy var socket = manager.defaultSocket
    
    
    //for swift3
    lazy var socket = SocketIOClient(socketURL: URL(string: "http://10.1.5.161:6789")!)
    static var socketId: String = ""
    static var listUser = [[String:Any]]()
    static var listMessage = [[String:Any]]()
    
    
    override init() {
        super.init()
        socket.on("sendsocketid") { ( dataArray, ack) -> Void in
            let strSocketId = dataArray[0] as! String
            SocketIOManager.socketId = strSocketId
            SocketIOManager.listUser = dataArray[1] as! [[String:Any]]
        }
        
        socket.on("updateUser") { (dataArray, socketAck) -> Void in
            SocketIOManager.listUser = dataArray[0] as! [[String:Any]]
            NotificationCenter.default.post(name: Notification.Name("UpdateUser"), object: nil)
        }
        
        socket.on("getListMessage") { (dataArray, socketAck) -> Void in
            let stringData = dataArray[0] as! String
            let data = stringData.data(using: .utf8)!
            let jsonArray = try! JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [[String:Any]]
            SocketIOManager.listMessage = jsonArray!
            NotificationCenter.default.post(name: Notification.Name("GETLISTMESSAGE"), object: nil)
        }
        
        socket.on("sendMessage") { (dataArray, socketAck) -> Void in
            
//            let stringData = dataArray[0] as! String
//            let data = stringData.data(using: .utf8)!
//            let jsonArray = try! JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:Any]
//
//            SocketIOManager.listMessage.append(jsonArray!)
            NotificationCenter.default.post(name: Notification.Name("sendMessage"), object: nil)
        }
        
        
        socket.on("disconnect") { (dataArray, socketAck) -> Void in
            print("--------------")
        }
    }
    
    //Date to milliseconds
    func currentTimeInMiliseconds() -> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    func connection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    
    
    func connectToServerWithNickname(userId: String, userName: String, socketId: String) {
        let dicData = ["userId" : userId,"userName" : userName,"socketId" : socketId]
        socket.emit("insertConnection", dicData)
    }
    
    func sendMessage(roomId: String, sendId: String, reciveId: String, content: String, type: String) {
        let dicData = ["roomId" : roomId, "sendId" : sendId,"reciveId" : reciveId,"content" : content, "type":type]
        socket.emit("sendMessage", dicData)
    }
    
    func getListMessage(roomId: String) {
        let dicData = ["roomId" : roomId]
        socket.emit("getListMessage", dicData)
    }
    
}
