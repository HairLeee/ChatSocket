//
//  FacebookObject.swift
//  RSAMobile
//
//  Created by tanchong on 3/28/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class SocialUerObject: NSObject {
    
    private var mName: String?
    private var mEmail: String?
    private var mId: String?
    private var mAvatar: String?
    
    required init(name: String?, email: String?, id: String?, avatarUrl: String?) {
        super.init()
        self.mId = id
        self.mEmail = email
        self.mName = name
        self.mAvatar = avatarUrl
    }
    
    func getName()-> String?{
        return mName
    }
    
    func getId()-> String? {
        return mId
    }
    
    func getEmail() -> String? {
        return mEmail
    }
    
    func getUrl()-> String?{
        return mAvatar
    }
}
