//
//  UserHelper.swift
//  RSAMobile
//
//  Created by tanchong on 3/30/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class UserHelper: NSObject {
    
     let userDefaults = UserDefaults.standard
    
     func extractUser(_ data: NSDictionary) -> Bool {
        if let responseJson = data as? [String : AnyObject] {
            guard let userInfo = AccountInfoResponse(json: responseJson)
                else {
                    return false
            }
            userDefaults.set(userInfo.accessToken, forKey: Key.AccountResponse.token)
            userDefaults.set(userInfo.verified, forKey: Key.AccountResponse.verified)
            userDefaults.set(userInfo.active, forKey: Key.AccountResponse.active)
            userDefaults.set(userInfo.user.name, forKey: Key.AccountResponse.userName)
            userDefaults.set(userInfo.user.email, forKey: Key.AccountResponse.userEmail)
            userDefaults.set(userInfo.user.mobile, forKey: Key.AccountResponse.userMobile)
            userDefaults.set(userInfo.user.avatarUrl, forKey: Key.AccountResponse.userAvatar)
            userDefaults.set(userInfo.user.avatarUrlBlur == nil ? userInfo.user.avatarUrl! + "blur" : userInfo.user.avatarUrlBlur, forKey: Key.AccountResponse.userAvatar_blur)
            return true
        } else {
            return false
        }
        
    }
    
     func deleteUserInfor() {
        userDefaults.removeObject(forKey: Key.AccountResponse.token)
        userDefaults.removeObject(forKey: Key.AccountResponse.userName)
        userDefaults.removeObject(forKey: Key.AccountResponse.userEmail)
        userDefaults.removeObject(forKey: Key.AccountResponse.userMobile)
        userDefaults.removeObject(forKey: Key.AccountResponse.userAvatar)
        userDefaults.removeObject(forKey: Key.AccountResponse.userAvatar_blur)

    }
    
    func getTokenUser() -> String? {
        return userDefaults.string(forKey: Key.AccountResponse.token)
    }
    
    func getVeified()-> Int? {
        return userDefaults.integer(forKey: Key.AccountResponse.verified)
    }
    
    func getUserName()-> String? {
        return userDefaults.string(forKey: Key.AccountResponse.userName)
    }
    
    
    func getUserEmail()-> String? {
        return userDefaults.string(forKey: Key.AccountResponse.userEmail)
    }
    
    func getUserMobile()-> String? {
        return userDefaults.string(forKey: Key.AccountResponse.userMobile)
    }
    
    func getUserAvatar()-> String? {
        return userDefaults.string(forKey: Key.AccountResponse.userAvatar)
    }
    func getUserAvatarBlur()-> String? {
        return userDefaults.string(forKey: Key.AccountResponse.userAvatar_blur)
    }
    func getCurrentPass()-> String? {
        return userDefaults.string(forKey: Key.CURRENT_PASSWOR)
    }
    
    func getActive()->Int? {
        return userDefaults.integer(forKey: Key.AccountResponse.active)
    }
    
    func getCarNumber()->String? {
        return userDefaults.string(forKey: Key.Notify.carNumber)
    }
    
    func setUserName(name: String) {
        userDefaults.set(name, forKey: Key.AccountResponse.userName)
    }
    
    func setUserEmail(email: String) {
        userDefaults.set(email, forKey: Key.AccountResponse.userEmail)
    }
    
    func setUserMobile(mobile: String) {
        userDefaults.set(mobile, forKey: Key.AccountResponse.userMobile)
    }
    
    func setUserAvatar(avatar: String) {
        userDefaults.set(avatar, forKey: Key.AccountResponse.userAvatar)
        userDefaults.set(avatar + "Blur", forKey: Key.AccountResponse.userAvatar_blur)
    }
    func setUserAvatarBlur(avatar: String) {
        userDefaults.set(avatar, forKey: Key.AccountResponse.userAvatar_blur)
    }

    func setCurrentPass(pass: String) {
        userDefaults.set(pass, forKey: Key.CURRENT_PASSWOR)
    }
    
    func setVerify(verify: Int) {
        userDefaults.set(verify, forKey: Key.AccountResponse.verified)
    }
    
    func setActive(active: Int) {
        userDefaults.set(active, forKey: Key.UserActive.active)
    }
    
    func setCarNumber(carNumber: String) {
        userDefaults.set(carNumber, forKey: Key.Notify.carNumber)
    }
    
   


}
