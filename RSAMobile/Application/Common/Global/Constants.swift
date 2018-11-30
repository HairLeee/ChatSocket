//
//  Constants.swift
//  RSAMobile
//
//  Created by tanchong on 3/22/17.
//  Copyright © 2017 Trung. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications

//let URLBase = "http://199.199.3.13:5555" // Server test
//let URLBase = "http://172.16.254.83:5555" // UAT
//let URLBase = "http://211.25.100.147:5555" // PUBLIC ID
//let URLBase = "http://104.155.130.191:5555" // Cloud ID
//let URLBase = "https://rsacms.tanchonggroup.com" // Server prod
let URLBase = "https://stgrsacms.tanchonggroup.com"
let successCode = 0

let emegencyNumber = "1800-88-6491"
let contactSupportNumber = "1800-88-6491"

let confirm:String = "Confirm"
let waring = "Warning"
let errorTitle = "Error"
let successTitle = "Success"
let alertTitleA = "Ok"
let cancel = "Cancel"


let GOOGLE_MAP_KEY = "AIzaSyCDqR9HGfMNFEcbLt6RYSyPkSComwm-IwU" // key for developer
let GOOGLE_PLACES_KEY = "AIzaSyBJmHKJ-CqFXOA-PuwIixod54sdAfOTOIE"
let MAP_ZOOM_DEFAULT: Float = 17.0
let VERIFIED = 1;
let NOT_VERIFY = 0;
let ACTIVED = 1;
let RINGIT = "RM"
let SERVICE_LIST = 1
let OTHER_SCREEN = 0
let CANCEL_SERVICE = 1
let NO_CANCEL = 0
let MAX_IMAGE_ACCIDENT = 4

let GRAY_COLOR_LINETABLEVIEW_REVIEWSUMMARY = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)

// MARK: - SERVICE STATUS
let CANCEL = 0
let ACTIVE = 1
let COMPLETED = 2
let DONE_REQUEST = 4
let NEW_REQUEST = 3
let USER_CACEL_CASE = 5

// MARK: - Server configuration
struct ServerConfigure {
    static let url: String = URLBase + "/api/"
    static let SERVER_TYPE = "TEST"
    
    struct Path {
        static let faceBookLogin: String = "login/facebook"
        static let googlelLogin: String = "login/google"
        static let systemLogin: String = "login/userReg"
        static let register: String = "user/register"
        static let forgotPassword: String = "user/forgotpassword"
        static let userChangeInfo = "user/changeInform"
        static let verifyCar = "vehicle/addCarVerify"
        static let deleteCar = "vehicle/deleteVerify/"
        static let getListCar = "vehicle/getListVerifier"
        static let getListCaseType = "vehicle/getListCaseType"
        static let getListFaultType = "vehicle/getListFaultTypeWithCaseType/"
        static let getListServiceType = "vehicle/getListServiceTypes"
        static let requestAssistance = "vehicle/requestAssistance"
        static let cancelRequest = "vehicle/cancelCase/"
        static let cancelConfirm = "vehicle/cancelCaseConfirm/"
        static let serviceList = "vehicle/serviceOrderList/"
        static let cancelService = "vehicle/cancelActivationLog/"
        static let cancelServiceConfirm = "vehicle/cancelActivationLogConfirm/"
        static let token = "user/sentDeviceTokenVer2"
        static let rating = "vehicle/remarkAndRate/"
        static let sendInfoDevice = "vehicle/getInformDevices"
        static let getCaseStatus = "vehicle/getCaseStatus/"
        static let downloadAvatar = "downloadAvatar"
        static let logoutUser = "logout"
    }
   
}

// MARK: Debug log
    let isDebug = true
func TCLog(_ content: Any) {
    if (isDebug) {
//        print(content)
    }
    
}

// MARK: - Key communicate with server
struct Key {
    
    static let USER_TYPE = "userType"
    static let CURRENT_PASSWOR = "current_pass"
    
    struct Facebook {
        //Post param
        static let name = "facebookName"
        static let email = "facebookEmail"
        static let id = "facebookId"
        static let avatar = "avatar"
    }
    
    struct Google {
        static let name = "googleName"
        static let email = "googleEmail"
        static let id = "googleId"
        static let avatar = "avatar"
    }
    
    struct SystemUser {
        static let userName = "userLogin"
        static let password = "password"
    }
    
    struct Register {
        static let userName = "userName"
        static let email = "userEmail"
        static let mobile = "userMobile"
        static let password = "password"
    }
    
    struct Logout {
        static let token = "token"
    }

    
    struct ForgotPass {
        static let email = "email"
    }
    
    struct AccountResponse {
        // Response key
        static let code = "code"
        static let message = "message"
        static let verified = "verified"
        static let token = "access_token"
        static let user = "user"
        static let userName = "name"
        static let userEmail = "email"
        static let userMobile = "mobile"
        static let userAvatar = "avatar"
        static let active = "activated"
        static let notifyStart = "notify"
        static let userAvatar_blur = "avatar_blur"
    }
    
    struct EditUserInfo {
        static let avatar = "avatar"
        static let email = "email"
        static let name = "name"
        static let mobile = "mobile"
        static let newPassword = "newPassword"
        static let confirmPas = "confirmPassword"
    }
    
    struct UserActive {
        static let active = "activated"
        static let serviceList = "serviceList"
        static let cancelService = "cancelService"
    }
    
    struct Verify {
        static let carNumber = "carplateNumber"
        static let myKad = "mykad_mykid"
    }
    
    struct Car {
        static let id = "id"
        static let code = "code"
        static let message = "message"
        static let data = "data"
        static let coverate = "coverate"
        static let expiry = "expiry"
        static let statusExpiry = "statusExpiry"
        static let carRegNo = "carRegNo"
        static let make = "make"
        static let model = "model"
        static let yearMake = "yearMake"
        static let typeOfCover = "typeOfCover"
    }
    
    struct CaseType {
        static let code = "code"
        static let message = "message"
        static let data = "data"
        static let id = "id"
        static let name = "name"
        static let icon = "icon"
        
    }
    
    
    struct FaultType {
        static let code = "code"
        static let message = "message"
        static let data = "data"
        static let id = "id"
        static let name = "name"
    }

    
    struct ServicType {
        static let code = "code"
        static let message = "message"
        static let data = "data"
        static let id = "id"
        static let typeName = "typename"
        
    }

    struct RequestAssitance {
        static let carplateNumber = "carplateNumber"
        static let currentLocation = "currentLocation"
        static let caseTypeId = "caseTypeId"
        static let faultTypeId = "faultTypeId"
        static let serviceTypeId = "serviceTypeId"
        static let id = "id"
        static let note = "note"
        static let paymentType = "paymentTypeId"
        static let breakPics  = "breakPics"
        static let codeCallGroup  = "codeCallGroup"
        static let codeCallGroupIBS = "9"
        static let codeCallGroupEtiqa = "8"
    }
    
    struct CancelAssitance {
        static let code = "code"
        static let message = "message"
        static let confirm = "confirm"
    }
    
    struct ServiceList {
        static let code = "code"
        static let message = "message"
        static let listService = "listServiceOrders"
        static let serviceOrderId = "serviceOrderId"
        static let providerName = "providerName"
        static let providerPhone = "providerPhone"
        static let coverageAmount = "coverageAmount"
        static let customerPay = "customerPay"
        static let totalFee = "totalFee"
        static let totalAdjust = "totalAdjust"
        static let activationlogs = "ActivationLogs"
        static let activavationLogId = "activavationLogId"
        static let serviceParent = "serviceParent"
        static let priceServiceParent = "priceServiceParent"
        static let serviceAddition = "serviceAddition"
        static let priceServiceAddition = "priceServiceAddition"
        static let fee = "fee"
        static let cancellationFee = "cancellationFee"
//        static let status = "status"
        static let adjust = "adjust"
        static let total  = "total"
        static let note = "note"
        static let cancelNote = "cancelNote"
        static let activeNote = "activeNote"
        static let serviceType = "ServiceType"
        static let status = "Status"
    }
    
    struct Notify {
        static let caseId = "caseId"
        static let serviceOderId = "serviceOrderId"
        static let notify = "notification"
        static let title = "title"
        static let body = "body"
        static let provider = "providerName"
        static let data = "data"
        static let distance = "distance"
        static let estimateTime = "estimateTimeDistance"
        static let carNumber = "carPlateNumber"
        
    }
    
    struct notifyUpdate {
        static let caseId = "racaseId"
        
        static let serviceId = "serviceOrderId"
    }
    
    struct notifyStatusCase {
        static let title = "title"
        static let body = "nameAgent"
        static let caseId = "caseId"
        static let status = "status"
    }
    
    struct InfoDevice {
        static let location = "location"
        static let deviceInform = "deviceInform"
        static let osVersion = "osVersion"
    }
    
    struct RemarkAndRate {
        static let note = "note"
        static let rating = "rating"
    }
    
    struct LocalKey {
        static let caseId = "caseId"
        static let doneRequest = "done"
        static let currentLogcation = "Currentlocation"
        static let userCancel = "userCacel"
        static let agent = "agentCase"
        static let image = "image"
        static let numberImage = "numberImage"
    }
    
}

struct UIParameter {
    struct Color {
        static let NavigationBackground = UIColor.init(red: 225.0/255.0, green: 194.0/255.0, blue: 15.0/255.0, alpha: 1.0)
        static let NavigationText = UIColor.white
    }
    
    static let AvatarBorderWidth : CGFloat = 6.0
    static let AvatarSize : CGFloat = 800
    static let PhotoUploadSize : CGFloat = 800

    struct LeftMenu {
        static let InforCellHeight : CGFloat = 250
        static let InforCellIdentify = "LeftMenuInfoTableCell"
        static let ActionCellHeight : CGFloat = 65
        static let ActionCellIdentify = "LeftMenuActionTableCell"
    }
}

// MARK: - Type user login
let facebook = 1
let google = 2
let systemUser = 3

func logoutUser() {
    let user = UserDefaults.standard
    let userType:Int = user.integer(forKey: Key.USER_TYPE)
    if userType == facebook {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
    } else if userType == google {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
    }
    
    UserHelper().deleteUserInfor()
}

// MARK: - Mobile format
enum MobileFormat: Int {
    case formatOne = 1, formatTow, formatThree // formatOne: 011-xxxx xxxx; formart tow 015-xxxx xxxx formatThree: xxx-xxx xxxx
}
let formatOne = "011"
let formatTwo = "015"


// MARK: Global variable
let MIN_LENGHT_PASSWORK = 8
let MIN_LENGTH_PHONE = 10
let MAX_WITH_TOOLTIP: CGFloat = 200.0
let TEXT_MAX_LENGHT = 50
let PHONE_MAX_LENGHT = 12
let PHONE_MAX_LENGHT_LONG = 13
let SCALE_IMAGE_SEND:CGFloat = 0.4
let SCALE_IMAGE_VIEW:CGFloat = 0.8
let WIDTH_IMAGE_VIEW = 260
let HEIGHT_IMAGE_VIEW: CGFloat = 450.0
let WIDTH_VIEW_IMAGE: CGFloat = 300.0



// MARK: - Message
let emailError = "Please input your email!"
let validEmail = "Invalid email. Please try again."
let passwordEmpty = "Please input your password!"
let passwordNotMacth = "These passwords don't match. Please try again."
let passwordInvalid = "Invalid password. Please try again."
let passwordNotTheSame = "New password can't be the same with old password."
let emailInValid = "Invalid email. Please try again."
let myKadInValid = "Invalid my Kad my Kid. Please try again."
let phoneNumberInvalid = "This mobile number format is not recognized. Please try again."
let phoneNumberTenChar = "Your mobile number must have at least 10 characters"
let passNumberChar = "Your password number must have at least 8 characters"
let passwordGuide = "Your password must contain minimum 8 characters, at least one lowercase character, one uppercase character, one number."
let textFieldEmpty = "Please enter a valid email address"
let require = "This field is required."
let internetNotconnect = "No initernet connected, Please check your internet!"
let authenError = "Authentication error"
let noCar = "Please enter your car registration number to update user profile"
let cancelRequest = "Do you want to cancel this request?"
let cancelServiceMessage = "Do you want to cancel this service?"
let deleteImageMessage = "Do you want to delete this picture?"

// new 
let currentPassw = "Incorrect password. Please try again."
let confirmDelete = "Are you sure you want to delete this item?"
let unknownAddress = "unknown address"
let notFoundCaseType = "No found any service"
let emergencyCall = "Emergency call"
let reload = "Reload"
let failMessage = "Fail to cancel, Had some problem while conneting to server."
let assignAgent = "Our agent has picked up your request. He will contact you soon."
let maxImageMessage = "Sorry, you have reached the maximum number of photos allowed."
// MARK: - Tooltip
var popTip: AMPopTip?
func setupTooltip() ->  Void{
    popTip = AMPopTip()
    popTip?.shouldDismissOnTap = true
    popTip?.shouldDismissOnTapOutside = false
    popTip?.edgeMargin = 5
    popTip?.offset = 2
    popTip?.edgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 10)
    popTip?.popoverColor = UIColor.darkGray
    popTip?.borderColor = UIColor.red
    popTip?.borderWidth = 1
    
}

enum Expiry:Int {
    case unexpired = 1, expirySoon, expired
    
    var color: UIColor {
        switch self {
        case .unexpired:
            return UIColor.init(red: 112/255, green: 180/255, blue: 31/255, alpha: 1.0)
        case .expirySoon:
            return UIColor.init(red: 251/255, green: 106/255, blue: 0/255, alpha: 1.0)
        case .expired:
            return UIColor.init(red: 220/255, green: 63/255, blue: 9/255, alpha: 1.0)
        }
    }
}

// MARK: - Extension scrollview
extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}

// MARK: - Main Navigation
enum LeftMenuAction : Int {
    case GetHelp = 0, AddMoreCar, Account,  Logout //Settings,
    
    var description : String {
        switch self {
        case .GetHelp:
            return "Request Assistance"
        case .AddMoreCar:
            return "Verify Policy"
        case .Account:
            return "Account Information"
//        case .Settings:
//            return "Settings"
        case .Logout:
            return "Logout"
        }
    }
    
    static let actionCount : Int = Logout.rawValue + 1
}

enum ControllerID : Int {
    case Login = 0
    case ForgotPassword
    case ChangePassword
    case Register
    case Verify
    case UserInformation
    case EditUserInformation
    case RequestAssistance
    case Settings
    case RequestDetail
    case Waiting
    case serviceProvider
    case serviceList
    case serviceDetail
    case remarkAndRate
    case cancellation
}

func getMainNavigation() -> MainNavigationViewController? {
    let application = UIApplication.shared
    
    return (application.delegate as? AppDelegate)?.mainNavigation
}

func getNavigationWithRootID (id : LeftMenuAction) -> MainNavigationViewController? {
    
    if let nav = getMainNavigation() {
        let rootController = nav.viewControllers[0]
        
        var newController : UIViewController = rootController
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        switch id {
        case .GetHelp:
            if !rootController.isKind(of: RequestAssistanceViewController.self) {
                newController = storyboard.instantiateViewController(withIdentifier: "requestAssistanceController")
            }
        case .AddMoreCar:
            if !rootController.isKind(of: VerifyViewController.self) {
                newController = storyboard.instantiateViewController(withIdentifier: "verifyController")
            }
        case .Account:
            if !rootController.isKind(of: UserDetailViewController.self) {
                newController = storyboard.instantiateViewController(withIdentifier: "userdetailController")
            }
//        case .Settings:
//            if !rootController.isKind(of: SettingViewController.self) {
//                newController = storyboard.instantiateViewController(withIdentifier: "settingController")
//            }
        case .Logout:
            newController = rootController
        }
        
        if newController != rootController {
            nav.setViewControllers([newController], animated: true)
        }
        
        return nav
    }
    
    return nil
}

func getControllerID (id : ControllerID) -> UIViewController {
    var newController : UIViewController
    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
    
    switch id {
    case .Login:
        newController = storyboard.instantiateViewController(withIdentifier: "loginController")
    case .ForgotPassword:
        newController = storyboard.instantiateViewController(withIdentifier: "forgotpassController")
    case .ChangePassword:
        newController = storyboard.instantiateViewController(withIdentifier: "changepassController")
    case .Register:
        newController = storyboard.instantiateViewController(withIdentifier: "registerController")
    case .Verify:
        newController = storyboard.instantiateViewController(withIdentifier: "verifyController")
    case .UserInformation:
        newController = storyboard.instantiateViewController(withIdentifier: "userdetailController")
    case .EditUserInformation:
        newController = storyboard.instantiateViewController(withIdentifier: "editInfoController")
    case .RequestAssistance:
        newController = storyboard.instantiateViewController(withIdentifier: "requestAssistanceController")
    case .Settings:
        newController = storyboard.instantiateViewController(withIdentifier: "settingController")
    case .RequestDetail:
         newController = storyboard.instantiateViewController(withIdentifier: "requestDetail")
    case .Waiting:
        newController = storyboard.instantiateViewController(withIdentifier: "waiting")
    case .serviceProvider:
        newController = storyboard.instantiateViewController(withIdentifier: "doneRequest")
    case .serviceList:
        newController = storyboard.instantiateViewController(withIdentifier: "servicelist")
    case .serviceDetail:
        newController = storyboard.instantiateViewController(withIdentifier: "serviceDetail")
    case .remarkAndRate:
        newController = storyboard.instantiateViewController(withIdentifier: "rating")
    case .cancellation:
        newController = storyboard.instantiateViewController(withIdentifier: "canellation")
    }
    
    return newController
}

// MARK: - Clear all notifycation
func clearAllNotify() {
    if #available(iOS 10.0, *) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // To remove all pending notifications which are not delivered yet but scheduled.
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
    } else {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UIApplication.shared.cancelAllLocalNotifications()
    }
}
// MARK - Currency unit of country
enum Currency : String {
    case RM   = "RM "
    case USD  = "USD "
    case VND  = "VND "
    // And more ...
}
// MARK - Define key to log event google analytics
enum GoogleAnalyticsEventKey {
    static let  REGISTER_ACCOUNT_EVENT = "Register_account"
    static let  REGISTER_ACCOUNT_KEY   = "1"
    static let  CALL_SOS_EVENT         = "Call_SOS"
    static let  CALL_SOS_KEY           = "2"
    static let  LOGIN_EVENT            = "Login"
    static let  LOGIN_KEY              = "3"
    static let  VERIFY_POLICY_EVENT    = "Verify_policy"
    static let  VERIFY_POLICY_KEY      = "4"
    static let  REQUEST_ASSISTANCE_EVENT = "Request_Assistant"
    static let  REQUEST_ASSISTANCE_KEY = "5"
    static let  CALL_AGENT_EVENT       = "Call_Agent"
    static let  CALL_AGENT_KEY         = "6"
    static let  FEEDBACK_EVENT         = "Feedback"
    static let  FEEDBACK_KEY           = "7"
    static let  FORGOT_PASS_EVENT      = "Forgot_pass_account"
    static let  FORGOT_PASS_KEY        = "8"
    static let  CAPTURE_PICTURE_EVENT  = "Capture picture"
    static let  CAPTURE_PICTURE_KEY    = "9"

}
enum GoogleAnalyticsParameterKey {
    static let  PARAMETER_EVENT = "Event"
    static let  PARAMETER_KEY   = "Key"
}

// MARK - Define Struct case status response
enum CaseStatus : UInt8 {
    case new_case
    case service_active
    case close_case
    case hold_case
    case close_case_unsolve
    case cancel_case
}
enum CaseStatusKey {
    static let code = "code"
    static let message = "message"
    static let caseStatus = "caseStatus"
    static let agentAssign = "agentAssign"
}
struct CaseStatusResponse {
    var code: UInt8?
    var message: String?
    var caseStatus: CaseStatus?
    var agentAssign: String?
}

//sang
//struct Color {
//    let GRAY_COLOR_LINETABLEVIEW_REVIEWSUMMARY = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
//}
