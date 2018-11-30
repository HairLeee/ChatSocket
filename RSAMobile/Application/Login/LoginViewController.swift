//
//  ViewController.swift
//  RSAMobile
//
//  Created by LinhTY on 3/23/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import Google
import Darwin
import Firebase
class LoginViewController: BaseViewController, GIDSignInDelegate, GIDSignInUIDelegate, UITextFieldDelegate {

    //var mainStoryboard: UIStoryboard?
    var error: NSError?
    let failMessage = "Fail to login, Had some problem while conneting to server."
    let userHelper = UserHelper()
    let loading = LoadingOverlay()
    let phoneTag = 2
    var mobileFormat:MobileFormat?
    let emailTag = 1
    var errorTag = 0
    
    @IBOutlet weak var userTextField: BorderBottomTextField!
    @IBOutlet weak var passwordTextField: BorderBottomTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var faceButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var callButton: UIButton!

    override func loadView() {
        super.loadView()
        userTextField.highLightType = HighLightTextField.HighLightPadding
        passwordTextField.highLightType = HighLightTextField.HighLightPadding
        userTextField.addBottomLine()
        passwordTextField.addBottomLine()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        GGLContext.sharedInstance().configureWithError(&error)
        if (error != nil) {
//            print(error ?? "")
            return
        }
        loading.center = view.center
        view.addSubview(loading)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        setupTooltip()
        self.hideKeyboardWhenTappedAround()
        passwordTextField.tag = phoneTag
        userTextField.tag = emailTag
        userTextField.keyboardType = .emailAddress
        userTextField.delegate = self
        passwordTextField.delegate = self
        userTextField.leftViewMode = .always
        userTextField.leftView = UIImageView(image: UIImage(named: "email"))
        passwordTextField.leftViewMode = .always
        passwordTextField.leftView = UIImageView(image: UIImage(named: "pwd"))
        loginButton.setBackgroundImage(UIImage(named: "btn_hover"), for: .highlighted)
        passwordTextField.bottomLineColor = UIColor.white
        userTextField.bottomLineColor = UIColor.white
        callButton.setBackgroundImage(UIImage(named: "call_click"), for: .highlighted)
        faceButton.setBackgroundImage(UIImage(named: "face_click"), for: .highlighted)
        googleButton.setBackgroundImage(UIImage(named: "google_click"), for: .highlighted)
//        passwordTextField.bottomLineView.addConstraint(NSLayoutConstraint(
//            item: passwordTextField.bottomLineView,
//            attribute: .bottom,
//            relatedBy: .equal,
//            toItem: self,
//            attribute: .bottom,
//            multiplier: 1,
//            constant: 15
//            )
//        )

        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if checkLogin() {
            gotoMainScreen()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setOtherScreen()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: - Check user was loged
    func checkLogin() -> Bool {
        let userDef = UserDefaults.standard
        if  (userDef.string(forKey: Key.AccountResponse.token) != nil) {
            return true
        }
        return false
    }

    
    // MARK: - Facebook login
    @IBAction func tapedFaceBookLogin(_ sender: Any) {
        // Log event FaceBook Login to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.LOGIN_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.LOGIN_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.LOGIN_KEY as NSObject
            ])

        if UtilHelper.shareInstance.isInternetAvailable() == false {
            self.showError(message: internetNotconnect)
            return
        }
        loading.showOverlay(view: view)
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.token != nil
                {
                    self.getFBUserData()
                } else {
                    self.loading.hideOverlayView()
                }
            } else {
                self.loading.hideOverlayView()
            }
        }

    }
    
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name,picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    if let userDir = result as? NSDictionary {
                        let id = userDir["id"] as? String
                        let email = userDir["email"] as? String
                        let name = userDir["name"] as? String
                        let urlAvatar = userDir["picture"] as? String
                        let socialUser: SocialUerObject = SocialUerObject(name: name, email: email, id: id, avatarUrl: urlAvatar)
                        self.userType = facebook
                        self.socialLogin(socialUser: socialUser)
                        
                    }
                }
            })
        }
    }

    
    
    // MARK: - Google login
    @IBAction func tapedGoogleLogin(_ sender: Any) {
        // Log event Google Login to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.LOGIN_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.LOGIN_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.LOGIN_KEY as NSObject
            ])

        if UtilHelper.shareInstance.isInternetAvailable() == false {
            self.showError(message: internetNotconnect)
            return
        }
        
        loading.showOverlay(view: view)
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    // MARK: - Google signin delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            let userId = user.userID
            let name = user.profile.name
            let email = user.profile.email
            var urlAvatar:String?
            if user.profile.hasImage {
                urlAvatar = user.profile.imageURL(withDimension: 100).absoluteString
            }
            let socialUser: SocialUerObject = SocialUerObject(name: name, email: email, id: userId, avatarUrl: urlAvatar)
            self.userType = google
            self.socialLogin(socialUser: socialUser)
        } else {
//            print("\(error.localizedDescription)")
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            
        }
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - System login
    @IBAction func tapedSystemLogin(_ sender: Any) {
        // Log event System login to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.LOGIN_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.LOGIN_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.LOGIN_KEY as NSObject
            ])
        if self.validateLogin() == false {
            return
        }
        if UtilHelper.shareInstance.isInternetAvailable() == false {
            self.showError(message: internetNotconnect)
            return
        }
        loading.showOverlay(view: view)
        let body = [Key.SystemUser.userName: userTextField.text!, Key.SystemUser.password: passwordTextField.text!] as Dictionary<String, String>
        let url = ServerConfigure.url + ServerConfigure.Path.systemLogin;
        RequestService.shareInstance.Post(keyForDictTask: ServerConfigure.Path.systemLogin, url, body: body, isCheckOuthen: false, successRespose: {(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            
            if let dictionResult = response.dictData {
                let success = dictionResult["code"] as! Int
                if (success == successCode) {
                    if self.userHelper.extractUser(dictionResult) == true {
                        self.userType = systemUser
                        let user = UserDefaults.standard
                        user.set(self.userType, forKey: Key.USER_TYPE)
                        OperationQueue.main.addOperation {
                            self.loading.hideOverlayView()
                            self.userHelper.setCurrentPass(pass: body[Key.Register.password]!);
                            self.gotoVerify()
                        }
                    }
                } else {
                    OperationQueue.main.addOperation {
                        self.loading.hideOverlayView()
                        self.showError(message: dictionResult["message"] as! String)
                    }
                }
            } else {
                OperationQueue.main.addOperation {
                    self.showError(message: self.failMessage)
                }
            }
        }, failureResponse: {(error) in
            OperationQueue.main.addOperation {
                self.showError(message: self.failMessage)
                self.loading.hideOverlayView()
            }
        })
    }
    
    func validateLogin()-> Bool{
        if userTextField.text == nil || userTextField.text?.characters.count == 0 {
            popTip?.showText(textFieldEmpty, direction: AMPopTipDirection.down, maxWidth: 200, in: self.view, fromFrame: self.userTextField.frame)
            errorTag = emailTag
            return false
        }
        
//        if UtilHelper.shareInstance.isValidEmail(testStr: userTextField.text!) == false {
//            popTip?.showText(validEmail, direction: AMPopTipDirection.down, maxWidth: 200, in: self.view, fromFrame: self.userTextField.frame)
//            errorTag = emailTag
//            return false
//        }
        
        if passwordTextField.text == nil || passwordTextField.text?.characters.count == 0 {
            popTip?.showText(passwordEmpty, direction: AMPopTipDirection.down, maxWidth: 200, in: self.view, fromFrame: self.passwordTextField.frame)
            errorTag = phoneTag
            return false
        }
        
        return true
    }
    
    // Mark: - Forgot password
    @IBAction func tapedForgotPass(_ sender: Any) {
        // Log event Register account to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.FORGOT_PASS_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.FORGOT_PASS_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.FORGOT_PASS_KEY as NSObject
            ])

        let forgot = getControllerID(id: .ForgotPassword)
        self.navigationController?.pushViewController(forgot, animated: true)
    }
    
    @IBAction func tapedRegister(_ sender: Any) {
        // Log event Register account to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.REGISTER_ACCOUNT_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.REGISTER_ACCOUNT_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.REGISTER_ACCOUNT_KEY as NSObject
            ])

        let register = getControllerID(id: .Register)
//        self.showError(message: register.description )

        if !register.isEqual(nil) {
            self.navigationController?.pushViewController(register, animated: true)
        }
    }
    
    @IBAction func tapedEmergencyCall(_ sender: Any) {
        // Log event Call SOS Action to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.CALL_SOS_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.CALL_SOS_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.CALL_SOS_KEY as NSObject
            ])

        guard let number = URL(string: "telprompt://" + emegencyNumber) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
    }
    
    
    // MARK: Send user info to server
    func socialLogin(socialUser: SocialUerObject?) -> Void {
        guard socialUser != nil else {
            return
        }
        let body = getBody(socialUser!)
        var url = ""
        if self.userType == facebook {
            url = ServerConfigure.url + ServerConfigure.Path.faceBookLogin
        } else {
             url = ServerConfigure.url + ServerConfigure.Path.googlelLogin
        }
        RequestService.shareInstance.Post(keyForDictTask: self.userType == facebook ? ServerConfigure.Path.faceBookLogin : ServerConfigure.Path.googlelLogin, url, body: body, isCheckOuthen: false, successRespose: {(responseData) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                if let dictResult = responseData.dictData {
                    let success = dictResult["code"] as! Int
                    if success == successCode {
                        let user = UserDefaults.standard
                        user.set(self.userType, forKey: Key.USER_TYPE)
                        if self.userHelper.extractUser(dictResult) == true {
                            self.gotoVerify()
                        }
                    } else {
                        OperationQueue.main.addOperation {
                            self.showError(message: dictResult["message"] as! String)
                        }
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
    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }
        
    func gotoVerify() -> Void {
        sendTokenDivce()
        let userDefault = UserDefaults.standard
        let notify = userDefault.integer(forKey: Key.AccountResponse.notifyStart)
        if notify == 1 {
            let doneRequest = getControllerID(id: .serviceProvider) as! DoneRequestViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            doneRequest.userInfo = appDelegate.userInfo
            self.navigationController?.pushViewController(doneRequest, animated: true)
            
        } else {
            if let verify = userHelper.getVeified() {
                if verify == VERIFIED {
                    self.gotoMainScreen()
                    return
                }
            }
            _ = getNavigationWithRootID(id: .AddMoreCar)

            }
        
        
    }
    
    func gotoMainScreen() -> Void {
        let user = UserDefaults.standard
        let caseId = user.integer(forKey: Key.LocalKey.caseId) as Int
        let doneRq = user.integer(forKey: Key.LocalKey.doneRequest)
        let agent = user.string(forKey: Key.LocalKey.agent)
        if caseId > 0 {
            if doneRq == DONE_REQUEST {
                let servicelist = getControllerID(id: .serviceList) as! ServiceListViewController
                servicelist.caseId = caseId
                self.navigationController?.pushViewController(servicelist, animated: true)
            } else {
                let waiting = getControllerID(id: .Waiting) as! WaitingViewController
                waiting.agent = agent
                waiting.caseId = caseId
                self.navigationController?.pushViewController(waiting, animated: true)
            }
        } else {
            _ = getNavigationWithRootID(id: .GetHelp)
        }
        
    }
    
    func sendTokenDivce() {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            let body = ["token": refreshedToken] as Dictionary<String, String>
            let url = ServerConfigure.url + ServerConfigure.Path.token
            RequestService.shareInstance.putRequest(keyForDictTask: ServerConfigure.Path.token, url, body: body, isCheckOuthen: true, successRespose: {(response) in
                if let dicResult = response.dictData {
                    let success = dicResult["code"] as! Int
                    if success != successCode {
                        self.sendTokenDivce()
                    }
                }
            } , failureResponse:  { (error) in
                self.sendTokenDivce()
            })
        }
        
    }
    
    func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return
        }
        
//        print("InstanceID token: \(FIRInstanceID.instanceID().token()!)")
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
//                print("Unable to connect with FCM. \(error?.localizedDescription ?? "")")
            } else {
//                print("Connected to FCM.")
            }
        }
    }


    
    func getBody(_ user: SocialUerObject)->Dictionary<String, String> {
        if self.userType == facebook {
            var body = [Key.Facebook.name: "", Key.Facebook.email: "", Key.Facebook.id: "", Key.Facebook.avatar:""] as Dictionary<String, String>
            body[Key.Facebook.name] = user.getName() != nil ? user.getName() : ""
            body[Key.Facebook.email] = user.getEmail() != nil ? user.getEmail() : ""
            body[Key.Facebook.id] = user.getId() != nil ? user.getId() : ""
            body[Key.Facebook.avatar] = user.getUrl() != nil ? user.getUrl() : ""
            return body
        } else {
            var body = [Key.Google.name: "", Key.Google.email: "", Key.Google.id: "", Key.Google.avatar:""] as Dictionary<String, String>
            body[Key.Google.name] = user.getName() != nil ? user.getName() : ""
            body[Key.Google.email] = user.getEmail() != nil ? user.getEmail() : ""
            body[Key.Google.id] = user.getId() != nil ? user.getId() : ""
            body[Key.Google.avatar] = user.getUrl() != nil ? user.getUrl() : ""
            return body

        }
    }
    
    // MARK: UItextfield delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        passwordTextField.bottomLineColor = UIColor.white
        userTextField.bottomLineColor = UIColor.white

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if errorTag == textField.tag {
            popTip?.hide()
        }
        
        if (textField.tag == phoneTag) {
            passwordTextField.bottomLineColor = UIColor.black
        }
        
        if textField.tag == emailTag {
            userTextField.bottomLineColor = UIColor.black
        }
    }
    
}

