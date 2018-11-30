//
//  Uti.swift
//  RSAMobile
//
//  Created by tanchong on 3/29/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import SystemConfiguration

class UtilHelper: NSObject {
    
    static let shareInstance: UtilHelper = {
        let instance = UtilHelper()
        return instance
    }()
    
    func getAlert(title: String, message: String, textAction: String)->UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: textAction, style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        })
        return alert
    }
    
    func compareString(root: String, comapre: String) -> Bool {
        if root == comapre {
            return true
        } else {
            return false
        }
    }
    
       func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPassword(pass: String)->Bool {
        let passRe = "^(?=.*[A-Z])(?=.*[0-9]).{8,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passRe)
        return passwordTest.evaluate(with: pass)

    }
    
    func validatePhone(mobile: String) -> Bool {
        
        let pattern = "^(011|015)-[0-9]{4} [0-9]{4}$";
        let pattern1 = "^[0-9]{3}-[0-9]{3} [0-9]{4}$";
        let patTest = NSPredicate(format:"SELF MATCHES %@", pattern)
        let patTest1 = NSPredicate(format:"SELF MATCHES %@", pattern1)
        if (patTest.evaluate(with: mobile) || patTest1.evaluate(with: mobile)) {
            return true;
        }else {
            return false;
        }
    }
    
    func isValidMykid(mykid: String)-> Bool {
        let pattern = "^[0-9]{6}-[0-9]{2}-[0-9]{4}$";
        let patTest = NSPredicate(format:"SELF MATCHES %@", pattern)
        if (patTest.evaluate(with: mykid)) {
            return true;
        }else {
            return false;
        }
    }
    
    func checkLenghtString(text: String, minLenght: Int)->Bool {
        return text.characters.count >= minLenght
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func convertDateFormater(dateTime: String?) -> String {
        if (dateTime == nil) {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date: Date = dateFormatter.date(from: dateTime!) {
            let stringDate = dateFormatter.string(from: date)
            let index = stringDate.index(stringDate.startIndex, offsetBy: 10)
            return stringDate.substring(to: index)
        } else {
            return ""
        }
        
        
    }
    
  
    func formatMobile(phoneNumber: String)->String {
        if phoneNumber.characters.count < 10 {
            return ""
        }
        var offerBy = 8
        if phoneNumber.characters.count == 10 {
            offerBy = 7
        }
        var index = phoneNumber.index(phoneNumber.startIndex, offsetBy: 3)
        var phoneFormat = phoneNumber.substring(to: index)
        index = phoneNumber.index(phoneFormat.endIndex, offsetBy: 1)
        let resPhone = phoneNumber.substring(from: index)
        offerBy = 4
        if phoneNumber.characters.count == 10 {
            offerBy = 3
        }
        index = phoneNumber.index(resPhone.startIndex, offsetBy: offerBy)
        let phone2 = resPhone.substring(to: index)
        index = resPhone.index(phone2.endIndex, offsetBy: 1)
        let phone3 = resPhone.substring(from: index)
        phoneFormat.append("-")
        phoneFormat.append(phone2)
        phoneFormat.append(" ")
        phoneFormat.append(phone3)
        return phoneFormat
    }
    
    func deFomatMobile(phoneNumber: String)->String {
        var phone = phoneNumber
        if phoneNumber.characters.count < 12 {
            return ""
        }
        var offerBy = 8
        if phoneNumber.characters.count == 12 {
            offerBy = 7
        }
        let index2 = phoneNumber.index(phoneNumber.startIndex, offsetBy: 3)
        let index = phoneNumber.index(phoneNumber.startIndex, offsetBy: offerBy)
        phone.remove(at: index)
        phone.remove(at: index2)
        return phone
    }
    
    func checkExpiry(date: String)->Bool {
        let expir = false
        
        if (getCurrentYear() > getYearFromDate(date: date)) {
            return true
        }

        if (getCurrentYear() < getYearFromDate(date: date)) {
            return false
        }
        
        if getCurrentMoth() > getMothFromDate(date: date) {
            return true
        }

        if getCurrentMoth() < getMothFromDate(date: date) {
            return false
        }
        
        if getCurrentDay() > getDateFromDate(date: date) {
            return true
        }
        
        if getCurrentDay() == getDateFromDate(date: date) {
            return true
        }

        return expir
    }
    
    func getCurrentYear()->Int {
        let date  = NSDate()
        let calendar = NSCalendar.current
        let year = calendar.component(.year, from: date as Date)
        return year
    }
    
    func getCurrentMoth()->Int {
        let date  = NSDate()
        let calendar = NSCalendar.current
        let month = calendar.component(.month, from: date as Date)
        return month
    }
    
    func getCurrentDay()->Int {
        let date  = NSDate()
        let calendar = NSCalendar.current
        let day = calendar.component(.day, from: date as Date)
        return day
    }
    
    func getYearFromDate(date: String)->Int {
        let index = date.index(date.startIndex, offsetBy: 4)
        let year = date.substring(to: index)
        return Int(year)!
    }
    
    func getMothFromDate(date: String)->Int {
        let index = date.index(date.startIndex, offsetBy: 5)
        let year = date.substring(to: index)
        let mIndex = date.index(year.endIndex, offsetBy: 2)
        let month = date.substring(to: mIndex)
        return Int(month)!
    }
    
    func getDateFromDate(date: String)->Int {
        let index = date.index(date.startIndex, offsetBy: 8)
        let year = date.substring(to: index)

        let dIndex = date.index(year.endIndex, offsetBy: 2)
        let day = date.substring(to: dIndex)
        return Int(day)!
    }
    
    
}
