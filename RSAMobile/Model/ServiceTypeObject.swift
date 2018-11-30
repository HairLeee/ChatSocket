//
//  ServiceTypeObject.swift
//  RSAMobile
//
//  Created by tanchong on 4/14/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class ServiceTypeObject: NSObject {
    var id: Int?
    var name: String?
    
    func setId(id: Int) {
        self.id = id
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func getId()->Int? {
        return id
    }
    
    func getName()->String?{
        return name
    }
}
