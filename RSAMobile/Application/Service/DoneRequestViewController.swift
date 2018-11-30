//
//  DoneRequestViewController.swift
//  RSAMobile
//
//  Created by Nguyen Van Trung on 5/3/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class DoneRequestViewController: BaseViewController {

    @IBOutlet weak var carNumber: UILabel!
    @IBOutlet weak var workshopName: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    var caseId: Int?
    var userInfo: [AnyHashable : Any]?
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.setBackgroundImage(UIImage(named: "btn_hover"), for: .highlighted)
        doneButton.setTitleColor(UIColor.black, for: .highlighted)
        extractUserInfo()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func extractUserInfo () {
        guard userInfo != nil else {
            return
        }
        
        caseId = Int((userInfo?[Key.Notify.caseId] as? String)!)
        workshopName.text = userInfo?[Key.Notify.provider] as? String
        discriptionLabel.text = "Distance: " + (userInfo?[Key.Notify.distance] as! String) + ". Estimate time: " + (userInfo?[Key.Notify.estimateTime] as! String)
        carNumber.text = userInfo?[Key.Notify.carNumber] as? String
    }

    @IBAction func tapedDone(_ sender: Any) {
        let serviceList = getControllerID(id: .serviceList) as! ServiceListViewController
        serviceList.caseId = self.caseId
        self.navigationController?.pushViewController(serviceList, animated: true)
    }
}
