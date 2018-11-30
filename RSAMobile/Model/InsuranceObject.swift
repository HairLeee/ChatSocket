//
//  InsuranceObject.swift
//  RSAMobile
//
//  Created by tanchong on 4/13/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class InsuranceObject: NSObject {
    var id: Int?
    var coverate: String?
    var expiry: String?
    var carRegNo: String?
    var make: String?
    var model: String?
    var yearMake: Int?
    var statusExpiry: Int?
    
    func setId(id: Int) {
        self.id = id
    }
    
    func setCoverate(coverate: String?) -> Void {
        self.coverate = coverate
    }
    
    func setExpiry(expiry: String?) -> Void {
        self.expiry = expiry
    }
    
    func setCarRegNo(regNo: String?)-> Void{
        self.carRegNo = regNo
    }
    
    func setMake(make: String?)->Void {
        self.make = make
    }
    
    func setModel(model: String?) {
        self.model = model
    }
    
    func setYearMake(yearMake: Int?) -> Void {
        self.yearMake = yearMake
    }
    
    func setStatusExpiry(statust: Int?) {
        self.statusExpiry = statust
    }
    
    func getId() -> Int? {
        return id
    }
    
    func getCoverate()-> String? {
        return coverate
    }
    
    func getExpiry()-> String? {
        return expiry
    }
    
    func getRegNo()->String? {
        return carRegNo
    }
    
    func getMake() -> String? {
        return make
    }
    
    func getModel() -> String? {
        return model
    }
    
    func getYearMake()-> Int? {
        return yearMake
    }
    
    func getStatusExpiry()-> Int? {
        return self.statusExpiry
    }
    
}
