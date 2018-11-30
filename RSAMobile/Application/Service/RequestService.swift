//
//  RequestService.swift
//  RSAMobile
//
//  Created by tanchong on 3/29/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

enum EComServicesError: Int {
    case eComServicesErrorA = 0
}


class RequestService: NSObject, NSURLConnectionDataDelegate {
    static let shareInstance: RequestService = {
        let instance = RequestService()
        return instance
    }()
    
    var token: String!
    var session:URLSession?
    let user = UserHelper();
    let imageCache = NSCache<NSString, AnyObject>()
    let operationQueue = OperationQueue()
    var dictTasks = [String : URLSessionDataTask]()
    
    override init() {
        super.init()
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpMaximumConnectionsPerHost = 15
        sessionConfig.timeoutIntervalForRequest = 30.0
        operationQueue.maxConcurrentOperationCount = 15
        session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: operationQueue)
        self.token = user.getTokenUser()
    }
    
    // MARK: - URLRequest from data
    func urlRequestWithUrlFromData(_ urlString: String, param: Dictionary<String, String>, method: String, checkAuthen:Bool, imageData: Data?) -> URLRequest {
        let escapedAddress: String = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url: URL = URL.init(string: escapedAddress)!
        let boundary = generateBoundaryString()
        let mutableUrlRequest: NSMutableURLRequest = NSMutableURLRequest.init(url: url)
        mutableUrlRequest.httpMethod = method
        mutableUrlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        mutableUrlRequest.timeoutInterval = 50
        if checkAuthen
        {
            self.token = user.getTokenUser()
            mutableUrlRequest.setValue(self.token, forHTTPHeaderField:  "Authorization")
        }
        if imageData != nil {
            mutableUrlRequest.httpBody = createBodyWithParameters(parameters: param, filePathKey: Key.EditUserInfo.avatar, imageDataKey: imageData as NSData?, boundary: boundary) as Data
        } else {
            mutableUrlRequest.httpBody = createBodyWithParameters(parameters: param, filePathKey: Key.EditUserInfo.avatar, imageDataKey: nil, boundary: boundary) as Data
        }
       
        return mutableUrlRequest as URLRequest
    }
    
    // MARK: - URLRequest url string
    func urlRequestWithUrlString(_ urlString: String, bodyString: Dictionary<String, String>, method: String, checkAuthen:Bool) -> URLRequest {
        let escapedAddress: String = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url: URL = URL.init(string: escapedAddress)!
        let mutableUrlRequest: NSMutableURLRequest = NSMutableURLRequest.init(url: url)
        mutableUrlRequest.httpMethod = method
        mutableUrlRequest.setValue("application/json", forHTTPHeaderField:  "Content-Type")
        mutableUrlRequest.timeoutInterval = 10
        if checkAuthen
        {
            self.token = user.getTokenUser()
            mutableUrlRequest.setValue(self.token, forHTTPHeaderField:  "Authorization")
        }
        mutableUrlRequest.httpBody =  try! JSONSerialization.data(withJSONObject: bodyString, options: [])
        
        
        return mutableUrlRequest as URLRequest
    }
    
    func urlWithUrlFromData(_ urlString: String, param: Dictionary<String, String>, method: String, checkAuthen:Bool, imageData: [Data]) -> URLRequest {
        let escapedAddress: String = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url: URL = URL.init(string: escapedAddress)!
        let boundary = generateBoundaryString()
        let mutableUrlRequest: NSMutableURLRequest = NSMutableURLRequest.init(url: url)
        mutableUrlRequest.httpMethod = method
        mutableUrlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        mutableUrlRequest.timeoutInterval = 50
        if checkAuthen
        {
            self.token = user.getTokenUser()
            mutableUrlRequest.setValue(self.token, forHTTPHeaderField:  "Authorization")
        }
        if imageData.count > 0{
            mutableUrlRequest.httpBody = createBody(parameters: param, filePathKey: Key.RequestAssitance.breakPics, imageDataKeys: imageData, boundary: boundary) as Data
        } else {
            mutableUrlRequest.httpBody = createBodyWithParameters(parameters: param, filePathKey: Key.RequestAssitance.breakPics, imageDataKey: nil, boundary: boundary) as Data
        }
        
        return mutableUrlRequest as URLRequest
    }
    
   
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData?, boundary: String) -> Data {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        if imageDataKey != nil {
            let filename = "user-profile.jpg"
            let mimetype = "image/jpg"
            
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
            body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageDataKey! as Data)
            body.appendString(string: "\r\n")
        }
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body as Data
    }
    
    func createBody(parameters: [String: String]?, filePathKey: String?, imageDataKeys: [Data], boundary: String) -> Data {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        for imageDataKey in imageDataKeys {
            let filename = "user-profile.jpg"
            let mimetype = "image/jpg"
            
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
            body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageDataKey as Data)
            body.appendString(string: "\r\n")
        }
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body as Data
    }



    
    func ecomRequest(_ request: URLRequest, completionHandler handler: @escaping (_ response: URLResponse?, _ data: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask{
       let sessionTask: URLSessionDataTask?
        
       sessionTask =  self.session?.dataTask(with: request) {data, response, error in
            
            handler(response, data, error as NSError?)
            if (error != nil || data == nil || data?.count == 0){
                if error != nil{
                }
                if data == nil{
                    
                }
                
                if (data?.count == 0){
                    
                }

                }
            }

        sessionTask?.resume()
        return sessionTask!
    }
    // MARK: - Post request
    func Post(keyForDictTask : String?,_ urlString: String!, body bodyString:Dictionary<String, String>, isCheckOuthen:Bool, successRespose: ((_ result: WebServiceRespose) -> Void)?, failureResponse: ((_ error: EComServicesError) -> Void)?) -> Void {
        let urlRequest = urlRequestWithUrlString(urlString, bodyString: bodyString, method: "POST", checkAuthen: isCheckOuthen)
        let task :URLSessionDataTask? = ecomRequest(urlRequest, completionHandler: {(response, data, error) -> Void in
            if (data != nil && (data?.count)! > 0) {
                if let httpResponse = response as? HTTPURLResponse {
                    let response:WebServiceRespose = WebServiceRespose.init(statusCode: httpResponse.statusCode, contentLength: data?.count, response: data, error: error)
                    successRespose?(response)
                    TCLog(response)
                }
            } else {
                failureResponse?(.eComServicesErrorA)
            }
        })
        dictTasks[keyForDictTask!] = task
    }
    
    func putRequest(keyForDictTask : String?,_ urlString: String!, body bodyString:Dictionary<String, String>, isCheckOuthen:Bool, successRespose: ((_ result: WebServiceRespose) -> Void)?, failureResponse: ((_ error: EComServicesError) -> Void)?) -> Void {
        let urlRequest = urlRequestWithUrlString(urlString, bodyString: bodyString, method: "PUT", checkAuthen: isCheckOuthen)
        let task :URLSessionDataTask? = ecomRequest(urlRequest, completionHandler: {(response, data, error) -> Void in
            if (data != nil && (data?.count)! > 0) {
                if let httpResponse = response as? HTTPURLResponse {
                    let response:WebServiceRespose = WebServiceRespose.init(statusCode: httpResponse.statusCode, contentLength: data?.count, response: data, error: error)
                    successRespose?(response)
                    TCLog(response)
                }
            } else {
                failureResponse?(.eComServicesErrorA)
            }
        })
        dictTasks[keyForDictTask!] = task
    }
    
    func PostRequest(keyForDictTask : String?,_ urlString: String!, param paramBody:Dictionary<String, String>,imageData: Data?, isCheckOuthen:Bool, successRespose: ((_ result: WebServiceRespose) -> Void)?, failureResponse: ((_ error: EComServicesError) -> Void)?) -> Void {
        let urlRequest = urlRequestWithUrlFromData(urlString, param: paramBody, method: "POST", checkAuthen: true, imageData: imageData)
        let task :URLSessionDataTask? = ecomRequest(urlRequest, completionHandler: {(response, data, error) -> Void in
            if (data != nil && (data?.count)! > 0) {
                if let httpResponse = response as? HTTPURLResponse {
                    let response:WebServiceRespose = WebServiceRespose.init(statusCode: httpResponse.statusCode, contentLength: data?.count, response: data, error: error)
                    if (response.statusCode == response.statusCodeUnauthorized) {
                        self.errorAuthen()
                    } else {
                        successRespose?(response)
                    }
                    
                }
            } else {
                failureResponse?(.eComServicesErrorA)
            }
        })
        dictTasks[keyForDictTask!] = task
    }
    
    func RequestAssistance(keyForDictTask : String?,_ urlString: String!, param paramBody:Dictionary<String, String>,imageData: [Data], isCheckOuthen:Bool, successRespose: ((_ result: WebServiceRespose) -> Void)?, failureResponse: ((_ error: EComServicesError) -> Void)?) -> Void {
        let urlRequest = urlWithUrlFromData(urlString, param: paramBody, method: "POST", checkAuthen: true, imageData: imageData)
        let task :URLSessionDataTask? = ecomRequest(urlRequest, completionHandler: {(response, data, error) -> Void in
            if (data != nil && (data?.count)! > 0) {
                if let httpResponse = response as? HTTPURLResponse {
                    let response:WebServiceRespose = WebServiceRespose.init(statusCode: httpResponse.statusCode, contentLength: data?.count, response: data, error: error)
                    if (response.statusCode == response.statusCodeUnauthorized) {
                        self.errorAuthen()
                    } else {
                        successRespose?(response)
                    }
                    
                }
            } else {
                failureResponse?(.eComServicesErrorA)
            }
        })
        dictTasks[keyForDictTask!] = task
        
    }

    
    
    func getDataFromUrl(keyForDictTask : String?,url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        let task :URLSessionDataTask? = self.session?.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }
        
        task?.resume()
        dictTasks[keyForDictTask!] = task

    }

    func Get(keyForDictTask : String?,_ urlString: String, checkAuthen: Bool, successResponse : ((_ responseData : WebServiceRespose) ->Void)?, failureResponse: ((_ error: WebServiceRespose) -> Void)? ) {
        
        let escapedAddress: String = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url: URL = URL.init(string: escapedAddress)!
        
        let mutableUrlRequest: NSMutableURLRequest = NSMutableURLRequest.init(url: url)
        mutableUrlRequest.httpMethod = "GET"
        mutableUrlRequest.setValue("application/json", forHTTPHeaderField:  "Content-Type")
        if checkAuthen
        {
            self.token = user.getTokenUser()
            mutableUrlRequest.setValue(self.token, forHTTPHeaderField:  "Authorization")
        }
        let task :URLSessionDataTask? = ecomRequest(mutableUrlRequest as URLRequest) { (response, data, error) -> Void in
            let httpResponse:HTTPURLResponse? = response as? HTTPURLResponse
            let response:WebServiceRespose = WebServiceRespose.init(statusCode: httpResponse?.statusCode, contentLength: (data?.count), response: data, error: error)
            
            if (data != nil && (data?.count)! > 0){
                let response:WebServiceRespose = WebServiceRespose.init(statusCode: httpResponse!.statusCode, contentLength: data?.count, response: data, error: error)
                if (response.statusCode == response.statusCodeUnauthorized) {
                    self.errorAuthen()
                    successResponse?(response)
                } else {
                    successResponse?(response)
                }
            }
            else{
                failureResponse?(response)
            }
        }
        dictTasks[keyForDictTask!] = task
    }
    
    func Put(keyForDictTask : String?,_ urlString: String, checkAuthen: Bool, successResponse : ((_ responseData : WebServiceRespose) ->Void)?, failureResponse: ((_ error: WebServiceRespose) -> Void)? ) {
        
        let escapedAddress: String = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url: URL = URL.init(string: escapedAddress)!
        
        let mutableUrlRequest: NSMutableURLRequest = NSMutableURLRequest.init(url: url)
        mutableUrlRequest.httpMethod = "PUT"
        mutableUrlRequest.setValue("application/json", forHTTPHeaderField:  "Content-Type")
        if checkAuthen
        {
            self.token = user.getTokenUser()
            mutableUrlRequest.setValue(self.token, forHTTPHeaderField:  "Authorization")
        }
        
        let task :URLSessionDataTask? = ecomRequest(mutableUrlRequest as URLRequest) { (response, data, error) in
            let httpResponse:HTTPURLResponse? = response as? HTTPURLResponse
            let response:WebServiceRespose = WebServiceRespose.init(statusCode: httpResponse?.statusCode, contentLength: (data?.count), response: data, error: error)
            
            if (data != nil && (data?.count)! > 0){
                let response:WebServiceRespose = WebServiceRespose.init(statusCode: httpResponse!.statusCode, contentLength: data?.count, response: data, error: error)
                if (response.statusCode == response.statusCodeUnauthorized) {
                    self.errorAuthen()
                    successResponse?(response)
                } else {
                    successResponse?(response)
                }
            }
            else{
                failureResponse?(response)
            }
        }
        dictTasks[keyForDictTask!] = task
    }

    func errorAuthen() {
        logoutUser()
        let alert = UIAlertController(title: errorTitle, message: authenError, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
            let controller = getControllerID(id: .Login)
            getMainNavigation()?.setViewControllers([controller], animated: true)

        })
        getMainNavigation()?.present(alert, animated: true, completion: nil)
        
    }


}



extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
