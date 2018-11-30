//
//  ProviderObject.swift
//  RSAMobile
//
//  Created by Nguyen Van Trung on 5/9/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class ProviderObject: NSObject {
    var caseId: Int?
    var serviceOderId: Int?
    var providerName: String?
    var distance: String?
    var estimateTime: String?
    
    func setCaseId(id: Int?) {
        self.caseId = id
    }
    
    func setServiceOderId(id: Int?) {
        self.serviceOderId = id
    }
    
    func setProviderName(providerName: String?) {
        self.providerName = providerName
    }
    
    func setDistance(distance: String?) {
        self.distance = distance
    }
    
    func setEstimateTime(estimateTime: String) {
        self.estimateTime = estimateTime
    }
    
    func getCaseId()-> Int? {
        return caseId
    }
    
    func getServcieOderId()-> Int? {
        return serviceOderId
    }
    
    func getProviderName()-> String? {
        return providerName
    }
    
    func getDistance() ->String?  {
        return distance
    }
    
    func getEstimateTime()-> String? {
        return estimateTime
    }
}
