//
//  BaseViewController.swift
//  RSAMobile
//
//  Created by tanchong on 3/24/17.
//  Copyright © 2017 Trung. All rights reserved.
//

import UIKit
import SideMenu


class BaseViewController: UIViewController {

    var userType: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.navigationController?.navigationBar.barTintColor = UIParameter.Color.NavigationBackground
        self.navigationController?.navigationBar.tintColor = UIParameter.Color.NavigationText
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = nil
        self.navigationController?.navigationBar.tintColor = nil
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func setOtherScreen() {
        let user = UserDefaults.standard
        user.set(OTHER_SCREEN, forKey: Key.UserActive.serviceList)
    }


}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


class ContainSideMenuBaseViewController : BaseViewController {
    
    var showLeft = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create side Menu
        if let nav = getMainNavigation() {
            
            SideMenuManager.menuLeftNavigationController = nav.leftMenuNavigation
            
            // Enable gestures. The left and/or right menus must be set up above for these to work.
            // Note that these continue to work on the Navigation Controller independent of the view controller it displays!
            SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
            //SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
            
            SideMenuManager.menuPresentMode = .menuSlideIn
            SideMenuManager.menuFadeStatusBar = false

            // Add left menu bar button
            //let leftBarButton = UIBarButtonItem(title: "Left Menu", style: .plain, target: self, action: #selector(ContainSideMenuBaseViewController.onLeftMenu(sender:)))
//            let leftBarButton = UIBarButtonItem(image: UIImage.init(named: "icon_menu"), style: .done, target: self, action: #selector(ContainSideMenuBaseViewController.onLeftMenu(sender:)))
//            self.navigationItem.leftBarButtonItem = leftBarButton
            let leftBarButton = UIButton(type: .custom)
            leftBarButton.setImage(UIImage(named: "icon_menu"), for: .normal)
            leftBarButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            leftBarButton.addTarget(self, action: #selector(self.onLeftMenu(sender:)), for: .touchUpInside)
            let item = UIBarButtonItem(customView: leftBarButton)
            self.navigationItem.setLeftBarButtonItems([item], animated: true)
        }
    }
    
    func onLeftMenu (sender : Any) {
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
    
}
