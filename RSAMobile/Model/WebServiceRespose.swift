//
//  WebServiceRespose.swift
//  RSAMobile
//
//  Created by tanchong on 3/29/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class WebServiceRespose: NSObject {
    var statusCode:Int?
    var contentLength:Int?
    var response:Data?
    var error:NSError?
    var totalDownloadFailImage:Int?
    let statusCodeOk = 200
    let statusCodeNotFound = 404
    let statusCodeUnauthorized = 401
    let statusCodeServerError = 500
    let statusCodeNotAcceptable = 406
    let statusCodeCreated = 201
    
    lazy var dictData : NSDictionary? = {
        return self.getResponseDataDict()
    }()
    
    lazy var arrayData : [[String: AnyObject]]? = {
        return self.getResponseDataArray()
    }()
    
    
    init(statusCode:Int?,contentLength:Int?,response:Data?, error: NSError?) {
        super.init()
        self.statusCode = statusCode
        self.contentLength = contentLength
        self.response = response
    }
    
    func getResponseDataArray () -> [[String: AnyObject]]? {
        if let data = self.response {
            do {
                if let json: AnyObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject?{
                    return json as? [[String: AnyObject]]
                }
            } catch let error as NSError {
//                print(error)
                return nil
            }
        }
        
        return nil
    }
    
    func getResponseDataDict () -> NSDictionary? {
        if let data = self.response {
            do {
                if let json : AnyObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject? {
                    return json as? NSDictionary
                }
            } catch let error as NSError {
//                print(error)
                return nil
            }
        }
        
        return nil
    }
    
    func isSuccess () -> Bool {
        if let dict = self.dictData {
            if let result = dict["result"] as? String {
                if result.lowercased() == "success" {
                    if let code = self.statusCode {
                        return (code == statusCodeOk)
                    }
                } else {
                    if self.statusCode == statusCodeOk {
                        self.statusCode = statusCodeServerError
                    }
                }
            } else {
                if let code = self.statusCode {
                    if self.response != nil
                    {
                        let datastring = NSString(data: self.response!, encoding: String.Encoding.utf8.rawValue)
                        if ((datastring!.contains("Minimum apk version")) == true)
                        {
                            return false
                        }
                        
                    }
                    return (code == statusCodeOk)
                }
            }
        }
        else {  // Check for case that response is not a dict
            if let code = self.statusCode {
                return (code == statusCodeOk)
            }
        }
        
        return false
    }
    
    func getResponseMessage () -> String? {
        if let dict = self.dictData {
            return (dict["body"] as? [String: AnyObject])?["message"] as? String
        }
        
        return nil
    }
    
    func getResponseCode () -> String? {
        if let dict = self.dictData {
            return (dict["body"] as? [String: AnyObject])?["error"] as? String
        }
        
        return nil
    }
    
    func isDenied () -> Bool {
        if let msg = self.getResponseMessage() {
            if msg.lowercased() == "access denied!" {
                return true
            }
        }
        
        return false
    }

}
