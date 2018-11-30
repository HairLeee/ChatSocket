//
//  EditInfoViewController.swift
//  RSAMobile
//
//  Created by tanchong on 4/3/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import AVFoundation

class ChangePasswordViewController: BaseViewController, UITextFieldDelegate {

    
    @IBOutlet weak var currentPassTextField: BorderBottomTextField!
    @IBOutlet weak var newPassTestField: BorderBottomTextField!
    @IBOutlet weak var reNewPTextField: BorderBottomTextField!
    @IBOutlet weak var changeButton: UIButton!
    
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var containerView: UIView!
    
    let currentPassTag = 2
    let passwordTag = 3
    let rePassTag = 4
    var errorTag = 0
    let loading = LoadingOverlay()
    var mobileFormat:MobileFormat?
    let maxLength = 11
    
    let failMessage = "Fail to edit profile. Had some problem while connecting to server!"
    
    //var mainStoryboard: UIStoryboard?
    let userHelper = UserHelper()
    override func loadView() {
        super.loadView()
        currentPassTextField.highLightType = HighLightTextField.HighLightBorder
        reNewPTextField.highLightType = HighLightTextField.HighLightBorder
        newPassTestField.highLightType = HighLightTextField.HighLightBorder
        currentPassTextField.addBottomLine()
        reNewPTextField.addBottomLine()
        newPassTestField.addBottomLine()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loading.center = view.center
        view.addSubview(loading)
        let userDefault = UserDefaults.standard
        userType = userDefault.integer(forKey: Key.USER_TYPE)
        initView()
        self.title = "Change Password"
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
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func initView() {
//        currentPassTextField.leftViewMode = .always
//        currentPassTextField.leftView = UIImageView(image: UIImage(named: "pw"))
//        newPassTestField.leftViewMode = .always
//        newPassTestField.leftView = UIImageView(image: UIImage(named: "pw"))
//        reNewPTextField.leftViewMode = .always
//        reNewPTextField.leftView = UIImageView(image: UIImage(named: "re-pw"))

        currentPassTextField.delegate = self
        reNewPTextField.delegate = self
        newPassTestField.delegate = self
        currentPassTextField.tag = currentPassTag
        newPassTestField.tag = passwordTag
        reNewPTextField.tag = rePassTag
       // scrollView.isScrollEnabled = false
        currentPassTextField.bottomLineColor = UIColor.gray
        newPassTestField.bottomLineColor = UIColor.gray
        reNewPTextField.bottomLineColor = UIColor.gray
        changeButton.setBackgroundImage(UIImage(named: "btn_hover"), for: .highlighted)
        changeButton.setTitleColor(UIColor.black, for: .highlighted)
//        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
//        self.navigationController?.navigationBar.backItem?.title = ""
    }

    
    // MARK: - Send data to server
    @IBAction func tapedDone(_ sender: Any) {
        if (self.validInfo() == false) {
            return
        }
        let url = ServerConfigure.url + ServerConfigure.Path.userChangeInfo
        if UtilHelper.shareInstance.isInternetAvailable() == false {
            self.showError(message: internetNotconnect)
            return
        }
        
        
        loading.showOverlay(view: view)
        RequestService.shareInstance.PostRequest(keyForDictTask: ServerConfigure.Path.userChangeInfo, url, param: getBody(), imageData: nil, isCheckOuthen: true, successRespose: {(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            if let dictionResult = response.dictData {
                let success = dictionResult["code"] as! Int
                if (success == successCode) {
                    OperationQueue.main.addOperation {
                        UserDefaults.standard.set(self.newPassTestField.text, forKey: Key.CURRENT_PASSWOR)
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    OperationQueue.main.addOperation {
                        self.showError(message: dictionResult["message"] as! String)
                    }
                }
            }else {
                OperationQueue.main.addOperation {
                    self.showError(message: self.failMessage)
                }
            }

        }, failureResponse: {(error) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                self.showError(message: self.failMessage)
            }
        })
        
        
    }
    
    @IBAction func tapedBack(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    func validInfo()->Bool {
//        var changePass = false;
//        if ((newPassTestField.text?.characters.count)! > 0) {
//            changePass = true
//        }
//        if ((currentPassTextField.text?.characters.count)! > 0) {
//            changePass = true
//        }
//        if ((reNewPTextField.text?.characters.count)! > 0) {
//            changePass = true
//        }
        // Password
       
        if  currentPassTextField.text == nil || (currentPassTextField.text?.characters.count)! < 1 {
            popTip?.showText(require, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.view, fromFrame: self.currentPassTextField.frame)
            currentPassTextField.bottomLineColor = UIColor.red
            errorTag =  passwordTag
            return false
        }
            var validPass = false
            if let curPass = UserDefaults.standard.value(forKey: Key.CURRENT_PASSWOR) as? String {
                if curPass == currentPassTextField.text {
//                    if curPass != newPassTestField.text {
//                        validPass = true
//                    }
                    validPass = true
                }
            }
            if validPass == false {
                popTip?.showText(currentPassw, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.view, fromFrame: self.currentPassTextField.frame)
                errorTag = currentPassTag
                currentPassTextField.bottomLineColor = UIColor.red
                return false
            }
            
            if  newPassTestField.text == nil || (newPassTestField.text?.characters.count)! < 1 {
                popTip?.showText(passwordGuide, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.view, fromFrame: self.newPassTestField.frame)
                newPassTestField.bottomLineColor = UIColor.red
                errorTag =  passwordTag
                return false
            }
            
            if let curPass = UserDefaults.standard.value(forKey: Key.CURRENT_PASSWOR) as? String {
                if  curPass == newPassTestField.text {
                    popTip?.showText(passwordNotTheSame, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.view, fromFrame: self.newPassTestField.frame)
                    newPassTestField.bottomLineColor = UIColor.red
                    errorTag =  passwordTag
                    return false
                }
            }
            
            if (UtilHelper.shareInstance.isValidPassword(pass: newPassTestField.text!) == false) {
                popTip?.showText(passwordGuide, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.view, fromFrame: self.newPassTestField.frame)
                newPassTestField.bottomLineColor = UIColor.red
                errorTag = passwordTag
                return false
                
            }
            
            if  reNewPTextField.text == nil || (reNewPTextField.text?.characters.count)! < 1 {
                popTip?.showText(passwordNotMacth, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.view, fromFrame: self.reNewPTextField.frame)
                errorTag = rePassTag
                return false
            }
            
            let comparePass = UtilHelper.shareInstance.compareString(root: newPassTestField.text!, comapre: reNewPTextField.text!)
            if comparePass == false {
                popTip?.showText(passwordNotMacth, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.view, fromFrame: self.reNewPTextField.frame)
                reNewPTextField.bottomLineColor = UIColor.red
                errorTag = rePassTag
                return false
            }
            
        
        
        return true
    }
    
    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showSuccess(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: "Success", message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITEXTFIELD delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
       // self.scrollView.isScrollEnabled = false
        if textField.tag == errorTag  {
            popTip?.hide()
        }
        switch textField.tag {
        case currentPassTag:
            currentPassTextField.bottomLineColor = UIColor.black
            break
        case passwordTag:
            newPassTestField.bottomLineColor = UIColor.black
            break
        case rePassTag:
            reNewPTextField.bottomLineColor = UIColor.black
            break
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.scrollView.scrollToTop()
//        self.scrollView.isScrollEnabled = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        let maxLength = TEXT_MAX_LENGHT
        if (isBackSpace == -92) {
            return true
        }
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }

    
    
    func getBody()-> Dictionary<String, String> {
        var body = [Key.EditUserInfo.newPassword: "", Key.EditUserInfo.confirmPas: ""] as Dictionary<String, String>
        body[Key.EditUserInfo.newPassword] = newPassTestField.text != nil ? newPassTestField.text : ""
        body[Key.EditUserInfo.confirmPas] = reNewPTextField.text != nil ? reNewPTextField.text : ""
        return body
    }
    
}
