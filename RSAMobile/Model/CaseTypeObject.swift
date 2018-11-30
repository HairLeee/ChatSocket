//
//  CaseTypeObject.swift
//  RSAMobile
//
//  Created by tanchong on 4/14/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class CaseTypeObject: NSObject {
    var id: Int?
    var name: String?
    var icon: String?
    
    func setId(id: Int) {
        self.id = id
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func setIcon(icon: String) {
        self.icon = icon
    }
    
    func getId()->Int? {
        return id
    }
    
    func getName()->String?{
        return name
    }
    
    func getIcon()-> String? {
        return icon
    }
    
}
