//
//  RequestHelper.swift
//  RSAMobile
//
//  Created by tanchong on 4/14/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class RequestHelper: NSObject {
    static let shareInstance: RequestHelper = {
        let instance = RequestHelper()
        return instance
    }()
    
    func extractInsuranceJson(_ data: NSDictionary)->[InsuranceObject] {
        var listInsurance: [InsuranceObject] = []
        if let responseJson = data as? [String : AnyObject] {
            
            if let carJSON: NSArray = (responseJson[Key.Car.data] as? NSArray) {
                for i in 0..<carJSON.count {
                    let carInfo = carJSON.object(at: i) as? [String: AnyObject]
                    let insurance = InsuranceObject()
                    insurance.setId(id: (carInfo?[Key.Car.id] as? Int)!)
                    insurance.setYearMake(yearMake: (carInfo?[Key.Car.yearMake] as? Int))
                    insurance.setCoverate(coverate:((carInfo?[Key.Car.typeOfCover] as? String)! + "_") + (carInfo?[Key.Car.coverate] as? String)!)
                    insurance.setMake(make: (carInfo?[Key.Car.make] as? String))
                    insurance.setModel(model: (carInfo?[Key.Car.model] as? String))
                    insurance.setExpiry(expiry: (carInfo?[Key.Car.expiry] as? String))
                    insurance.setStatusExpiry(statust: carInfo?[Key.Car.statusExpiry] as? Int)
                    insurance.setCarRegNo(regNo: (carInfo?[Key.Car.carRegNo]as? String))
                    listInsurance.append(insurance)
                }

            }
            
        }
        
        return listInsurance
        
    }
    func extractCaseStatusJson(_ data: NSDictionary)-> CaseStatusResponse {
        var caseStatusStruct =  CaseStatusResponse(code: 0, message: " ", caseStatus: CaseStatus.new_case, agentAssign: " ")
        if let responseJson = data as? [String : AnyObject] {
            for (key,value) in responseJson {
                switch key {
                case CaseStatusKey.code:
                    caseStatusStruct.code = value as? UInt8
                    break
                case CaseStatusKey.message:
                    caseStatusStruct.message = value as? String
                    break
                case CaseStatusKey.caseStatus:
                    caseStatusStruct.caseStatus = value as? CaseStatus
                    break
                case CaseStatusKey.agentAssign:
                    caseStatusStruct.agentAssign = value as? String
                    break
                default: break
                    
                }
            }
            
        }
        
        return caseStatusStruct
        
    }

    func extractCaseTypeJson(_ data: NSDictionary)->[CaseTypeObject] {
        var listInsurance: [CaseTypeObject] = []
        if let responseJson = data as? [String : AnyObject] {
            
            if let caseTypeSON: NSArray = (responseJson[Key.Car.data] as? NSArray) {
                for i in 0..<caseTypeSON.count {
                    let carInfo = caseTypeSON.object(at: i) as? [String: AnyObject]
                    let caseTypeObjet = CaseTypeObject()
                    caseTypeObjet.setId(id: (carInfo?[Key.CaseType.id] as? Int)!)
                    caseTypeObjet.setName(name:(carInfo?[Key.CaseType.name] as? String)!)
                    caseTypeObjet.setIcon(icon: (carInfo?[Key.CaseType.icon] as? String)!)
                    listInsurance.append(caseTypeObjet)
                }
            }
            
            
        }
        
        return listInsurance
        
    }
    
    
    func extractFaultTypeJson(_ data: NSDictionary)->[FaulTypeObject] {
        var listInsurance: [FaulTypeObject] = []
        if let responseJson = data as? [String : AnyObject] {
            
            if  let faultTypeJSON: NSArray = (responseJson[Key.Car.data] as? NSArray) {
                for i in 0..<faultTypeJSON.count {
                    let typeInfo = faultTypeJSON.object(at: i) as? [String: AnyObject]
                    let insurance = FaulTypeObject()
                    insurance.setId(id: (typeInfo?[Key.FaultType.id] as? Int)!)
                    insurance.setName(name: (typeInfo?[Key.FaultType.name]as? String)!)
                    listInsurance.append(insurance)
                }
            }
            
            
        }
        
        return listInsurance
        
    }
    
    func extractServicetypeJson(_ data: NSDictionary)->[ServiceTypeObject] {
        var listInsurance: [ServiceTypeObject] = []
        if let responseJson = data as? [String : AnyObject] {
            
            if  let serviceJSON: NSArray = (responseJson[Key.Car.data] as? NSArray) {
                for i in 0..<serviceJSON.count {
                    let servicInfo = serviceJSON.object(at: i) as? [String: AnyObject]
                    let insurance = ServiceTypeObject()
                    insurance.setId(id: (servicInfo?[Key.ServicType.id] as? Int)!)
                    insurance.setName(name: (servicInfo?[Key.ServicType.typeName] as? String)!)
                    listInsurance.append(insurance)
                }
            }
        }
        
        return listInsurance
        
    }


    func extracServiceList(_ data: NSDictionary)->[ServiceList] {
        var listServices: [ServiceList] = []
        if let serviceJson: NSArray = (data[Key.ServiceList.listService] as? NSArray) {
            for i in 0..<serviceJson.count {
                let serviceList = ServiceList()
                let info = serviceJson.object(at: i) as? [String: AnyObject]
                serviceList.setProviderName(providerName: info?[Key.ServiceList.providerName] as? String)
                serviceList.setProviderPhone(providerPhone: info?[Key.ServiceList.providerPhone] as? String)
                serviceList.setCoverageAmount(coverage: info?[Key.ServiceList.coverageAmount] as? Int)
                serviceList.setCustomerPayMent(customerPay: info?[Key.ServiceList.customerPay] as? Int)
                serviceList.setTotalFee(totalFee: info?[Key.ServiceList.totalFee] as? Int)
                serviceList.setTotalAdjust(totalAdjust: info?[Key.ServiceList.totalAdjust] as? Int)
                serviceList.setServiceId(id: info?[Key.ServiceList.serviceOrderId] as? Int)
                serviceList.setServiceType(serviceType: info?[Key.ServiceList.serviceType] as? String)
                serviceList.setStatus(status: info?[Key.ServiceList.status] as? Int)
//                if let actionLog: NSArray = (info?[Key.ServiceList.activationlogs] as? NSArray) {
//                    var activationLogs: [ActivationLog] = []
//                    for i in 0..<actionLog.count {
//                        let activationLog = ActivationLog()
//                        let tariff = actionLog.object(at: i) as? [String: AnyObject]
//                        activationLog.setActivationId(id: tariff?[Key.ServiceList.activavationLogId] as? Int)
//                        activationLog.setServiceParent(serviceParent: tariff?[Key.ServiceList.serviceParent] as? String)
//                        activationLog.setPriceServiceParent(price: tariff?[Key.ServiceList.priceServiceParent] as? Int)
//                        activationLog.setServiceAddition(serviceAddition: tariff?[Key.ServiceList.serviceAddition] as? String)
//                        activationLog.setPriceServiceAddition(price: tariff?[Key.ServiceList.priceServiceAddition] as? Int)
//                        activationLog.setProviderName(providerName: info?[Key.ServiceList.providerName] as? String)
//                        activationLog.setStatus(status: tariff?[Key.ServiceList.status] as? Int)
//                        activationLog.setNote(note: tariff?[Key.ServiceList.note] as? String)
//                        activationLog.setActiveNote(note: tariff?[Key.ServiceList.activeNote] as? String)
//                        activationLog.setCancelNote(note: tariff?[Key.ServiceList.cancelNote] as? String)
//                        activationLog.setCancelFee(fee: tariff?[Key.ServiceList.cancellationFee] as? Double)
//                        activationLog.setFee(fee: tariff?[Key.ServiceList.fee] as? Int)
//                        activationLog.setAdjust(adjust: tariff?[Key.ServiceList.adjust] as? Int)
//                        activationLog.setTotal(total: tariff?[Key.ServiceList.total] as? Int)
//                        activationLogs.append(activationLog)
//                    }
//                    serviceList.setActivationLog(activationLog: activationLogs)
//                }
                listServices.append(serviceList)
            }
        }
        
        return listServices
    }

}
