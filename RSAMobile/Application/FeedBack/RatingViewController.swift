//
//  RatingViewController.swift
//  RSAMobile
//
//  Created by Nguyen Van Trung on 5/15/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit
import Firebase
class RatingViewController: UIViewController {

    var caseId: Int?
    @IBOutlet weak var remarkText: UITextView!
    @IBOutlet weak var rating: RatingControl!
    @IBOutlet weak var skipButton: UIButton!
    
    let failMessage = "Have some problem while send request to server. Plese try again"
    let loading = LoadingOverlay()
    override func viewDidLoad() {
        super.viewDidLoad()
        rating.layer.cornerRadius = 5.0
        rating.layer.borderWidth = 1.0
        skipButton.isHidden = true
        rating.layer.borderColor = UIColor.init(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0).cgColor
        remarkText.layer.borderWidth = 1.0
        remarkText.layer.cornerRadius = 5.0
        remarkText.layer.borderColor = UIColor.init(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0).cgColor
        self.hideKeyboardWhenTappedAround()
        let user = UserDefaults.standard
        user.set(0, forKey: Key.LocalKey.caseId)
        clearAllNotify()
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
    

    @IBAction func tapedDone(_ sender: Any) {
        // Log event feed back action to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.FEEDBACK_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.FEEDBACK_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.FEEDBACK_KEY as NSObject
            ])

        guard caseId != nil else {
            return
        }
        let id:Int = caseId!
        let url = ServerConfigure.url + ServerConfigure.Path.rating + String(id)
        let body = [Key.RemarkAndRate.note: remarkText.text, Key.RemarkAndRate.rating: String(rating.rating)] as Dictionary<String, String>
        loading.showOverlay(view: view)
        RequestService.shareInstance.Post(keyForDictTask: ServerConfigure.Path.rating, url, body: body, isCheckOuthen: true, successRespose: {(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                if let resultDict = response.dictData {
                    let code = resultDict["code"]  as! Int
                    if code == successCode {
                        self.showSuccess(message: resultDict[Key.CancelAssitance.message] as! String)
                    } else {
                        self.showError(message: resultDict["message"] as! String)
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
    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func showSuccess(message: String) {
        let alert = UIAlertController.init(title: successTitle, message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: alertTitleA, style: .default, handler: {(action) in
            let getHelp = getControllerID(id: .RequestAssistance)
            self.navigationController?.pushViewController(getHelp, animated: true)
            alert.dismiss(animated: false, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)

        
    }
 
    @IBAction func tapedSkip(_ sender: Any) {
        let getHelp = getControllerID(id: .RequestAssistance)
        self.navigationController?.pushViewController(getHelp, animated: true)
    }
    
   
    

}
