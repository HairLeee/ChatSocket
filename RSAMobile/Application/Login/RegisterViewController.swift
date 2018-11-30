//
//  RegisterViewController.swift
//  RSAMobile
//
//  Created by tanchong on 3/29/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import Firebase
class RegisterViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTextFiled: BorderBottomTextField!
    @IBOutlet weak var emailTextFiled: BorderBottomTextField!
    @IBOutlet weak var phoneNumberTF: BorderBottomTextField!
    @IBOutlet weak var passwordTextFiled: BorderBottomTextField!
    @IBOutlet weak var rePassTextFiled: BorderBottomTextField!
   // @IBOutlet weak var containerView: UIView!
    var mobileFormat:MobileFormat?
   
  //  @IBOutlet weak var scrollView: UIScrollView!
    let userNameTag = 5
    let phoneTag = 1
    let passwordTag = 2
    let rePassTag = 3
    let emailTag = 4
    var tagError = 0;
    let userHelper = UserHelper()
     let failMessage = "Fail to register, Had some problem while connecting to server!"
    //var mainStoryboard: UIStoryboard?
    let loading = LoadingOverlay()
    override func loadView() {
        super.loadView()
        userNameTextFiled.highLightType = HighLightTextField.HighLightPadding
        emailTextFiled.highLightType = HighLightTextField.HighLightPadding
        phoneNumberTF.highLightType = HighLightTextField.HighLightPadding
        passwordTextFiled.highLightType = HighLightTextField.HighLightPadding
        rePassTextFiled.highLightType = HighLightTextField.HighLightPadding
        userNameTextFiled.addBottomLine()
        emailTextFiled.addBottomLine()
        phoneNumberTF.addBottomLine()
        passwordTextFiled.addBottomLine()
        rePassTextFiled.addBottomLine()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        //mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        

    }
    
    func initView() {
        userNameTextFiled.leftViewMode = .always
        userNameTextFiled.leftView = UIImageView(image: UIImage(named: "user"))
        emailTextFiled.leftViewMode = .always
        emailTextFiled.leftView = UIImageView(image: UIImage(named: "re_email"))
        phoneNumberTF.leftViewMode = .always
        phoneNumberTF.leftView = UIImageView(image: UIImage(named: "mobile"))
        passwordTextFiled.leftViewMode = .always
        passwordTextFiled.leftView = UIImageView(image: UIImage(named: "pw"))
        rePassTextFiled.leftViewMode = .always
        rePassTextFiled.leftView = UIImageView(image: UIImage(named: "re-pw"))
        emailTextFiled.keyboardType = .emailAddress
        
        userNameTextFiled.bottomLineColor = UIColor.init(red: 255.0/255.0, green: 229.0/255.0, blue: 152/255, alpha: 1.0)
        emailTextFiled.bottomLineColor = UIColor.init(red: 255.0/255.0, green: 229.0/255.0, blue: 152/255, alpha: 1.0)
        phoneNumberTF.bottomLineColor = UIColor.init(red: 255.0/255.0, green: 229.0/255.0, blue: 152/255, alpha: 1.0)
        passwordTextFiled.bottomLineColor = UIColor.init(red: 255.0/255.0, green: 229.0/255.0, blue: 152/255, alpha: 1.0)
        rePassTextFiled.bottomLineColor = UIColor.init(red: 255.0/255.0, green: 229.0/255.0, blue: 152/255, alpha: 1.0)
        //scrollView.isScrollEnabled = false
        
        phoneNumberTF.delegate = self
        passwordTextFiled.delegate = self
        rePassTextFiled.delegate = self
        emailTextFiled.delegate = self
        phoneNumberTF.tag = phoneTag
        userNameTextFiled.tag = userNameTag
        passwordTextFiled.tag = passwordTag
        rePassTextFiled.tag = rePassTag
        emailTextFiled.tag = emailTag
        userNameTextFiled.delegate = self
        
//        let close = UIButton(type: .custom)
//        close.setImage(UIImage(named: "re_done"), for: .normal)
//        close.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        close.addTarget(self, action: #selector(self.tapedDone(_sender:)), for: .touchUpInside)
//        let item = UIBarButtonItem(customView: close)
//        self.navigationItem.setRightBarButtonItems([item], animated: true)
//        self.navigationItem.title = "Register"
//        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
//        
//        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "close")
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "close")
//        self.navigationController?.navigationBar.backItem?.title = ""
        
    }
    


    @IBAction func tapedCancel(_ sender: Any) {
//        let controller = getControllerID(id: .Login)
//        getMainNavigation()?.setViewControllers([controller], animated: true)
        _ = navigationController?.popViewController(animated: true)
    }
    
    func tapedClose(_sender: Any) {
        let controller = getControllerID(id: .Login)
        getMainNavigation()?.setViewControllers([controller], animated: true)
    }
    @IBAction func tappedDone(_ sender: Any) {
        doneRegister()
    }
    
    func doneRegister() {
        // Log event register account to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.REGISTER_ACCOUNT_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.REGISTER_ACCOUNT_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.REGISTER_ACCOUNT_KEY as NSObject
            ])

        if self.validateInfo() == false {
            return
        }
        let body = getBody()
        let url = ServerConfigure.url + ServerConfigure.Path.register
        if UtilHelper.shareInstance.isInternetAvailable() == false {
            self.showError(message: internetNotconnect)
            return
        }
        loading.showOverlay(view: view)
        RequestService.shareInstance.Post(keyForDictTask: ServerConfigure.Path.register, url, body: body, isCheckOuthen: false, successRespose: {(responseData) in
            
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            if let dictResult = responseData.dictData {
                let success = dictResult["code"] as! Int
                if success == successCode {
                    
                    if self.userHelper.extractUser(dictResult) == true {
                        OperationQueue.main.addOperation {
                            self.userType = systemUser
                            self.removeKeyValuePreviousUser()
                            let user = UserDefaults.standard
                            _ = self.userHelper.extractUser(dictResult)
                            user.set(self.userType, forKey: Key.USER_TYPE)
                            user.synchronize()
                            self.sendTokenDivce()
                        }
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
    func removeKeyValuePreviousUser() -> Void {
        let user = UserDefaults.standard
        user.set(nil, forKey: Key.UserActive.cancelService)
        user.set(nil, forKey: Key.USER_TYPE)
        user.set(nil, forKey: Key.LocalKey.caseId)
        user.set(nil, forKey: Key.LocalKey.doneRequest)
        user.set(nil, forKey: Key.UserActive.serviceList)
        user.set(nil, forKey: Key.LocalKey.doneRequest)
        user.set(nil, forKey: Key.LocalKey.userCancel)
        user.synchronize()

    }
    func sendTokenDivce() {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            let body = ["token": refreshedToken] as Dictionary<String, String>
            let url = ServerConfigure.url + ServerConfigure.Path.token
            loading.showOverlay(view: view)
            RequestService.shareInstance.putRequest(keyForDictTask: ServerConfigure.Path.token, url, body: body, isCheckOuthen: true, successRespose: {(response) in
                if let dicResult = response.dictData {
                    let success = dicResult["code"] as! Int
                    if success != successCode {
                        self.sendTokenDivce()
                    }
                }
                OperationQueue.main.addOperation {
                    self.loading.hideOverlayView()
                    self.gotoVerify()
                }
            } , failureResponse:  { (error) in
                OperationQueue.main.addOperation {
                    self.loading.hideOverlayView()
                    self.gotoVerify()
                }
                self.sendTokenDivce()
            })
        }
        
    }

    
    @IBAction func tapedRegister(_ sender: Any) {
        if self.validateInfo() == false {
            return
        }
        let body = getBody()
        let url = ServerConfigure.url + ServerConfigure.Path.register
        if UtilHelper.shareInstance.isInternetAvailable() == false {
            self.showError(message: internetNotconnect)
            return
        }
        loading.showOverlay(view: view)
        RequestService.shareInstance.Post(keyForDictTask: ServerConfigure.Path.register, url, body: body, isCheckOuthen: false, successRespose: {(responseData) in
            
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            if let dictResult = responseData.dictData {
                let success = dictResult["code"] as! Int
                if success == successCode {
                    if self.userHelper.extractUser(dictResult) == true {
                        OperationQueue.main.addOperation {
                            self.userType = systemUser
                            let user = UserDefaults.standard
                            user.set(self.userType, forKey: Key.USER_TYPE)
                            self.gotoVerify()
                        }
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
    
    func validateInfo() -> Bool {
        
        // Phone
        if  phoneNumberTF.text == nil || (phoneNumberTF.text?.characters.count)! < 1{
            popTip?.showText(require, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: view, fromFrame: self.phoneNumberTF.frame)
            phoneNumberTF.bottomLineColor = UIColor.red
            tagError = phoneTag
            return false
        }
        let phone = phoneNumberTF.text
        if (phoneNumberTF.text?.characters.count)! < MIN_LENGTH_PHONE {
            popTip?.showText(phoneNumberInvalid, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: view, fromFrame: self.phoneNumberTF.frame)
            phoneNumberTF.bottomLineColor = UIColor.red
            tagError = phoneTag
            return false
        }
        
        if (UtilHelper.shareInstance.validatePhone(mobile: phone!) == false) {
            popTip?.showText(phoneNumberInvalid, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: view, fromFrame: self.phoneNumberTF.frame)
            phoneNumberTF.bottomLineColor = UIColor.red
            tagError = phoneTag
            return false
        }
        
        
        // Email
        if  emailTextFiled.text == nil || (emailTextFiled.text?.characters.count)! < 1 {
            popTip?.showText(require, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: view, fromFrame: self.emailTextFiled.frame)
            emailTextFiled.bottomLineColor = UIColor.red
            tagError = emailTag
            return false
        }

        if UtilHelper.shareInstance.isValidEmail(testStr: emailTextFiled.text!) == false {
            popTip?.showText(validEmail, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: view, fromFrame: self.emailTextFiled.frame)
            emailTextFiled.bottomLineColor = UIColor.red
            tagError = emailTag
            return false
        }
       
       
        // password
        if  passwordTextFiled.text == nil || (passwordTextFiled.text?.characters.count)! < 1 {
            popTip?.showText(require, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: view, fromFrame: self.passwordTextFiled.frame)
            passwordTextFiled.bottomLineColor = UIColor.red
            tagError = passwordTag
            return false
        }
        
        if (UtilHelper.shareInstance.checkLenghtString(text: passwordTextFiled.text!, minLenght: MIN_LENGHT_PASSWORK) == false) {
            popTip?.showText(passwordGuide, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: view, fromFrame: self.passwordTextFiled.frame)
            passwordTextFiled.bottomLineColor = UIColor.red
            tagError = passwordTag
            return false
            
        }
        
        if (UtilHelper.shareInstance.isValidPassword(pass: passwordTextFiled.text!) == false) {
            popTip?.showText(passwordGuide, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: view, fromFrame: self.passwordTextFiled.frame)
            passwordTextFiled.bottomLineColor = UIColor.red
            tagError = passwordTag
            return false
            
        }
        
        if  rePassTextFiled.text == nil || (rePassTextFiled.text?.characters.count)! < 1 {
            popTip?.showText(passwordNotMacth, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: view, fromFrame: self.rePassTextFiled.frame)
            tagError = rePassTag
            return false
        }
        
        
        
        let comparePass = UtilHelper.shareInstance.compareString(root: passwordTextFiled.text!, comapre: rePassTextFiled.text!)
        if comparePass == false {
            popTip?.showText(passwordNotMacth, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: view, fromFrame: self.rePassTextFiled.frame)
            rePassTextFiled.bottomLineColor = UIColor.red
            tagError = rePassTag
            return false
        }
        return true
    }
    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)

    }
    
    func getBody()-> Dictionary<String, String> {
        var body = [Key.Register.userName: "", Key.Register.email: emailTextFiled.text!, Key.Register.mobile: phoneNumberTF.text!,
                    Key.Register.password: passwordTextFiled.text!] as Dictionary<String, String>
        body[Key.Register.userName] = userNameTextFiled.text != nil ? userNameTextFiled.text : ""
        return body
    }
    
    func gotoVerify() -> Void {
        _ = getNavigationWithRootID(id: .AddMoreCar)
    }
    
    // MARK: - UI text filed delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //self.scrollView.isScrollEnabled = true
        if textField.tag == tagError  {
            popTip?.hide()

        }
        switch textField.tag {
        case tagError:
            popTip?.hide()
            break
        case phoneTag:
            phoneNumberTF.bottomLineColor = UIColor.black
            break
        case emailTag:
            emailTextFiled.bottomLineColor = UIColor.black
            break
        case passwordTag:
            passwordTextFiled.bottomLineColor = UIColor.black
            break
        case rePassTag:
            rePassTextFiled.bottomLineColor = UIColor.black
            break
        case userNameTag:
            userNameTextFiled.bottomLineColor = UIColor.black
            break

        default: break
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //scrollView.scrollToTop()
        //self.scrollView.isScrollEnabled = false
        emailTextFiled.bottomLineColor = UIColor.white
        passwordTextFiled.bottomLineColor = UIColor.white
        rePassTextFiled.bottomLineColor = UIColor.white
        phoneNumberTF.bottomLineColor = UIColor.white
        userNameTextFiled.bottomLineColor = UIColor.white
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        var maxLength = PHONE_MAX_LENGHT
        if (isBackSpace == -92) {
            return true
        }
        if (textField.tag == phoneTag) {
            if (mobileFormat == MobileFormat.formatOne) {
                maxLength = PHONE_MAX_LENGHT_LONG
            }
            if (textField.text?.characters.count == 3) {
                if (textField.text == formatOne || textField.text == formatTwo) {
                    mobileFormat = MobileFormat.formatOne
                } else {
                    mobileFormat = MobileFormat.formatThree
                }
                textField.text?.append("-")
            }
            if ((textField.text?.characters.count)! > 5) {
                if (mobileFormat == MobileFormat.formatOne) {
                    if (textField.text?.characters.count == 8) {
                        textField.text?.append(" ")
                    }
                } else {
                    if (textField.text?.characters.count == 7) {
                        textField.text?.append(" ")
                    }
                }
            }
            
        } else {
            maxLength = TEXT_MAX_LENGHT
            
        }
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
}
