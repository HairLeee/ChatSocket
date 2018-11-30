//
//  LeftMenuTableViewController.swift
//  RSAMobile
//
//  Created by tanchong on 3/24/17.
//  Copyright © 2017 Trung. All rights reserved.
//

import UIKit
import Firebase
class LeftMenuTableViewController: UITableViewController {
    
    var mainNavigation : MainNavigationViewController?
    var mesageStr = "Logout is failed"
    var actionID : LeftMenuAction?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let footerView = UIView()
        //footerView.backgroundColor = UIParameter.Color.NavigationBackground
        self.tableView.tableFooterView = footerView
        
        //self.tableView.backgroundColor = UIParameter.Color.NavigationBackground
        self.tableView.separatorColor = UIColor.init(red: 211/255, green: 160/255, blue: 8/225, alpha: 1.0)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LeftMenuTableViewController.didDownloadAvatarImage(noti:)), name: NSNotification.Name(rawValue:notificationAvatarImageFinishDownload), object: nil)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:notificationAvatarImageFinishDownload), object: nil)
    }
    
    func didDownloadAvatarImage(noti: Notification) -> Void {
        if let _ = noti.object as? UIImage {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return LeftMenuAction.actionCount
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UIParameter.LeftMenu.InforCellHeight
        }
        
        return UIParameter.LeftMenu.ActionCellHeight
    }
    
    func showError(message: String) {
        let nav = getNavigationWithRootID(id: actionID!)
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        nav?.present(alert, animated: true, completion: nil)
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identify = indexPath.section == 0 ? UIParameter.LeftMenu.InforCellIdentify : UIParameter.LeftMenu.ActionCellIdentify
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath)
        
        if indexPath.section == 0 {
            let userHelper = UserHelper()
            (cell as! InforLeftMenuTableViewCell).avatarView.image = self.getAvatarImage()
            (cell as! InforLeftMenuTableViewCell).nameLabel.text = userHelper.getUserName()
            (cell as! InforLeftMenuTableViewCell).emailLabel.text = userHelper.getUserEmail()
            
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);    // Clear seperator for this cell
        } else {
           actionID = LeftMenuAction(rawValue: indexPath.row)!
            (cell as! LeftMenuTableViewCell).titleLabel.text = actionID?.description
            (cell as! LeftMenuTableViewCell).markLabel?.isHidden = true
            
            if indexPath.row == 0 {
                (cell as! LeftMenuTableViewCell).displayMarkLabel(content: "URGENT")
                (cell as! LeftMenuTableViewCell).titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
            }
            
            if indexPath.row == LeftMenuAction.actionCount - 1 {
                cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
            }
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
           actionID = LeftMenuAction(rawValue: indexPath.row)!
            
            dismiss(animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: false)
            
            let nav = getNavigationWithRootID(id: actionID!)
            
            if actionID == .Logout {
                gAvatarImage = nil
                gBlurAvatarImage = UIImage(named: "bg")
                // Display message
                let alert = UIAlertController.init(title: actionID?.description, message: "Are you sure you want to logout?", preferredStyle: .alert)
                
                let actionOK = UIAlertAction.init(title: actionID?.description, style: .default, handler: { (action : UIAlertAction) -> Void in
                    let body = [Key.Logout.token : FIRInstanceID.instanceID().token()] as! Dictionary<String, String>
                    let url = ServerConfigure.url + ServerConfigure.Path.logoutUser;
                    
                    RequestService.shareInstance.Post(keyForDictTask: ServerConfigure.Path.logoutUser, url, body: body, isCheckOuthen: true, successRespose: {(response) in
                        print("%@",response)
                        if let dictionResult = response.dictData {
                           self.mesageStr = (dictionResult["message"] as? String)!
                            let success = dictionResult["code"] as! Int
                            if (success == successCode) {
                                        OperationQueue.main.addOperation {
                                            logoutUser()
                                            RequestService.shareInstance.session?.getAllTasks(completionHandler: { (tasks) in
                                                tasks.forEach({ (eachTask) in
                                                    eachTask.cancel()
                                                })
                                            })
                                            UserDefaults.standard.set(0, forKey: Key.LocalKey.caseId)
                                            let controller = getControllerID(id: .Login)
                                            getMainNavigation()?.setViewControllers([controller], animated: true)
                                        }
                            } else {
                                OperationQueue.main.addOperation {
                                    self.showError(message: self.mesageStr)
                                }
                            }
                        } else {
                            OperationQueue.main.addOperation {
                                self.showError(message: self.mesageStr)
                            }
                        }
                    }, failureResponse: {(error) in
                        OperationQueue.main.addOperation {
                            self.showError(message: self.mesageStr)
                        }
                    })

                })
                
                let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(actionOK)
                alert.addAction(actionCancel)
                
                nav?.present(alert, animated: true, completion: nil)

            }        
        }
    }
}
