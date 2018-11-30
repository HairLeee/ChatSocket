//
//  UserDetailViewController.swift
//  RSAMobile
//
//  Created by tanchong on 3/31/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import Firebase

class UserDetailViewController: ContainSideMenuBaseViewController, UIScrollViewDelegate {

    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var requestButton: UIButton!

    let fieldCell = "carCell"
    let failMessage = "Fail to load data, Had some problem while conneting to server."
    var listData:[InsuranceObject] = []
    let loading = LoadingOverlay()
    let titles:[String] = ["Car Reg.No", "Coverage", "Expiry", "Make", "Model", "Year Make"]
    let itemOfIns = 6
    var currentItem = 1
    var insurances: [InsuranceDetail] = []
    var noData = false
    
   // @IBOutlet weak var topScroll: NSLayoutConstraint!
    @IBOutlet weak var pagePageControll: UIPageControl!
    @IBOutlet weak var pageScroll: UIScrollView!

    //var mainStoryboard: UIStoryboard?
    let userHelper = UserHelper()
    
    @IBOutlet weak var bgInfo: UIImageView!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //initView()
        
        self.avatarImage.makeRoundBorder(borderWidth: UIParameter.AvatarBorderWidth)
        // round background
        self.bgInfo.layer.cornerRadius = self.bgInfo.frame.size.width / 2
        self.bgInfo.clipsToBounds = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        NotificationCenter.default.addObserver(self, selector: #selector(UserDetailViewController.didDownloadAvatarImage(noti:)), name: NSNotification.Name(rawValue:notificationAvatarImageFinishDownload), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserDetailViewController.didCreateBlurImage(noti:)), name: NSNotification.Name(rawValue:notificationBlurAvatarImageCreated), object: nil)
        initView()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let image = self.getAvatarImage() {
            self.avatarImage.image = image
            self.bgInfo.image = gBlurAvatarImage
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:notificationAvatarImageFinishDownload), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:notificationBlurAvatarImageCreated), object: nil)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        self.dismiss(animated: false, completion: nil)
//    }
    
    func initView() {
        
//        deleteButton.tintColor = UIColor.white
//        deleteButton.setImage(UIImage(named:"delete"), for: UIControlState.normal)
//        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 6,left: 100,bottom: 6,right: 14)
//        deleteButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: -30,bottom: 0,right: 34)
//        deleteButton.setTitle("Delete", for: UIControlState.normal)
//        deleteButton.layer.borderColor = UIColor.white.cgColor

        requestButton.layer.borderColor = UIColor.init(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1.0).cgColor
        deleteButton.layer.borderColor  = UIColor.init(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1.0).cgColor
        requestButton.layer.borderWidth = 1.0
        deleteButton.layer.borderWidth = 1.0

        if let name = self.userHelper.getUserName() {
            self.userNameLabel.text = name
        } else {
            self.userNameLabel.text = " "
        }
        
        if let email = self.userHelper.getUserEmail() {
            self.emailLabel.text = email
        } else {
            self.emailLabel.text = " "
        }
        
        if let phone = self.userHelper.getUserMobile() {
            self.phoneNumberLabel.text = UtilHelper.shareInstance.formatMobile(phoneNumber: phone)
        } else {
            self.phoneNumberLabel.text = " "
        }
        
        infoButton.setBackgroundImage(UIImage(named:"info_click"), for: .highlighted)
        editButton.setBackgroundImage(UIImage(named:"edit_click"), for: .highlighted)
        
        
//        let longPress = UILongPressGestureRecognizer()
//        longPress.addTarget(self, action:#selector(handleLongPress))
//        longPress.minimumPressDuration = 2.0
//        self.insuranceInfoTableView.addGestureRecognizer(longPress)
        
        pageScroll.delegate = self
        getListInsurance()
        
    }
    
    // MARK: - Page view insurance
    func createInsuranceView()->[InsuranceDetail]  {
        var listPage:[InsuranceDetail] = []
        //topScroll.constant = 0
        for i in 0..<listData.count {
            let insurance:InsuranceDetail = Bundle.main.loadNibNamed("InsuranceDetail", owner: self, options: nil)?.first as! InsuranceDetail
            insurance.viewSetting()
            //let object = listData[listData.count - 1 - i]
            let object = listData[i]
            insurance.carNoContent.text = object.getRegNo()
            insurance.coverageContent.text = object.getCoverate()
            insurance.expiryContent.text = UtilHelper.shareInstance.convertDateFormater(dateTime: object.getExpiry())
            insurance.makeContent.text = object.getMake()
            insurance.modelContent.text = object.getModel()
            if  let statusExpiry = object.getStatusExpiry() {
                if let expiryId = Expiry(rawValue: statusExpiry) {
                    insurance.colorBackgroud = expiryId.color
                    insurance.review.textColor = expiryId.color
                    if expiryId != Expiry.unexpired {
                         insurance.expiryContent.textColor = expiryId.color
                    }
                }
                
                if statusExpiry != 1 {
                    insurance.review.isHidden = false
                }
            }
            
            
            

            if  let year: Int = object.getYearMake() {
                insurance.yearContent.text = String(year)
            } else {
                 insurance.yearContent.text = ""
            }
            
            listPage.append(insurance)
        }
        if listPage.count == 0 {
            noData = true
            let insurance:InsuranceDetail = Bundle.main.loadNibNamed("InsuranceDetail", owner: self, options: nil)?.first as! InsuranceDetail
            insurance.isHidenNoView = false
            insurance.setNodataView()
            insurance.noDataText.text = noCar
            listPage.append(insurance)
            //topScroll.constant = 40
            pageScroll.isScrollEnabled = false
        }
        
        return listPage
        
    }
    
    func setupPageScrollView(insurances: [InsuranceDetail]) {
        let subViews = self.pageScroll.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        
        pageScroll.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: pageScroll.frame.height)
        pageScroll.contentSize = CGSize(width: view.frame.width * CGFloat(insurances.count), height: pageScroll.frame.height)
        pageScroll.isPagingEnabled = true
        for i in 0..<insurances.count {
            insurances[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: pageScroll.frame.origin.y, width: view.frame.width, height: pageScroll.frame.height)
            pageScroll.addSubview(insurances[i])
        }
    }
    
    func didDownloadAvatarImage(noti: Notification) -> Void {
        DispatchQueue.main.async() { () -> Void in
            self.avatarImage.image = noti.object as? UIImage
        }
    }
    
    func didCreateBlurImage(noti: Notification) -> Void {
        DispatchQueue.main.async() { () -> Void in
            self.bgInfo.image = noti.object as? UIImage
        }
    }
    
    @IBAction func tapedBack(_ sender: Any) {
        self.onLeftMenu(sender: sender)
    }
        
    
    func backToLogin() -> Void {
        let accountInfor = getControllerID(id: .Login)  //mainStoryboard?.instantiateViewController(withIdentifier: "loginController") as! LoginViewController
        getMainNavigation()?.setViewControllers([accountInfor], animated: true)
    }
    
    @IBAction func tapedEdit(_ sender: Any) {
       let edit = getControllerID(id: .EditUserInformation)     //self.mainStoryboard?.instantiateViewController(withIdentifier: "editInfoController") as! EditInfoViewController
        self.navigationController?.pushViewController(edit, animated: true)
    }
    @IBAction func tapedInfo(_ sender: Any) {
        // Log event Call agent Event to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.CALL_AGENT_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.CALL_AGENT_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.CALL_AGENT_KEY as NSObject
            ])

        guard let number = URL(string: "telprompt://" + contactSupportNumber) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
        sendInfoDevice()
    }

    
    // MARK: - Get list insurance
    func getListInsurance() {
        let url = ServerConfigure.url + ServerConfigure.Path.getListCar
        loading.showOverlay(view: view)
        RequestService.shareInstance.Get(keyForDictTask: ServerConfigure.Path.getListCar, url, checkAuthen: true, successResponse: {(response)in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            if let dictionResult = response.dictData {
                let success = dictionResult["code"] as! Int
                if success == successCode {
                    DispatchQueue.main.async {
                        let listInsurance = RequestHelper.shareInstance.extractInsuranceJson(dictionResult)
                        self.listData = listInsurance
                        self.insurances = self.createInsuranceView()
                        self.setupPageScrollView(insurances: self.insurances)
                        if self.noData {
                        self.pagePageControll.numberOfPages = 0
                        } else {
                        self.pagePageControll.numberOfPages = self.insurances.count
                        }
                        
                        self.pagePageControll.currentPage = 0
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
                let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message: self.failMessage, textAction: alertTitleA)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Handle action Insurance
    
    @IBAction func callAssistance(_ sender: Any) {
        let insurance = getCurrentInsurance()
        if let nav = getMainNavigation() {
            let getHelp = storyboard?.instantiateViewController(withIdentifier: "requestAssistanceController") as! RequestAssistanceViewController
            getHelp.insurance = insurance
            nav.setViewControllers([getHelp], animated: true)
        }
      
    }
    
   @IBAction  func deleteInsuarance(_ sender: Any) {
        if listData.count > 0 {
            let insurance = getCurrentInsurance()
            showConfirmDelete(insurance: insurance)
        }
    }
    
    func getCurrentInsurance()-> InsuranceObject {
        if listData.count <= 0 {
            return InsuranceObject()
        }
        let index = pagePageControll.currentPage
        let insurance = listData[index]
        return insurance
    }
    
    func showConfirmDelete(insurance: InsuranceObject) {
        let alert = UtilHelper.shareInstance.getAlert(title: confirm, message: confirmDelete, textAction: cancel)
        alert.addAction(UIAlertAction(title: alertTitleA, style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
            let id:Int = insurance.getId()!
            let url = ServerConfigure.url + ServerConfigure.Path.deleteCar + String(id)
            self.loading.showOverlay(view: self.view)
            RequestService.shareInstance.Put(keyForDictTask: ServerConfigure.Path.deleteCar, url, checkAuthen: true, successResponse: {(response) in
                OperationQueue.main.addOperation {
                    self.loading.hideOverlayView()
                    if let dictResult = response.dictData {
                        let success = dictResult["code"] as! Int
                        if success == successCode {
                            let alert = UtilHelper.shareInstance.getAlert(title: successTitle, message:dictResult["message"] as! String, textAction: alertTitleA)
                            self.present(alert, animated: true, completion: nil)
                            self.getListInsurance()
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
        })
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Scroll view delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(pageScroll.contentOffset.x/view.frame.width)
        pagePageControll.currentPage = Int(pageIndex)
    }
    
}
