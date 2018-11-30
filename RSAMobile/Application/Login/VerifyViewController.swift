//
//  VerifyViewController.swift
//  RSAMobile
//
//  Created by tanchong on 3/30/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import SideMenu
import Firebase
class VerifyViewController: UIViewController, UITextFieldDelegate {

   var showLeft = false
    @IBOutlet weak var btnVerify: UIButton!
    @IBOutlet weak var carNoTextFiled: BorderBottomTextField!
    @IBOutlet weak var mykadMyKid: BorderBottomTextField!
    let failMessage = "Fail to verify, Had some problem while conneting to server."
    let loading = LoadingOverlay()
    //var mainStoryboard: UIStoryboard?
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func loadView() {
        super.loadView()
        carNoTextFiled.highLightType = HighLightTextField.HighLightPadding
        mykadMyKid.highLightType = HighLightTextField.HighLightPadding
        mykadMyKid.addBottomLine()
        carNoTextFiled.addBottomLine()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
       initView()
        self.hideKeyboardWhenTappedAround()
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func initView() {
        carNoTextFiled.delegate = self
        carNoTextFiled.leftViewMode = .always
        carNoTextFiled.bottomLineColor = UIColor.init(red: 221.0/225.0, green: 221.0/225.0, blue: 221.0/225.0, alpha: 1.0)
        carNoTextFiled.leftView = UIImageView(image: UIImage(named: "mykad"))
        
        
        mykadMyKid.delegate = self
        mykadMyKid.leftViewMode = .always
        mykadMyKid.bottomLineColor = UIColor.init(red: 221.0/225.0, green: 221.0/225.0, blue: 221.0/225.0, alpha: 1.0)
        mykadMyKid.leftView = UIImageView(image: UIImage(named: "id_card"))
        btnVerify.setBackgroundImage(UIImage(named: "btn_hover"), for: .highlighted)
        btnVerify.setTitleColor(UIColor.black, for: .highlighted)
        self.navigationItem.title = "Verify Policy"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        checkVerify()
    }
    
    func checkVerify () {
        let user = UserHelper()
        if let verify = user.getVeified() {
            if verify == VERIFIED {
//                let leftBarButton = UIBarButtonItem(image: UIImage.init(named: "icon_menu"), style: .done, target: self, action: #selector(ContainSideMenuBaseViewController.onLeftMenu(sender:)))
//                self.navigationItem.leftBarButtonItem = leftBarButton
//                let leftBarButton = UIButton(type: .custom)
//                leftBarButton.setImage(UIImage(named: "icon_menu"), for: .normal)
//                leftBarButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//                leftBarButton.addTarget(self, action: #selector(self.onLeftMenu(sender:)), for: .touchUpInside)
//                let item = UIBarButtonItem(customView: leftBarButton)
//                self.navigationItem.setLeftBarButtonItems([item], animated: true)
                menuButton.isHidden = false
                skipButton.isHidden = true
            } else {
//                let skip = UIButton(type: .custom)
//                skip.setTitle("Skip", for: .normal)
//                skip.setTitleColor(UIColor.black, for: .normal)
//                skip.frame = CGRect(x: 0, y: 0, width: 35, height: 40)
//                skip.addTarget(self, action: #selector(self.tapedSkip(_:)), for: .touchUpInside)
//                let item = UIBarButtonItem(customView: skip)
//                self.navigationItem.setRightBarButtonItems([item], animated: true)
                menuButton.isHidden = true
                skipButton.isHidden = false

            }
        }
    }
   
    func onLeftMenu (sender : Any) {
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
    @IBAction func tappedMenu(_ sender: Any) {
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    func toggleLeftMenu() -> Void {
        self.showLeft = !self.showLeft
        
        if self.showLeft {
//            print ("show left")
            present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        } else {
            // Similarly, to dismiss a menu programmatically, you would do this:
//            print ("hide left")
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func tapedVerify(_ sender: Any) {
        // Log event Verify to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.VERIFY_POLICY_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.VERIFY_POLICY_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.VERIFY_POLICY_KEY as NSObject
            ])

        if validateCar() == false {
            return
        }
        
        let url = ServerConfigure.url + ServerConfigure.Path.verifyCar
        let body = [Key.Verify.carNumber: carNoTextFiled.text!, Key.Verify.myKad: mykadMyKid.text!] as Dictionary<String, String>
        self.loading.showOverlay(view: view)
        RequestService.shareInstance.Post(keyForDictTask: ServerConfigure.Path.verifyCar, url, body: body, isCheckOuthen: true, successRespose: {(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            if let dictionResult = response.dictData {
                let success = dictionResult["code"] as! Int
                if (success == successCode) {
                   let user = UserHelper()
                    user.setVerify(verify: VERIFIED)
                    if dictionResult["data"] != nil  {
                        OperationQueue.main.addOperation {
                            //self.goToAccountInfo()
                            _ = getNavigationWithRootID(id: .Account)
                        }
                    } else {
                        self.showError(message: dictionResult["message"] as! String)
                    }
                    
                } else {
                    OperationQueue.main.addOperation {
                        self.showError(message: dictionResult["message"] as! String)
                    }
                }
            }
        }, failureResponse: {(error) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                self.showError(message: self.failMessage)
            }
        
        })
    }
    
    @IBAction func tapedSkip(_ sender: Any) {
        _ = getNavigationWithRootID(id: .GetHelp)
    }
    
//    func goToAccountInfo() -> Void {
//        let accountInfor = getControllerID(id: .UserInformation)    //mainStoryboard?.instantiateViewController(withIdentifier: "userDetailController") as! UserDetailViewController
//        self.present(accountInfor, animated: true, completion: nil)
//    }
    
    func validateCar()->Bool {
        if carNoTextFiled.text == nil || carNoTextFiled.text?.characters.count == 0 {
            popTip?.showText(require, direction: AMPopTipDirection.down, maxWidth: 200, in: self.view, fromFrame: self.carNoTextFiled.frame)
            carNoTextFiled.bottomLineColor = UIColor.red
            return false
        }
        
        if mykadMyKid.text == nil || mykadMyKid.text?.characters.count == 0 {
            popTip?.showText(require, direction: AMPopTipDirection.down, maxWidth: 200, in: self.view, fromFrame: self.mykadMyKid.frame)
            mykadMyKid.bottomLineColor = UIColor.red
            return false
        }
//        
//        if UtilHelper.shareInstance.isValidMykid(mykid: mykadMyKid.text!) == false {
//            popTip?.showText(myKadInValid, direction: AMPopTipDirection.down, maxWidth: 200, in: self.view, fromFrame: self.mykadMyKid.frame)
//            return false
//        }

        return true
    }
    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - UI text field delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        popTip?.hide()
        let textview = textField as! BorderBottomTextField
        textview.bottomLineColor = UIColor.black
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        let textview = textField as! BorderBottomTextField
        textview.bottomLineColor = UIColor.init(red: 221.0/225.0, green: 221.0/225.0, blue: 221.0/225.0, alpha: 1.0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
