//
//  MainNavigationViewController.swift
//  TCMapProj
//
//  Created by Trần Thị Yến Linh on 8/24/16.
//  Copyright © 2016 TCSystems. All rights reserved.
//

import UIKit
import SideMenu

class MainNavigationViewController : UINavigationController {
    
    let leftMenuNavigation : UISideMenuNavigationController? = {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)

        return storyboard.instantiateViewController(withIdentifier: "leftMenuNavigationController") as? UISideMenuNavigationController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let leftMenuController = self.leftMenuNavigation?.viewControllers[0] as? LeftMenuTableViewController {
            leftMenuController.mainNavigation = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
}
