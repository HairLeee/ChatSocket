//
//  ForgotPassViewController.swift
//  RSAMobile
//
//  Created by tanchong on 3/31/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class ForgotPassViewController: BaseViewController, UITextFieldDelegate {

    let failMessage = "Fail to send data"
    
    @IBOutlet weak var btn_send: UIButton!
    @IBOutlet weak var emailTextfield: BorderBottomTextField!
    //var mainStoryboad: UIStoryboard?
    let loading = LoadingOverlay()
    
    override func loadView() {
        super.loadView()
        emailTextfield.highLightType = HighLightTextField.HighLightPadding
        emailTextfield.addBottomLine()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //mainStoryboad = UIStoryboard(name: "Main", bundle: nil)
        emailTextfield.highLightType = HighLightTextField.HighLightPadding
        emailTextfield.bottomLineColor = UIColor.lightGray
        emailTextfield.delegate = self
        emailTextfield.leftViewMode = .always
        emailTextfield.leftView = UIImageView(image: UIImage(named: "email_reset"))
        self.hideKeyboardWhenTappedAround()
        btn_send.setBackgroundImage(UIImage(named: "btn_hover"), for: .highlighted)
        btn_send.setTitleColor(UIColor.white, for: .highlighted)
        self.navigationItem.title = "Forgot Password"
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // This will show in the next view controller being pushed
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func tapedBack(_ sender: Any) {
        self.backToLogin()
    }

   
    @IBAction func tapedSend(_ sender: Any) {
        if emailTextfield.text == nil || (emailTextfield.text?.characters.count)! < 0 {
            popTip?.showText(emailError, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.view, fromFrame: self.emailTextfield.frame)
            emailTextfield.bottomLineColor = UIColor.red
            return
        }
        
        if UtilHelper.shareInstance.isValidEmail(testStr: emailTextfield.text!) == false {
            popTip?.showText(emailInValid, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.view, fromFrame: self.emailTextfield.frame)
            emailTextfield.bottomLineColor = UIColor.red
            return
        }
        if UtilHelper.shareInstance.isInternetAvailable() == false {
            self.showError(message: internetNotconnect)
            return
        }
        let body = [Key.ForgotPass.email: emailTextfield.text!] as Dictionary<String, String>
        let url = ServerConfigure.url + ServerConfigure.Path.forgotPassword
        loading.showOverlay(view: self.view)
        RequestService.shareInstance.Post(keyForDictTask: ServerConfigure.Path.forgotPassword, url, body: body, isCheckOuthen: false, successRespose: {(responseData) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            if let dictionResult = responseData.dictData {
                let success = dictionResult["code"] as! Int
                if success == 0 {
                    OperationQueue.main.addOperation {
                        self.showSuccess(message: dictionResult["message"] as! String)
                    }

                } else {
                    OperationQueue.main.addOperation {
                        self.showError(message: dictionResult["message"] as! String)
                    }
                }
            }
        
        }, failureResponse: {(error) in
            OperationQueue.main.addOperation {
                self.showError(message: self.failMessage)
                self.loading.hideOverlayView()
            }
        })
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showSuccess(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: "Success", message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }
   
    func backToLogin() -> Void {
//        let login = getControllerID(id: .Login)     //mainStoryboad?.instantiateViewController(withIdentifier: "loginController") as! LoginViewController
//        self.present(login, animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UI text field delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        popTip?.hide()
        emailTextfield.bottomLineColor = UIColor.black
    }

}
