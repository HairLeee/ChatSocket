//
//  CancellationViewController.swift
//  RSAMobile
//
//  Created by Nguyen Van Trung on 6/5/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class CancellationViewController: UIViewController {

    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    var service: ServiceList?
    let loading = LoadingOverlay()
    override func viewDidLoad() {
        super.viewDidLoad()
        note.layer.cornerRadius = 5.0
        note.layer.borderWidth = 1.0
        
        note.layer.borderColor = UIColor.init(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0).cgColor
        self.hideKeyboardWhenTappedAround()
        submitButton.setBackgroundImage(UIImage(named: "btn_hover"), for: .highlighted)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

 
    @IBAction func tapedBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedSubmit(_ sender: Any) {
        self.view.endEditing(true)
        requestCancel()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func requestCancel() {
//        self.loading.showOverlay(view: view)
//        let body = ["note": note.text] as Dictionary<String, String>
//        if let id = service?.getActivationLogId() {
//            let url = ServerConfigure.url + ServerConfigure.Path.cancelService + String(id)
//            RequestService.shareInstance.putRequest(url,body:body, isCheckOuthen: true, successRespose: {(response) in
//                OperationQueue.main.addOperation {
//                    self.loading.hideOverlayView()
//                }
//                if let dictionResult = response.dictData {
//                    let success = dictionResult[Key.CancelAssitance.code] as! Int
//                    if (success == successCode) {
//                        if let confirm = dictionResult[Key.CancelAssitance.confirm] {
//                            let alert = UIAlertController.init(title: waring, message: dictionResult[Key.CancelAssitance.message] as? String, preferredStyle: .alert)
//                            let ok = UIAlertAction.init(title: "OK", style: .default, handler: {(action) in
//                                self.cancelConfirm(confirm: confirm as! Int, id: id, body: body)
//                                alert.dismiss(animated: true, completion: nil)
//                            })
//                            let cancel = UIAlertAction.init(title: "Cancel", style: .default, handler: {(action) in
//                                alert.dismiss(animated: true, completion: nil)
//                            })
//                            alert.addAction(ok)
//                            alert.addAction(cancel)
//                            self.present(alert, animated: true, completion: nil)
//                        } else {
//                            OperationQueue.main.addOperation {
//                                self.showSuccess(message: dictionResult[Key.CancelAssitance.message] as! String)
//                            }
//                            
//                        }
//                        
//                        
//                    }
//                }
//            }, failureResponse: {(error) in
//                OperationQueue.main.addOperation {
//                    self.showError(message: failMessage)
//                    self.loading.hideOverlayView()
//                }
//                
//            })
//        }
    }
    
    func cancelConfirm(confirm: Int, id: Int, body: Dictionary<String, String>) {
        loading.showOverlay(view: view)
        let url = ServerConfigure.url + ServerConfigure.Path.cancelServiceConfirm + String(id)
        RequestService.shareInstance.putRequest(keyForDictTask: ServerConfigure.Path.cancelServiceConfirm, url, body: body, isCheckOuthen: true, successRespose: {(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                if let dictionResult = response.dictData {
                    let success = dictionResult[Key.CancelAssitance.code] as! Int
                    if (success == successCode) {
                        self.showSuccess(message: dictionResult[Key.CancelAssitance.message] as! String)
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
    
    func showSuccess(message: String) {
        let alert = UIAlertController.init(title: "Success", message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: {(action) in
            //            self.serviceList.remove(at: self.pagePosition!)
            //            self.initTopView()
            //            self.setupPageScrollView();
            let user = UserDefaults.standard
            user.set(CANCEL_SERVICE, forKey: Key.UserActive.cancelService)
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }


    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }

}
