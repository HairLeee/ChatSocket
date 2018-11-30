//
//  AccountInfoResponse.swift
//  RSAMobile
//
//  Created by tanchong on 3/29/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import Foundation

struct AccountInfoResponse {
    let accessToken: String
    let verified: Int?
    let active: Bool?
    let user: (name: String?, email: String?, mobile: String?, avatarUrl: String?,avatarUrlBlur: String?)
}


extension AccountInfoResponse {
    init?(json: [String: Any]) {
        guard let accessToken = json[Key.AccountResponse.token] as? String,
            let userJSON = json[Key.AccountResponse.user] as? [String : AnyObject]
        else {
            return nil
        }
        let verified = json[Key.AccountResponse.verified] as? Int
        let active = json[Key.AccountResponse.active] as? Bool
        let name = userJSON[Key.AccountResponse.userName] as? String
        let email = userJSON[Key.AccountResponse.userEmail] as? String
        let mobile = userJSON[Key.AccountResponse.userMobile] as? String
        let avatar = userJSON[Key.AccountResponse.userAvatar] as? String ?? "avatar"
        let avatarBlur =  avatar + "Blur"
        self.accessToken = accessToken
        self.user = (name, email, mobile, avatar , avatarBlur)
        self.verified = verified
        self.active = active
    }
    
}
