//
//  ServiceList.swift
//  RSAMobile
//
//  Created by Nguyen Van Trung on 5/8/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class ServiceList: NSObject {
    var serviceOrderId: Int?
    var providerName: String?
    var providerPhone: String?
    var coverageAmount: Int?
    var customerPayMent: Int?
    var totalFee: Int?
    var totalAdjust: Int?
    var serviceType: String?
    var status: Int?
    //var activationLog:[ActivationLog]?
    
    func setServiceType(serviceType: String?) {
        self.serviceType = serviceType
    }
    
    func setStatus(status: Int?) {
        self.status = status
    }
    
    func setServiceId(id: Int?) {
        self.serviceOrderId = id
    }
    
       
    func setProviderName(providerName: String?) {
        self.providerName = providerName
    }
    
    func setProviderPhone(providerPhone: String?) {
        self.providerPhone = providerPhone
    }
    
    func setCoverageAmount(coverage: Int?) {
        self.coverageAmount = coverage
    }
    
    func setCustomerPayMent(customerPay: Int?) {
        self.customerPayMent = customerPay
    }
    
    func setTotalFee(totalFee: Int?) {
        self.totalFee = totalFee
    }
    
    func setTotalAdjust(totalAdjust: Int?) {
        self.totalAdjust = totalAdjust
    }
    
//    func setActivationLog(activationLog: [ActivationLog]) {
//        self.activationLog = activationLog
//    }
    
    func getServiceId()->Int? {
        return serviceOrderId
    }
    
    func getProviderName()-> String? {
        return self.providerName
    }
    
    func getProviderPhone() -> String? {
        return self.providerPhone
    }
    
    func getCoverageAmount()-> Int? {
        return self.coverageAmount
    }
    
    func getCustomerPay()->Int? {
        return self.customerPayMent
    }
    
    func getTotalFee()-> Int? {
        return totalFee
    }
    
    func getTotalAdjust() -> Int? {
        return totalAdjust
    }
    
    func getServiceType()-> String? {
        return serviceType
    }
    
    func getStatus()-> Int? {
        return status
    }
    
//    func getActivationLog()-> [ActivationLog]? {
//        return self.activationLog
//    }
    
}
