//
//  WaitingViewController.swift
//  RSAMobile
//
//  Created by tanchong on 4/21/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
class WaitingViewController: UIViewController {

    var pulse:Pulsing?
    var pulse1: Pulsing?
    var pulse2: Pulsing?
    var caseId: Int?
    let radius = 170
    let loading = LoadingOverlay()
    let user = UserDefaults.standard
    var agent: String?
    let failMessageResponse = "Fail to load data, Had some problem while conneting to server."

   // @IBOutlet weak var ballView: UIView!
    @IBOutlet weak var pulsingButton: UIButton!
    @IBOutlet weak var urgentLabel: UILabel!
    @IBOutlet weak var caseIdLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
        
        user.set(NEW_REQUEST, forKey: Key.LocalKey.doneRequest)
        user.set(caseId, forKey: Key.LocalKey.caseId)
        if let agent = self.agent {
            urgentLabel.text = "Our agent " + agent + " has picked up your request. He will contact you soon."
        }
        if let casid = caseId {
            let caseString = "Your Case ID: " + String(casid)
            caseIdLabel.text = caseString
        }
        self.getCaseStatus(caseId: caseId!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let x = 0
        let y = 0
        let frame = CGRect(x: x, y: y, width: 100, height: 50)
        let dotAnimation = NVActivityIndicatorView(frame: frame,
                                                            type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballPulse.rawValue)!)
        dotAnimation.startAnimating()
       // ballView.addSubview(dotAnimation)
        
        let frame2 = CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height/2 - 150, width: 300, height: 300)
        let roundAnimation = NVActivityIndicatorView(frame: frame2,
                                                            type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballScaleMultiple.rawValue)!)
        roundAnimation.startAnimating()
        //view.addSubview(activityIndicatorView1)
        self.view.layer.insertSublayer(roundAnimation.layer, below: pulsingButton.layer)

    }
    
    func getCaseStatus(caseId: Int) {
        let url = ServerConfigure.url + (ServerConfigure.Path.getCaseStatus + String.init(stringInterpolationSegment: caseId))
        loading.showOverlay(view: view)
        let user = UserHelper();
        let headers: HTTPHeaders = [
            "Authorization": user.getTokenUser()!,
            "Accept": "application/json"
        ]
        
        Alamofire.request(url, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                OperationQueue.main.addOperation {
                    self.loading.hideOverlayView()
                }
                let jsonDictionary = response.value as? NSDictionary
                let success = jsonDictionary?["success"] as! Int
                if success == successCode {
                    let status: CaseStatus? = CaseStatus(rawValue: UInt8(jsonDictionary?["status"] as! Int) - 1 )
                    switch status! {
                    case .new_case:
                        // continue execute this case
                        break
                    case .close_case:
                        self.backViewController()
                        break
                    case .close_case_unsolve:
                        self.backViewController()
                        break
                    case .hold_case:
                        // continue execute this case
                        break
                    case .cancel_case:
                        self.backViewController()
                        break
                    case .service_active:
                        // continue execute this case
                        break
                        
                    }
                    
                } else {
                    OperationQueue.main.addOperation {
                        self.showError(message: jsonDictionary?["message"] as! String)
                    }
                }

            case .failure( _):
                OperationQueue.main.addOperation {
                    self.loading.hideOverlayView()
                    let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message: self.failMessageResponse, textAction: alertTitleA)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    func backViewController() -> Void {
        self.user.set(0, forKey: Key.LocalKey.caseId)
        self.user.set(USER_CACEL_CASE, forKey: Key.LocalKey.userCancel)
        let request = getControllerID(id: .RequestAssistance)
        self.navigationController?.pushViewController(request, animated: true)
    }
    @IBAction func tapedCancel(_ sender: Any) {
        let alert = UIAlertController.init(title: "Confirm", message: cancelRequest, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: alertTitleA, style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            self.canceRequest()
        }))
        alert.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func canceRequest() {
        self.loading.showOverlay(view: view)
        if let id = caseId {
            let url = ServerConfigure.url + ServerConfigure.Path.cancelRequest + String(id)
            RequestService.shareInstance.Put(keyForDictTask: ServerConfigure.Path.cancelRequest, url, checkAuthen: true, successResponse: {(response) in
                OperationQueue.main.addOperation {
                    self.loading.hideOverlayView()
                }
                if let dictionResult = response.dictData {
                    let success = dictionResult[Key.CancelAssitance.code] as! Int
                    if (success == successCode) {
                        if let confirm = dictionResult[Key.CancelAssitance.confirm] {
                            let alert = UIAlertController.init(title: "Comfirm", message: dictionResult[Key.CancelAssitance.message] as? String, preferredStyle: .alert)
                            let ok = UIAlertAction.init(title: "OK", style: .default, handler: {(action) in
                                self.cancelConfirm(confirm: confirm as! Int)
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
                        
                        
                    }else {
                        OperationQueue.main.addOperation {
                            self.showError(message: dictionResult[Key.CancelAssitance.message] as! String)

                        }
                    }
                }
            }, failureResponse: {(error) in
                OperationQueue.main.addOperation {
                    self.showError(message: failMessage)
                    self.loading.hideOverlayView()
                }
                
            })
        } else {
            let request = getControllerID(id: .RequestAssistance)
            self.navigationController?.pushViewController(request, animated: true)
            
        }

    }
    
    
    func cancelConfirm(confirm: Int) {
        loading.showOverlay(view: view)
        if let id = caseId {
            let url = ServerConfigure.url + ServerConfigure.Path.cancelConfirm + String(id)
            RequestService.shareInstance.Put(keyForDictTask: ServerConfigure.Path.cancelConfirm, url, checkAuthen: true, successResponse: {(response) in
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
        } else {
            let request = getControllerID(id: .RequestAssistance)
            self.navigationController?.pushViewController(request, animated: true)
            
        }

    }
    
    @IBAction func tapedCallButton(_ sender: Any) {
        guard let number = URL(string: "telprompt://" + contactSupportNumber) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
        sendInfoDevice()
        
    }
    
    func showSuccess(message: String) {
        let alert = UIAlertController.init(title: "Success", message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: {(action) in
            self.user.set(0, forKey: Key.LocalKey.caseId)
            self.user.set(USER_CACEL_CASE, forKey: Key.LocalKey.userCancel)
            let request = getControllerID(id: .RequestAssistance)
            self.navigationController?.pushViewController(request, animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func taped(_ sender: Any) {
//        let doneRequest = getControllerID(id: .serviceProvider) as! DoneRequestViewController
//        doneRequest.caseId = self.caseId
//        self.navigationController?.pushViewController(doneRequest, animated: true)
        
    }
    
}
