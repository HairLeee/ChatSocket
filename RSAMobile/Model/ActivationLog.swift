//
//  ActivationLog.swift
//  RSAMobile
//
//  Created by Nguyen Van Trung on 5/11/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class ActivationLog: NSObject {
    var providerName: String?
    var serviceParent: String?
    var serviceAddition: String?
    var fee: Int?
    var adjust: Int?
    var total: Int?
    var activationLogId: Int?
    var priceServiceParent: Int?
    var priceServiceAddition: Int?
    var status: Int?
    var note: String?
    var activeNote: String?
    var cancelNote: String?
    var cancelFee: Double?
    
    func setActivationId(id: Int?) {
        self.activationLogId = id
    }
    
    func setProviderName(providerName: String?) {
        self.providerName = providerName
    }
    
    func setPriceServiceParent(price: Int?) {
        self.priceServiceParent = price
    }
    
    
    func setPriceServiceAddition(price: Int?) {
        self.priceServiceAddition = price
    }
    
    func setStatus(status: Int?) {
        self.status = status
    }
    
    func setNote(note: String?) {
        self.note = note
    }
    
    func setActiveNote(note: String?) {
        self.activeNote = note
    }
    
    func setCancelNote(note: String?) {
        self.cancelNote = note
    }
    
    func setServiceParent(serviceParent: String?) {
        self.serviceParent = serviceParent
    }
    
    func setServiceAddition(serviceAddition: String?) -> Void {
        self.serviceAddition = serviceAddition
    }
    
    func setFee(fee: Int?) {
        self.fee = fee
    }
    
    func setCancelFee(fee: Double?) {
        self.cancelFee = fee
    }
    
    func setAdjust(adjust: Int?) {
        self.adjust = adjust
    }
    
    func setTotal(total: Int?) {
        self.total = total
    }

    func getParentService()-> String? {
        return serviceParent
    }
    
    func getServiceAddition()-> String? {
        return serviceAddition
    }
    
    func getFee()-> Int? {
        return fee
    }
    
    func getAdjust() -> Int? {
        return adjust
    }
    
    func getTotal()-> Int? {
        return total
    }
    
    func getCancelFee()->Double? {
        return cancelFee
    }
    
    
    func getProviderName()-> String? {
        return self.providerName
    }
    
    func getActivationLogId()->Int? {
        return activationLogId
    }
    
    func getServiceParentPrice()->Int?  {
        return priceServiceParent
    }
    
    func getAdditionServicePrice()->Int? {
        return priceServiceAddition
    }
    
    func getStatus()->Int? {
        return status
    }
    
    func getNote()->String {
        if let note = self.note {
            return note
        } else {
            return ""
        }
        
    }
    
    func getActiveNote()->String {
        if let note = self.activeNote {
            return note
        } else {
            return ""
        }
    }
    
    func getCancelNote()->String {
        if let note = self.cancelNote {
            return note
        } else {
            return ""
        }
    }


}
