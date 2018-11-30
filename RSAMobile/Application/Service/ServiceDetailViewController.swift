//
//  ServiceDetailViewController.swift
//  RSAMobile
//
//  Created by Nguyen Van Trung on 5/9/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import UIKit

class ServiceDetailViewController: BaseViewController, ServiceDelegate, UIScrollViewDelegate {

    var pagePosition:Int?
    var serviceList:[ActivationLog] = []
    var listPage: [ServiceDetail] = []
    let loading = LoadingOverlay()
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var serviceScrollView: UIScrollView!
    @IBOutlet weak var wiewScroll: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTopView()
        setupPageScrollView();
        serviceScrollView.delegate = self
        self.title = "Service Detail"
        let rightBarButton = UIBarButtonItem(image: UIImage.init(named: "ic_call"), style: .done, target: self, action: #selector(tapedCall(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        // Do any additional setup after loading the view.
        wiewScroll.isScrollEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.backItem?.title = ""
        setOtherScreen()
    }
    
    func setupPageView()->[ServiceDetail] {
        var lisPage: [ServiceDetail] = []
        
        for i in 0..<serviceList.count {
            let service: ServiceDetail = Bundle.main.loadNibNamed("ServiceDetail", owner: self, options: nil)?.first as! ServiceDetail
            service.setupView()
            let info = serviceList[i]
            
            service.parentServiceName.text = info.getParentService()
            service.childServiceName.text = info.getServiceAddition()
            if let parentPrice = info.getServiceParentPrice(){
                service.parentServiceFee.text = String(parentPrice)
            }
            
            if let childPrice = info.getAdditionServicePrice() {
                service.childServiceFee.text = String(childPrice)
            }
            
            if let adjFee = info.getAdjust() {
                service.adjFee.text = String(adjFee)
            }
            
            service.AdjName.text = "Adj"
            var note:String = ""
            note.append(info.getNote())
            service.noteTextView.text = note
            service.delegate = self
            lisPage.append(service)
            if info.getStatus() == ACTIVE {
                service.cancelButton.isHidden = false
            } else {
                service.cancelButton.isHidden = true
            }
        }
        
        return lisPage
    }
    
    func tapedCall(_ sender: Any) {
        guard let number = URL(string: "telprompt://" + contactSupportNumber) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
    }
    
    func setupPageScrollView() {
        listPage = setupPageView()
        let subviews = self.serviceScrollView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        pageControl.numberOfPages = listPage.count
        
        serviceScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: serviceScrollView.frame.height)
        serviceScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(listPage.count), height: serviceScrollView.frame.height)
        serviceScrollView.isPagingEnabled = true
        for i in 0..<listPage.count {
            listPage[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: serviceScrollView.frame.origin.y, width: view.frame.width, height: serviceScrollView.frame.height)
            serviceScrollView.addSubview(listPage[i])
        }
        if let position = pagePosition {
            pageControl.currentPage = position
        } else {
            pagePosition = 0
        }
        let x = (serviceScrollView.contentOffset.x + view.frame.width) * CGFloat.init(pagePosition!)
        serviceScrollView.contentOffset = CGPoint(x: x, y: 0.0)
        
    }
    
    func initTopView() {
        guard pagePosition != nil else {
            return
        }
        let info = serviceList[pagePosition!]
        serviceName.text = info.getParentService()
        providerName.text = info.getProviderName()
        if let price = info.getTotal() {
            totalPrice.text = RINGIT + " " + String(price)
        } else {
            totalPrice.text = RINGIT
        }
        
    }
    
    // MARK: - Service delegate
    func cancelService() {
        self.view.endEditing(true)
        let alert = UIAlertController.init(title: confirm, message: cancelServiceMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: alertTitleA, style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            self.requestCancel()
        }))
        alert.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func requestCancel() {
        self.loading.showOverlay(view: view)
        let service = self.serviceList[pagePosition!]
        let page = listPage[pagePosition!]
        let body = ["note": page.noteTextView.text] as Dictionary<String, String>
        if let id = service.getActivationLogId() {
            let url = ServerConfigure.url + ServerConfigure.Path.cancelService + String(id)
            RequestService.shareInstance.putRequest(keyForDictTask: ServerConfigure.Path.cancelService, url,body:body, isCheckOuthen: true, successRespose: {(response) in
                OperationQueue.main.addOperation {
                    self.loading.hideOverlayView()
                }
                if let dictionResult = response.dictData {
                    let success = dictionResult[Key.CancelAssitance.code] as! Int
                    if (success == successCode) {
                        if let confirm = dictionResult[Key.CancelAssitance.confirm] {
                            let alert = UIAlertController.init(title: waring, message: dictionResult[Key.CancelAssitance.message] as? String, preferredStyle: .alert)
                            let ok = UIAlertAction.init(title: "OK", style: .default, handler: {(action) in
                                self.cancelConfirm(confirm: confirm as! Int, id: id, body: body)
                                alert.dismiss(animated: true, completion: nil)
                            })
                            let cancel = UIAlertAction.init(title: "Cancel", style: .default, handler: {(action) in
                                alert.dismiss(animated: true, completion: nil)
                            })
                            alert.addAction(ok)
                            alert.addAction(cancel)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            OperationQueue.main.addOperation {
                                self.showSuccess(message: dictionResult[Key.CancelAssitance.message] as! String)
                            }
                            
                        }
                        
                        
                    }
                }
            }, failureResponse: {(error) in
                OperationQueue.main.addOperation {
                    self.showError(message: failMessage)
                    self.loading.hideOverlayView()
                }
                
            })
        }
    }
    
    func textDidEditTing() {
        self.wiewScroll.isScrollEnabled = true
    }
    
    func textDidEndEditing() {
        self.wiewScroll.scrollToTop()
        self.wiewScroll.isScrollEnabled = false
    }
    
    func cancelConfirm(confirm: Int, id: Int, body: Dictionary<String, String>) {
        loading.showOverlay(view: view)
        let url = ServerConfigure.url + ServerConfigure.Path.cancelServiceConfirm + String(id)
        RequestService.shareInstance.putRequest(keyForDictTask: ServerConfigure.Path.cancelServiceConfirm, url, body: body, isCheckOuthen: true, successRespose: {(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                if let dictionResult = response.dictData {
                    let success = dictionResult[Key.CancelAssitance.code] as! Int
                    if (success == successCode) {
                        self.showSuccess(message: dictionResult[Key.CancelAssitance.message] as! String)
                    }
                }
            }
            
        }, failureResponse: {(error) in
            OperationQueue.main.addOperation {
                self.showError(message: failMessage)
                self.loading.hideOverlayView()
            }
            
        })
        
    }
    
    func showSuccess(message: String) {
        let alert = UIAlertController.init(title: "Success", message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: {(action) in
//            self.serviceList.remove(at: self.pagePosition!)
//            self.initTopView()
//            self.setupPageScrollView();
            let user = UserDefaults.standard
            user.set(CANCEL_SERVICE, forKey: Key.UserActive.cancelService)
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }

    
    // MARK: - Scroll view delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(serviceScrollView.contentOffset.x/view.frame.width)
        pagePosition = Int(pageIndex)
        pageControl.currentPage = Int(pageIndex)
        initTopView()
    }

    
}
