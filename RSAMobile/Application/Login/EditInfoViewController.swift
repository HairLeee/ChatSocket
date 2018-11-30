//
//  EditInfoViewController.swift
//  RSAMobile
//
//  Created by tanchong on 4/3/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import AVFoundation

class EditInfoViewController: BaseViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var usernameTextField: BorderBottomTextField!
    @IBOutlet weak var phoneTextField: BorderBottomTextField!
    @IBOutlet weak var emailTextField: BorderBottomTextField!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var takePhotoBut : UIButton!
    @IBOutlet weak var changePassBut : UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    let phoneTag = 1;
    let mailTag = 5
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
    
    let camera = "Take a new photo"
    let galary = "Select a photo"
    override func loadView() {
        super.loadView()
        usernameTextField.highLightType = HighLightTextField.HighLightBorder
        emailTextField.highLightType = HighLightTextField.HighLightBorder
        phoneTextField.highLightType = HighLightTextField.HighLightBorder
        usernameTextField.addBottomLine()
        emailTextField.addBottomLine()
        phoneTextField.addBottomLine()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        loading.center = view.center
        view.addSubview(loading)
        let userDefault = UserDefaults.standard
        userType = userDefault.integer(forKey: Key.USER_TYPE)
        initView()
        
        //self.title = "Edit"
        //self.navigationItem.title = "Edit"
//        let rightButItem = UIBarButtonItem(image: UIImage(named: "re_done"), style: .plain, target: self, action: #selector(self.tapedDone(_:)))
//        self.navigationItem.rightBarButtonItem = rightButItem
//        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "arrow")
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "arrow")

        self.navigationController?.navigationBar.backItem?.title = ""

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(LeftMenuTableViewController.didDownloadAvatarImage(noti:)), name: NSNotification.Name(rawValue:notificationAvatarImageFinishDownload), object: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:notificationAvatarImageFinishDownload), object: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    
    
    func initView() {
//        usernameTextField.leftViewMode = .always
//        usernameTextField.leftView = UIImageView(image: UIImage(named: "user"))
//        emailTextField.leftViewMode = .always
//        emailTextField.leftView = UIImageView(image: UIImage(named: "email"))
//        phoneTextField.leftViewMode = .always
//        phoneTextField.leftView = UIImageView(image: UIImage(named: "mobile"))
        emailTextField.keyboardType = .emailAddress

        phoneTextField.delegate = self
        phoneTextField.tag = phoneTag
        emailTextField.delegate = self
        emailTextField.tag = mailTag
        usernameTextField.delegate = self
        scrollView.isScrollEnabled = false
        
        usernameTextField.bottomLineColor = UIColor.gray
        emailTextField.bottomLineColor = UIColor.gray
        phoneTextField.bottomLineColor = UIColor.gray
        emailTextField.isUserInteractionEnabled = false
        if let name = self.userHelper.getUserName() {
            usernameTextField.text = name
        }
        
        if let phone = self.userHelper.getUserMobile() {
            phoneTextField.text = UtilHelper.shareInstance.formatMobile(phoneNumber: phone)
        }
        
        if let email = userHelper.getUserEmail() {
            emailTextField.text = email
        }
        
        // round image
        self.avatarImage.makeRoundBorder(borderWidth: 6.0, borderColor: UIColor.init(red: 234.0/255, green: 234.0/255, blue: 234.0/255, alpha: 1.0))
        self.avatarImage.image = getAvatarImage()
        
        self.takePhotoBut.makeHalfRoundMask(6.0, isVertical: false)
        
        if userType == facebook || userType == google {
            changePassBut.isHidden = true
        }
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
    }
    
    
    
    
    func didDownloadAvatarImage(noti: Notification) -> Void {
        if let image = noti.object as? UIImage {
            DispatchQueue.main.async {
                self.avatarImage.image = image
            }
        }
    }
    
    
    @IBAction func tapedCamera(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: camera, style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
            //camera
            if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized
            {
                self.openCamera()
            }
            else
            {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                    if granted == true
                    {
                        self.openCamera()
                    }
                    else
                    {
                        self.alertToEncourageCameraAccessInitially()
                    }
                });
            }
           
        })
        
        alert.addAction(UIAlertAction(title: galary, style: .default){(action) in
            alert.dismiss(animated: true, completion: nil)
            // Photo libary
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            self.present(myPickerController, animated: true, completion: nil)

        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default){(action) in
            alert.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for capturing photos!",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.canOpenURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onChangePassword(_ sender: Any) {
        let controller = getControllerID(id: .ChangePassword)
        self.navigationController?.pushViewController(controller, animated: true)
    }
  
    @IBAction func tappedBack(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    // MARK: - Send data to server
    @IBAction func tapedDone(_ sender: Any) {
        if (self.validInfo() == false) {
            return
        }
        
        let url = ServerConfigure.url + ServerConfigure.Path.userChangeInfo
        let imageData = UIImageJPEGRepresentation(self.avatarImage.image!.cropToSize(CGSize(width: UIParameter.AvatarSize, height: UIParameter.AvatarSize)), 1)
      
        if UtilHelper.shareInstance.isInternetAvailable() == false {
            self.showError(message: internetNotconnect)
            return
        }
        loading.showOverlay(view: view)
        RequestService.shareInstance.PostRequest(keyForDictTask: ServerConfigure.Path.userChangeInfo, url, param: getBody(), imageData: imageData!, isCheckOuthen: true, successRespose: {(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            if let dictionResult = response.dictData {
                let success = dictionResult["code"] as! Int
                if (success == successCode) {
                    let imageUrl = dictionResult[Key.AccountResponse.userAvatar] as! String
                    self.userHelper.setUserAvatar(avatar: imageUrl)
                    self.updateLocalInfo()
                    OperationQueue.main.addOperation {
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
    
    func validInfo()->Bool {
        
        // Phone
        if  phoneTextField.text == nil || (phoneTextField.text?.characters.count)! < 1{
            popTip?.showText(require, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.containerView, fromFrame: self.phoneTextField.frame)
            phoneTextField.bottomLineColor = UIColor.red
            errorTag = phoneTag
            return false
        }
        let phone = phoneTextField.text
        if (UtilHelper.shareInstance.deFomatMobile(phoneNumber: phone!)).characters.count < MIN_LENGTH_PHONE {
            popTip?.showText(phoneNumberInvalid, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.containerView, fromFrame: self.phoneTextField.frame)
            phoneTextField.bottomLineColor = UIColor.red
            errorTag = phoneTag
            return false
        }
        
        if (UtilHelper.shareInstance.validatePhone(mobile: phone!) == false) {
            popTip?.showText(phoneNumberInvalid, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.containerView, fromFrame: self.phoneTextField.frame)
            phoneTextField.bottomLineColor = UIColor.red
            errorTag = phoneTag
            return false
        }
        
        // Email
        if  emailTextField.text == nil || (emailTextField.text?.characters.count)! < 1 {
            popTip?.showText(require, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.containerView, fromFrame: self.emailTextField.frame)
            emailTextField.bottomLineColor = UIColor.red
            errorTag = mailTag
            return false
        }
        
        if UtilHelper.shareInstance.isValidEmail(testStr: emailTextField.text!) == false {
            popTip?.showText(validEmail, direction: AMPopTipDirection.down, maxWidth: MAX_WITH_TOOLTIP, in: self.containerView, fromFrame: self.emailTextField.frame)
            emailTextField.bottomLineColor = UIColor.red
            errorTag = mailTag
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
        self.scrollView.isScrollEnabled = false
        if textField.tag == errorTag  {
            popTip?.hide()
        }
        switch textField.tag {
        case phoneTag:
            phoneTextField.bottomLineColor = UIColor.black
            break
        case mailTag:
            emailTextField.bottomLineColor = UIColor.black
            break
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.scrollView.scrollToTop()
        self.scrollView.isScrollEnabled = false
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

    
    
    func getBody()-> Dictionary<String, String> {
        var body = [Key.EditUserInfo.name: "", Key.EditUserInfo.email: "", Key.EditUserInfo.mobile: ""] as Dictionary<String, String>
        body[Key.EditUserInfo.email] = emailTextField.text != nil ? emailTextField.text : ""
        body[Key.EditUserInfo.name] = usernameTextField.text != nil ? usernameTextField.text : ""
        body[Key.EditUserInfo.mobile] = phoneTextField.text != nil ? phoneTextField.text : ""
        return body
    }
    
    func updateLocalInfo() {
        if let username = usernameTextField.text {
            userHelper.setUserName(name: username)
        }
        
        if let email = emailTextField.text {
            userHelper.setUserEmail(email: email)
        }

        if let mobile = phoneTextField.text {
            userHelper.setUserMobile(mobile: UtilHelper.shareInstance.deFomatMobile(phoneNumber: mobile))
        }
        
        self.updateAvatar(avatarImage.image)

    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avatarImage.image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        self.dismiss(animated: true, completion: nil);
    }
}
