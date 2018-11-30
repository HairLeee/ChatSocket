//
//  ServiceListViewController.swift
//  RSAMobile
//
//  Created by Nguyen Van Trung on 5/5/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import Firebase
class ServiceListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var completeView: UIView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var onHoldView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
   // @IBOutlet weak var totalFee: UILabel!
   // @IBOutlet weak var coverageLabel: UILabel!
    @IBOutlet weak var serviceTable: UITableView!
    @IBOutlet weak var doneButton: UIButton!
//    @IBOutlet weak var infoView: UIView!
    
   // @IBOutlet weak var parentFee: UILabel!
    
    
    
    let user = UserDefaults.standard
    let loading = LoadingOverlay()
    let failLoadMessage = "Fail to load data, Had some problem while conneting to server."
    var caseId: Int?
    var servicelists:[ServiceList] = []
    let cellIdentifier = "providerCell"
    //var listAtivationLog: [ActivationLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Service List"
        doneButton.setBackgroundImage(UIImage(named: "btn_done_click"), for: .highlighted)
        doneButton.setTitleColor(UIColor.white, for: .highlighted)
        doneButton.isHidden = true
        initView()
        getServiceList()
        updateTopView()
        serviceTable.rowHeight = UITableViewAutomaticDimension
        serviceTable.estimatedRowHeight = 100

//        infoView.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let canel = user.integer(forKey: Key.UserActive.cancelService) as Int
        if canel == CANCEL_SERVICE {
            getServiceList()
        }
        user.set(DONE_REQUEST, forKey: Key.LocalKey.doneRequest)
        user.set(NO_CANCEL, forKey: Key.UserActive.cancelService)
        user.set(SERVICE_LIST, forKey: Key.UserActive.serviceList)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange, object: .none, queue: OperationQueue.main) { [weak self] _ in
            self?.serviceTable.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        user.set(OTHER_SCREEN, forKey: Key.UserActive.serviceList)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    

    @IBAction func tapedCall(_ sender: Any) {
        // Log event Call agent Event to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.CALL_AGENT_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.CALL_AGENT_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.CALL_AGENT_KEY as NSObject
            ])

        guard let number = URL(string: "telprompt://" + contactSupportNumber) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
        sendInfoDevice()
    }
    
    func initView() {
        completeView.layer.cornerRadius = completeView.frame.width / 2
        cancelView.layer.cornerRadius = cancelView.frame.width / 2
        onHoldView.layer.cornerRadius = onHoldView.frame.width / 2
        serviceTable.delegate = self
        serviceTable.dataSource = self
        serviceTable.tableFooterView = UIView()
        for recognizer in self.view.gestureRecognizers ?? [] {
             self.view.removeGestureRecognizer(recognizer)
        }
        
        
        
    }
    
    func getServiceList() {
        guard caseId != nil else {
            return
        }
        let id:Int = caseId!
        let url = ServerConfigure.url + ServerConfigure.Path.serviceList + String(id)
        loading.showOverlay(view: view)
        RequestService.shareInstance.Get(keyForDictTask: ServerConfigure.Path.serviceList, url, checkAuthen: true, successResponse: {(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                if let resultDic = response.dictData {
                    let success = resultDic[Key.ServiceList.code] as! Int
                    if success == successCode {
                        self.servicelists = []
                        self.servicelists = RequestHelper.shareInstance.extracServiceList(resultDic)
                        //self.initAtivationLog()
                        self.serviceTable.reloadData()
                        self.updateTopView()
                        self.enableDoneServie()
//                        self.infoView.isHidden = false
                        let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
                        RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
                    } else {   
                        OperationQueue.main.addOperation {
                            self.showError(message: resultDic["message"] as! String)
                        }
                    }
                }
            }
        }, failureResponse: { (error) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message: self.failLoadMessage, textAction: alertTitleA)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func update() {
//        self.infoView.isHidden = true
    }
    
    func updateTopView() {
        var customerPay = 0
        var coverageAmount = 0
        var total = 0
        for service in servicelists {
            if let pay = service.getCustomerPay() {
                customerPay += pay
            }
            
            if let pay = service.getCoverageAmount() {
                coverageAmount += pay
            }
            
            if let pay = service.getTotalFee() {
                total += pay
            }
            
            if let pay = service.getTotalAdjust() {
                total += pay
            }
            
        }
        //totalFee.text = String(total)
        priceLabel.text = Currency.RM.rawValue + String(customerPay)
      //  coverageLabel.text = String(coverageAmount)
    }
    
//    func initAtivationLog() {
//        listAtivationLog = []
//        for service in servicelists {
//            if let activations = service.getActivationLog() {
//                for activation in activations {
//                    self.listAtivationLog.append(activation)
//                }
//            }
//           
//        }
//    }
    
    // MARK: - UITABLE DELEGATE AND DATASource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servicelists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProviderTopViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProviderTopViewCell
        //let info: ServiceList = self.servicelists[indexPath.row]
        cell.serviceName.text = self.servicelists[indexPath.row].getServiceType()
        cell.providerName.text = "Service provider: " + self.servicelists[indexPath.row].getProviderName()!
        //cell.childName.text = info.getServiceAddition()
//        if let parentPrice = info.getServiceParentPrice(){
//           cell.parentFee.text = String(parentPrice)
//        }
        
//        if let childPrice = info.getAdditionServicePrice() {
//            cell.childFee.text = String(childPrice)
//        }
//        
//        if let adjFee = info.getAdjust() {
//            cell.adjFee.text = String(adjFee)
//        }
        
        let status = self.servicelists[indexPath.row].getStatus()
        if status == COMPLETED {
            cell.status.backgroundColor = UIColor.init(red: 80/255, green: 203/255, blue: 60/255, alpha: 1.0)
            
            if let total = self.servicelists[indexPath.row].getCustomerPay() {
                if total > 0 {
                    cell.providerPrice.text = Currency.RM.rawValue + String(total)
                } else {
                    setFreePrice(label: cell.providerPrice)
                }
            } else {
                setFreePrice(label: cell.providerPrice)
            }

        } else if status == ACTIVE {
            cell.status.backgroundColor = UIColor.init(red: 243/255, green: 224/255, blue: 16/255, alpha: 1.0)
            
            if let total = self.servicelists[indexPath.row].getCustomerPay() {
                if total > 0 {
                    cell.providerPrice.text = Currency.RM.rawValue + String(total)
                } else {
                    setFreePrice(label: cell.providerPrice)
                    
                }
                
            } else {
                setFreePrice(label: cell.providerPrice)
            }

        } else {
            cell.status.backgroundColor = UIColor.init(red: 255/255, green: 77/255, blue: 58/255, alpha: 1.0)
            
            if let total = self.servicelists[indexPath.row].getCustomerPay() {
                if total > 0 {
                    cell.providerPrice.text = Currency.RM.rawValue + String(total)
                } else {
                    setFreePrice(label: cell.providerPrice)
                }
            } else {
                setFreePrice(label: cell.providerPrice)
            }

            setBlackColor(view: cell.serviceName)
            setBlackColor(view: cell.providerName)
            //setBlackColor(view: cell.parentFee)
//            setBlackColor(view: cell.childName)
            //setBlackColor(view: cell.childFee)
            setBlackColor(view: cell.providerPrice)
            //setBlackColor(view: cell.adjFee)
            //setBlackColor(view: cell.adj)
            //setBlackColor(view: cell.fee)
           // setBlackColor(view: cell.total)
        }
        
        
        return cell
    }
    
    func setFreePrice(label: UILabel) {
        label.text = "Free"
        label.textColor = UIColor.init(red: 108/255, green: 108/255, blue: 108/255, alpha: 1.0)
    }
    
    func setBlackColor(view: UILabel) {
       view.textColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let serviceDitail = getControllerID(id: .serviceDetail) as! ServiceDetailViewController
//        serviceDitail.pagePosition = indexPath.row
//        serviceDitail.serviceList = listAtivationLog
//        self.navigationController?.pushViewController(serviceDitail, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // Override to support conditional editing of the table view.
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let service = servicelists[indexPath.row]
        if (service.getStatus() == ACTIVE) {
            return false // True
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
       
        let cancel = UITableViewRowAction(style: .normal, title: "Cancel") { action, index in
            self.confirmCancel(position: editActionsForRowAt.row)
        }
        cancel.backgroundColor = UIColor.black
        return [cancel]
    }
    
    
    
   // MARK: -  Cancel Service
    func confirmCancel(position: Int) {
        let alert = UIAlertController.init(title: confirm, message: cancelServiceMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: alertTitleA, style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            //self.requestCancel(position: position)
            let cancellation = getControllerID(id: .cancellation) as! CancellationViewController
            cancellation.service = self.servicelists[position]
            self.navigationController?.pushViewController(cancellation, animated: true)
        }))
        alert.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func requestCancel(position: Int) {
        self.loading.showOverlay(view: view)
        let service = self.servicelists[position]
        
        let body = ["note": ""] as Dictionary<String, String>
        if let id = service.getServiceId() {
            let url = ServerConfigure.url + ServerConfigure.Path.cancelService + String(id)
            RequestService.shareInstance.putRequest(keyForDictTask: ServerConfigure.Path.cancelService, url,body:body, isCheckOuthen: true, successRespose: {(response) in
                OperationQueue.main.addOperation {
                    self.loading.hideOverlayView()
                }
                if let dictionResult = response.dictData {
                    let success = dictionResult[Key.CancelAssitance.code] as! Int
                    if (success == successCode) {
                        if let isConfirm = dictionResult[Key.CancelAssitance.confirm] {
                            let alert = UIAlertController.init(title: waring, message: dictionResult[Key.CancelAssitance.message] as? String, preferredStyle: .alert)
                            let ok = UIAlertAction.init(title: "OK", style: .default, handler: {(action) in
                                self.cancelConfirm(confirm: isConfirm as! Int, id: id, body: body)
                                alert.dismiss(animated: true, completion: nil)
                            })
                            let cancel = UIAlertAction.init(title: "Cancel", style: .default, handler: {(action) in
                                alert.dismiss(animated: true, completion: nil)
                            })
                            alert.addAction(ok)
                            alert.addAction(cancel)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            OperationQueue.main.addOperation {
                                self.showSuccess(message: dictionResult[Key.CancelAssitance.message] as! String)
                            }
                            
                        }
                        
                        
                    }
                }
            }, failureResponse: {(error) in
                OperationQueue.main.addOperation {
                    self.showError(message: failMessage)
                    self.loading.hideOverlayView()
                }
                
            })
        }
    }
    
    func cancelConfirm(confirm: Int, id: Int, body: Dictionary<String, String>) {
        loading.showOverlay(view: view)
        let url = ServerConfigure.url + ServerConfigure.Path.cancelServiceConfirm + String(id)
        RequestService.shareInstance.putRequest(keyForDictTask: ServerConfigure.Path.cancelServiceConfirm, url, body: body, isCheckOuthen: true, successRespose: {(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            if let dictionResult = response.dictData {
                let success = dictionResult[Key.CancelAssitance.code] as! Int
                if (success == successCode) {
                    self.showSuccess(message: dictionResult[Key.CancelAssitance.message] as! String)
                }
            }
        }, failureResponse: {(error) in
            OperationQueue.main.addOperation {
                self.showError(message: failMessage)
                self.loading.hideOverlayView()
            }
            
        })
        
    }
    
    func showSuccess(message: String) {
        let alert = UIAlertController.init(title: "Success", message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: {(action) in
            
            self.getServiceList()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    
    
    // MARK: - Other method
    func enableDoneServie() {
        if checkDoneService() {
            doneButton.isHidden = false
        } else {
            doneButton.isHidden = true
        }
    }
    
    func checkDoneService()-> Bool {
        for service in servicelists {
            if service.getStatus() == ACTIVE {
                return false
            }
        }
        return true
    }
    
    @IBAction func tappedDone(_ sender: Any) {
        let rating = getControllerID(id: .remarkAndRate) as! RatingViewController
        rating.caseId = self.caseId
        self.navigationController?.pushViewController(rating, animated: true)
    }
    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }

}
