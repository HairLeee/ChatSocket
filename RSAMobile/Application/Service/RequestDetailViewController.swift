//
//  RequestDetailViewController.swift
//  RSAMobile
//
//  Created by tanchong on 4/14/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import DropDown
import Firebase

class RequestDetailViewController: BaseViewController, UITextFieldDelegate {
    
    var listServiceType: [ServiceTypeObject] = []
    var listFaultType: [FaulTypeObject] = []
    var listFaulData = [String]()
    var listSertype = [String]()
    var loading = LoadingOverlay()
    let failMessage = "Fail to load data, Had some problem while conneting to server."
    let distanceUp = " distance up to 0km"
    let CASHID = 1
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var corverdLabel: UILabel!
    @IBOutlet weak var carNo: UILabel!
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var caseType: UILabel!
    @IBOutlet weak var faultType: UILabel!
    @IBOutlet weak var service: UILabel!
    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var caseTypeImage: UIImageView!
    
    @IBOutlet weak var cashButton: UIButton!
    var carNoText:String?
    var currentLocationText:String?
    var caseTypeText: String?
    var caseTypeId:Int?
    var faultTypeDropDown = DropDown()
    var serviceDropDown = DropDown()
    var caseTypeImageView:UIImage?
    var isChooseCash = false
    var faulTypeId:Int?
    var serviceId:Int?
    
    @IBOutlet weak var dotView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        getListService()
        getListFaulType()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BaseViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.title = "Request Assitance"
       
        let rightButItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.tapedDone(_:)))
        self.navigationItem.rightBarButtonItem = rightButItem
        let leftBarButton = UIBarButtonItem(image: UIImage.init(named: "back"), style: .done, target: self, action: #selector(self.popToRoot(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarButton
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    func popToRoot(sender:UIBarButtonItem){
        _ = self.navigationController?.popToRootViewController(animated: true)
    }

    
    func initView() {
        carNo.text = carNoText
        currentLocation.text = currentLocationText
        caseType.text = caseTypeText
        caseTypeImage.image = caseTypeImageView
        scrollView.isScrollEnabled = false
        comment.delegate = self
        // Dropdow
        faultTypeDropDown.anchorView = faultType
        faultTypeDropDown.width = faultType.frame.size.width
        faultTypeDropDown.direction = .bottom
        faultTypeDropDown.bottomOffset = CGPoint(x: 0, y:(faultTypeDropDown.anchorView?.plainView.bounds.height)!)
        faultTypeDropDown.selectionAction = { (index: Int, item: String) in
            self.faultType.text = item
            self.faulTypeId = self.listFaultType[index].getId()
            self.faultTypeDropDown.hide()
        }
        
        // Guesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(RequestDetailViewController.faulTypeTap(sender:)))
        faultType.isUserInteractionEnabled = true
        faultType.addGestureRecognizer(tap)
        let serviceTap = UITapGestureRecognizer(target: self, action: #selector(self.serviceTap(sender:)))
        service.isUserInteractionEnabled = true
        service.addGestureRecognizer(serviceTap)
        serviceDropDown.anchorView = service
        serviceDropDown.width = service.frame.size.width
        serviceDropDown.direction = .bottom
        serviceDropDown.bottomOffset = CGPoint(x: 0, y:(serviceDropDown.anchorView?.plainView.bounds.height)!)
        serviceDropDown.selectionAction = { (index: Int, item: String) in
            self.service.text = item
            self.corverdLabel.text = "Coverd: " + item + self.distanceUp
            self.serviceDropDown.hide()
            self.serviceId = self.listServiceType[index].getId()
        }
        
        cashButton.layer.cornerRadius = cashButton.frame.size.width/2
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.title = ""
        sendTokenDivce()
    }
    
    func sendTokenDivce() {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            let body = ["token": refreshedToken] as Dictionary<String, String>
            let url = ServerConfigure.url + ServerConfigure.Path.token
            RequestService.shareInstance.putRequest(keyForDictTask: ServerConfigure.Path.token, url, body: body, isCheckOuthen: true, successRespose: {(response) in
                if let dicResult = response.dictData {
                    let success = dicResult["code"] as! Int
                    if success == successCode {
                        
                    }
                }
            } , failureResponse:  { (error) in
                
            })
        }
        
    }
    
    // MARK: - Fetch data from server
    func getListService() {
        let url = ServerConfigure.url + ServerConfigure.Path.getListServiceType
        loading.showOverlay(view: view)
        RequestService.shareInstance.Get(keyForDictTask: ServerConfigure.Path.getListServiceType, url, checkAuthen: true,successResponse:{(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                if let dictionResult = response.dictData {
                    let success = dictionResult["code"] as! Int
                    if success == successCode {
                        self.listServiceType = RequestHelper.shareInstance.extractServicetypeJson(dictionResult)
                        if self.listServiceType.count == 0 {
                            return
                        }
                        for service in self.listServiceType {
                            self.listSertype.append(service.getName()!)
                        }
                        self.serviceDropDown.dataSource = self.listSertype
                        self.service.text = self.listSertype[0]
                        self.corverdLabel.text = "Coverd: " + self.listSertype[0] + self.distanceUp
                        self.serviceId = self.listServiceType[0].getId()
                    } else {
                        OperationQueue.main.addOperation {
                            self.showError(message: dictionResult["message"] as! String)
                        }
                    }
                    
                    
                }

            }
        } , failureResponse: {(error) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                self.showError()
            }
        })
    }
    
    func getListFaulType() {
        let url = ServerConfigure.url + ServerConfigure.Path.getListFaultType + String(caseTypeId!)
        //loading.showOverlay(view: view)
        RequestService.shareInstance.Get(keyForDictTask: ServerConfigure.Path.getListFaultType, url, checkAuthen: true,successResponse:{(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                if let dictionResult = response.dictData {
                    let success = dictionResult["code"] as! Int
                    if success == successCode {
                        self.listFaultType = RequestHelper.shareInstance.extractFaultTypeJson(dictionResult)
                        if self.listFaultType.count == 0 {
                            return
                        }
                        for faultType in self.listFaultType {
                            self.listFaulData.append(faultType.getName()!)
                        }
                        self.faultTypeDropDown.dataSource = self.listFaulData
                        self.faultType.text = self.listFaulData[0]
                        self.faulTypeId = self.listFaultType[0].getId()
                        
                    } else {
                        OperationQueue.main.addOperation {
                            self.showError(message: dictionResult["message"] as! String)
                        }
                    }
                    
                    
                }

            }
        } , failureResponse: {(error) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                self.showError()
            }
        })
    }
    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showError() {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message: self.failMessage, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITEXTFIELD Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.scrollView.isScrollEnabled = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.scrollToTop()
        self.scrollView.isScrollEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    // MARK: - Taped Button
    @IBAction func tapedDone(_ sender: Any) {
        if isChooseCash == false {
            showError(message: "Plase choose a payment!")
            return
        }
        let url = ServerConfigure.url + ServerConfigure.Path.requestAssistance
        let body = getBody()
        loading.showOverlay(view: view)
        RequestService.shareInstance.Post(keyForDictTask: ServerConfigure.Path.requestAssistance, url, body: body, isCheckOuthen: true, successRespose: {(responseData) in
            
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            if let dictResult = responseData.dictData {
                let success = dictResult["code"] as! Int
                if success == successCode {
                    OperationQueue.main.addOperation {
                        let waiting = getControllerID(id: .Waiting) as! WaitingViewController
                        waiting.caseId = dictResult["id"] as? Int
                        self.navigationController?.pushViewController(waiting, animated: true)

                    }
                    
                } else {
                    OperationQueue.main.addOperation {
                        self.showError(message: dictResult["message"] as! String)
                    }
                    
                }
            } else {
                OperationQueue.main.addOperation {
                    self.showError(message: self.failMessage)
                }
            }
        }, failureResponse: { (error) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                self.showError(message: self.failMessage)
            }
        })

    }
    
    @IBAction func tapedBack(_ sender: Any) {
        let controller = getControllerID(id: .RequestAssistance)
        getMainNavigation()?.setViewControllers([controller], animated: true)

    }

    @IBAction func tapedFaultype(_ sender: Any) {
        faultTypeDropDown.show()
    }
    
    @IBAction func tapedService(_ sender: Any) {
        serviceDropDown.show()
    }
    
    @IBAction func tapedCash(_ sender: Any) {
        if isChooseCash == false {
            cashButton.layer.backgroundColor = UIColor(red: 38/255, green: 124/255, blue: 196/255, alpha: 1.0).cgColor
            isChooseCash = true
        } else {
            cashButton.layer.backgroundColor = UIColor(red: 67/255, green: 169/255, blue: 255/255, alpha: 1.0).cgColor
            isChooseCash = false
        }
    }
    
    func faulTypeTap(sender: UITapGestureRecognizer) {
        faultTypeDropDown.show()
    }
    
    func serviceTap(sender: UITapGestureRecognizer) {
        serviceDropDown.show()
    }
    
    func getBody()-> Dictionary<String, String> {
        let body = [Key.RequestAssitance.carplateNumber: carNoText!, Key.RequestAssitance.currentLocation: currentLocationText!, Key.RequestAssitance.caseTypeId: String(caseTypeId!),
                    Key.RequestAssitance.faultTypeId: String(faulTypeId!), Key.RequestAssitance.serviceTypeId: String(serviceId!), Key.RequestAssitance.note: comment.text != nil ? comment.text! : "", Key.RequestAssitance.paymentType: String(CASHID)] as Dictionary<String, String>
        
        return body
    }
    
}
