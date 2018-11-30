//
//  AppDelegate.swift
//  RSAMobile
//
//  Created by LinhTY on 3/23/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import CoreData
import Google
import GoogleMaps
import GooglePlaces
import Firebase
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainNavigation : MainNavigationViewController?
    let gcmMessageIDKey = "gcm.message_id"
    var userInfo: [AnyHashable : Any]?
    var arrUserInfor = [[AnyHashable : Any]]()
    var arrUserInforBackup = [[AnyHashable : Any]]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GMSServices.provideAPIKey(GOOGLE_MAP_KEY)
        GMSPlacesClient.provideAPIKey(GOOGLE_PLACES_KEY)
        GMSServices.provideAPIKey(GOOGLE_MAP_KEY)
        UIApplication.shared.statusBarStyle = .lightContent
        
        registerRemoteAPNS(application: application)
        
        if let rootController = window?.rootViewController {
            if rootController.isKind(of: MainNavigationViewController.self) {
                self.mainNavigation = (rootController as? MainNavigationViewController)
            }
        }
        
//        if let launchOpts = launchOptions as [UIApplicationLaunchOptionsKey: Any]? {
//            if let notificationPayload = launchOpts[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
//                
//                //Handle push notification here
//            }
//            else if let notification = (launchOpts as NSDictionary).object(forKey: "UIApplicationLaunchOptionsLocalNotificationKey") as? UILocalNotification {
//                //Handle local notification here
//            }
        return true
    }
    // register remote APNS
    func registerRemoteAPNS(application: UIApplication) -> Void {
        // Regist for Remote notification from FCM
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // Firebase configure
//        FIRApp.configure()
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let hanlded =  FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        GIDSignIn.sharedInstance().handle(url as URL!,
                                          sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                          annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return hanlded
    }

    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        // Unregist notification to check whenever the FCM token are generated
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // Stop Firebase message
       // FIRMessaging.messaging().disconnect()

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Regist notification to check whenever the FCM token are generated
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification(_:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        connectToFcm()
        executeNotifier()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
        guard FIRInstanceID.instanceID().token() != nil else {
            return
        }
        registerRemoteAPNS(application: application)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        guard FIRInstanceID.instanceID().token() != nil else {
            return
        }
        registerRemoteAPNS(application: application)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // Print message ID.
        // Print full message.
        let state = UIApplication.shared.applicationState
        if state == .active {
            return
        }
        self.arrUserInfor.append(userInfo)
        self.arrUserInforBackup.append(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)

    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "RSAMobile")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - FIRInstanceIDTokenRefresh Notification
    func tokenRefreshNotification(_ notification: Notification) {
        // Connect to FCM since connection may have failed when attempted before having a token.
        
        connectToFcm()
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

    
}


extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        userInfo = notification.request.content.userInfo
        let id = userInfo?[Key.notifyUpdate.caseId] as? String
        let status = userInfo?[Key.notifyStatusCase.status] as? String
        if status != nil{
            gotoFeadback(caseId: Int(id!)!)
        }
        let state = UIApplication.shared.applicationState
        if state == .active {
            let user = UserDefaults.standard
            let serviceList = user.integer(forKey: Key.UserActive.serviceList)
            // check if root view controller is instance of MyViewController
            if serviceList == 1 {
                //                let doneRequest = getControllerID(id: .serviceList) as! ServiceListViewController
                //                doneRequest.caseId = Int((userInfo?[Key.Notify.caseId] as? String)!)
                //                self.mainNavigation?.pushViewController(doneRequest, animated: false)
                guard let rvc = self.window?.rootViewController else {
                    return
                }
                if let vc = getCurrentViewController(rvc) {
                    (vc as? ServiceListViewController)?.getServiceList()
                }
                completionHandler([.alert, .badge, .sound])
            } else {
                let id = userInfo?[Key.notifyUpdate.caseId] as? String
                let agent = userInfo?[Key.notifyStatusCase.body] as? String
                if (agent != nil) {
                    gotoWaiting()
                } else if id != nil{
                    // gotoServicelist()
                    completionHandler([.alert, .badge, .sound])
                } else {
                    gotoDone()
                }
            }
            
        } else {
            // Change this to your preferred presentation option
            completionHandler([.alert, .badge, .sound])
        }
    }
    func executeNotifier() -> Void {
        while arrUserInfor.count > 0 {
            userInfo = arrUserInfor[0]
            let id = userInfo?[Key.notifyUpdate.caseId] as? String
            let status = userInfo?[Key.notifyStatusCase.status] as? String
            if status != nil{
                gotoFeadback(caseId: Int(id!)!)
            }
            let state = UIApplication.shared.applicationState
            if state == .active {
                let user = UserDefaults.standard
                let serviceList = user.integer(forKey: Key.UserActive.serviceList)
                // check if root view controller is instance of MyViewController
                if serviceList == 1 {
                    //                let doneRequest = getControllerID(id: .serviceList) as! ServiceListViewController
                    //                doneRequest.caseId = Int((userInfo?[Key.Notify.caseId] as? String)!)
                    //                self.mainNavigation?.pushViewController(doneRequest, animated: false)
                    guard let rvc = self.window?.rootViewController else {
                        return
                    }
                    if let vc = getCurrentViewController(rvc) {
                        (vc as? ServiceListViewController)?.getServiceList()
                        (vc as? ServiceListViewController)?.loading.hideOverlayView()
                    }
                } else {
                    let id = userInfo?[Key.notifyUpdate.caseId] as? String
                    let agent = userInfo?[Key.notifyStatusCase.body] as? String
                    if (agent != nil) {
                        gotoWaiting()
                    } else if id != nil{
                        // gotoServicelist()
                    } else {
                        gotoDone()
                    }
                }
                
            } else {
                // Change this to your preferred presentation option
            }
            arrUserInfor.remove(at: 0)
            
        }
    }
    func getCurrentViewController(_ vc: UIViewController) -> UIViewController? {
        if let pvc = vc.presentedViewController {
            return getCurrentViewController(pvc)
        }
        else if let svc = vc as? UISplitViewController, svc.viewControllers.count > 0 {
            return getCurrentViewController(svc.viewControllers.last!)
        }
        else if let nc = vc as? UINavigationController, nc.viewControllers.count > 0 {
            return getCurrentViewController(nc.topViewController!)
        }
        else if let tbc = vc as? UITabBarController {
            if let svc = tbc.selectedViewController {
                return getCurrentViewController(svc)
            }
        }
        return vc
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        userInfo = response.notification.request.content.userInfo
        let id = userInfo?[Key.notifyUpdate.caseId] as? String
        let status = userInfo?[Key.notifyStatusCase.status] as? String
        if status != nil{
            gotoFeadback(caseId: Int(id!)!)
        }
        let state = UIApplication.shared.applicationState
        if state == .active {
            let user = UserDefaults.standard
            let serviceList = user.integer(forKey: Key.UserActive.serviceList)
            // check if root view controller is instance of MyViewController
            if serviceList == 1 {
                //                let doneRequest = getControllerID(id: .serviceList) as! ServiceListViewController
                //                doneRequest.caseId = Int((userInfo?[Key.Notify.caseId] as? String)!)
                //                self.mainNavigation?.pushViewController(doneRequest, animated: false)
                guard let rvc = self.window?.rootViewController else {
                    return
                }
                if let vc = getCurrentViewController(rvc) {
                    (vc as? ServiceListViewController)?.getServiceList()
                }
                completionHandler()
            } else {
                let id = userInfo?[Key.notifyUpdate.caseId] as? String
                let agent = userInfo?[Key.notifyStatusCase.body] as? String
                if (agent != nil) {
                    gotoWaiting()
                } else if id != nil{
                    // gotoServicelist()
                    completionHandler()
                } else {
                    gotoDone()
                }
            }
            
        } else {
            // Change this to your preferred presentation option
            completionHandler()
        }
    }
    
    func gotoDone() {
        if checkLogin() {
            let doneRequest = getControllerID(id: .serviceProvider) as! DoneRequestViewController
            doneRequest.userInfo = userInfo
            self.mainNavigation?.pushViewController(doneRequest, animated: true)
        } else {
            if let rootController = window?.rootViewController {
                if rootController.isKind(of: MainNavigationViewController.self) {
                    self.mainNavigation = (rootController as? MainNavigationViewController)
                }
            }
        }
    }
    
    func gotoWaiting() {
        let agent = userInfo?[Key.notifyStatusCase.body] as? String
        let caseId = userInfo?[Key.notifyStatusCase.caseId] as? String
        if checkLogin() {
            let waiting = getControllerID(id: .Waiting) as! WaitingViewController
            waiting.agent = agent
            waiting.caseId = Int(caseId!)
            self.mainNavigation?.pushViewController(waiting, animated: true)
        } else {
            UserDefaults.standard.set(agent, forKey: Key.LocalKey.agent)
            UserDefaults.standard.set(caseId, forKey: Key.LocalKey.caseId)
            if let rootController = window?.rootViewController {
                if rootController.isKind(of: MainNavigationViewController.self) {
                    self.mainNavigation = (rootController as? MainNavigationViewController)
                }
            }
        }

    }
    
    func gotoServicelist() {
        if checkLogin() {
            let serviceList = getControllerID(id: .serviceList) as! ServiceListViewController
            serviceList.caseId = Int(userInfo?[Key.notifyUpdate.caseId] as! String)
            self.mainNavigation?.pushViewController(serviceList, animated: true)
        } else {
            if let rootController = window?.rootViewController {
                if rootController.isKind(of: MainNavigationViewController.self) {
                    self.mainNavigation = (rootController as? MainNavigationViewController)
                }
            }
        }
    }
    
    func gotoFeadback(caseId: Int) {
        if let rootController = window?.rootViewController {
            if ((getCurrentViewController(rootController) as? DoneRequestViewController) != nil) {
                let requestAssi = getControllerID(id: .RequestAssistance)
                self.mainNavigation?.pushViewController(requestAssi, animated: true)
            } else if ((getCurrentViewController(rootController) as? WaitingViewController) != nil) {
                let requestAssi = getControllerID(id: .RequestAssistance)
                self.mainNavigation?.pushViewController(requestAssi, animated: true)
            } else if ((getCurrentViewController(rootController) as? ServiceListViewController) != nil) {
                let rating = getControllerID(id: .remarkAndRate) as! RatingViewController
                rating.caseId = caseId
                self.mainNavigation?.pushViewController(rating, animated: true)
            }
        }
    
    }
    
    
    
    func checkLogin() -> Bool {
        let userDef = UserDefaults.standard
        if  (userDef.string(forKey: Key.AccountResponse.token) != nil) {
            userDef.set(0, forKey: Key.AccountResponse.notifyStart)
            return true
        }
        userDef.set(1, forKey: Key.AccountResponse.notifyStart)
        return false
    }
    
}

extension AppDelegate : FIRMessagingDelegate {
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage){
       gotoDone()
    }

}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
//    @IBInspectable
//    var borderWidth: CGFloat {
//        get {
//            return layer.borderWidth
//        }
//        set {
//            layer.borderWidth = newValue
//        }
//    }
    
//    @IBInspectable
//    var borderColor: UIColor? {
//        get {
//            if let color = layer.borderColor {
//                return UIColor(cgColor: color)
//            }
//            return nil
//        }
//        set {
//            if let color = newValue {
//                layer.borderColor = color.cgColor
//            } else {
//                layer.borderColor = nil
//            }
//        }
//    }
    
}

