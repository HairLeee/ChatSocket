//
//  RequestAssistanceViewController.swift
//  RSAMobile
//
//  Created by Hoang Trung on 4/11/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces
import DropDown
import Firebase

class RequestAssistanceViewController: ContainSideMenuBaseViewController,UIImagePickerControllerDelegate, UITextFieldDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, ButtonDelegate, UINavigationControllerDelegate , iCarouselDataSource, iCarouselDelegate{
    //var mMapView = GMSMapView()
    var locationManager = CLLocationManager()
    var marker = GMSMarker()
    var loading = LoadingOverlay()
    let failMessage = "Fail to load data, Had some problem while conneting to server."
    let activeMessage = "Your account is not active. Please go to your email and activate your account. Otherwise you can't send any request assistance"
    var isFirstLoad = true
    var listCar:[InsuranceObject] = []
    var listData = [String]()
    var listCaseType = [CaseTypeObject]()
    var resultsArray = [String]()
    var addressDropdown = DropDown()
    var carDropDrow = DropDown()
    let placesClient = GMSPlacesClient()
    var listButtonCase = [ButtonView]()
    var caseTypeChoosed:ButtonView?
    var insurance: InsuranceObject?
    let userDefault = UserDefaults.standard
    let carNoTag = 1
    let locationTag = 2
    let notTag = 3
    var userCacel:Int?
    var listImageAccident:[Data] = []
    let CASHID = 1
    var userNote:String?
    var originFrameNoteView :CGRect? = CGRect.zero
    let heightScreenIphone6Plus = 375
    
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var noteBackground: UIView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var currentButton: UIButton!
    @IBOutlet weak var dropButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var carNoTextField: UITextField!
    @IBOutlet weak var currentPosTextField: UITextField!
    @IBOutlet weak var caseTypeScroll: UIScrollView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var noteDoneButton: UIButton!
    
    
    @IBOutlet weak var scoringNoteView: UILabel!
    @IBOutlet weak var countView: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var imageiCarouselView: iCarousel!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var imageControll: UIPageControl!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var closeview: UIView!
    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet weak var cashButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initData()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BaseViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        imageiCarouselView.type = .linear
        imageiCarouselView.scrollSpeed = 0.5

        // register keyboard event show/hide for view controller
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)

    }
//    override var preferredStatusBarStyle : UIStatusBarStyle {
//        return .lightContent
//    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        // remove observer keyboard event
//        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.stopUpdatingLocation()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setOtherScreen()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // MARK: - Keyboard Show/Hiden
    /*
     Move noteview if  display overlapping noteview and keyboad
     */
    func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            // Get frame keyboard when show on screen
            let userInfo:NSDictionary = notification.userInfo! as NSDictionary
            let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.cgRectValue
            let deltaHeight = keyboardRectangle.size.height - (UIScreen.main.bounds.size.height - (noteView.frame.origin.y + noteView.frame.size.height))
            UIView.animate(withDuration: 1, animations: {
                // if have overlapping then move view
                if  deltaHeight > 0  {
                    // store origin frame of noteview
                    if self.originFrameNoteView == CGRect.zero {
                        self.originFrameNoteView = self.noteView.frame
                    }
                    // move noteview to deltaHeight
                    self.noteView.frame = CGRect.init(x: self.noteView.frame.origin.x, y: self.noteView.frame.origin.y - 10.0 - deltaHeight, width: self.noteView.frame.size.width, height: self.noteView.frame.size.height)
                }
            }, completion: { (Bool) in
                
            })

        }
    }
    /*
     Move noteview to origin frame
     */
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            UIView.animate(withDuration: 1, animations: {
                // Move noteview to origin frames
                if self.originFrameNoteView != CGRect.zero {
                    self.noteView.frame = self.originFrameNoteView!
                }
            }, completion: { (Bool) in
                
            })
        }
    }
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Init view
    func initView() {
        // topview
        topView.layer.shadowColor = UIColor.black.cgColor
        topView.layer.shadowOffset = CGSize.zero
        topView.layer.shadowOpacity = 0.5
        topView.layer.shadowRadius = 1.0
        topView.layer.cornerRadius = 8.0
        topView.layer.borderWidth = 1.0
        topView.layer.borderColor = UIColor.white.cgColor
        
        // Dropdow
        addressDropdown.anchorView = currentPosTextField
        addressDropdown.dataSource = resultsArray
        addressDropdown.width = currentPosTextField.frame.size.width
        addressDropdown.direction = .bottom
        addressDropdown.bottomOffset = CGPoint(x: 0, y:(addressDropdown.anchorView?.plainView.bounds.height)!)
        addressDropdown.selectionAction = { (index: Int, item: String) in
            self.currentPosTextField.text = item
            self.addressDropdown.hide()
            self.getLatLonFromAdress(address: item)
            self.view.endEditing(true)
        }
        
        carDropDrow.anchorView = carNoTextField
        carDropDrow.dataSource = listData
        carDropDrow.width = currentPosTextField.frame.size.width
        carDropDrow.direction = .bottom
        carDropDrow.bottomOffset = CGPoint(x: 0, y:(carDropDrow.anchorView?.plainView.bounds.height)!)
        carDropDrow.selectionAction = { (index: Int, item: String) in
            self.carNoTextField.text = item
            self.carDropDrow.hide()
        }

//        let call = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tapedCall(_sender:)))
//        self.navigationController?.navigationItem.rightBarButtonItem = call
        
        currentPosTextField.delegate = self
        carNoTextField.delegate = self
        noteButton.layer.cornerRadius = 5.0
        carNoTextField.tag = carNoTag
        currentPosTextField.tag = locationTag
        scoringNoteView.isHidden = true
        let call = UIButton(type: .custom)
        call.setImage(UIImage(named: "call_menu"), for: .normal)
        call.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        call.addTarget(self, action: #selector(self.tapedCall(_sender:)), for: .touchUpInside)
        let item = UIBarButtonItem(customView: call)
        self.navigationItem.setRightBarButtonItems([item], animated: true)
        self.navigationItem.title = "Request Assistance"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        
        carNoTextField.borderStyle = .none
        currentPosTextField.borderStyle = .none
        // note init
        noteBackground.isHidden = true
        noteView.layer.cornerRadius = 10.0
        noteView.isHidden = true
        noteText.layer.cornerRadius = 5.0
        noteDoneButton.layer.cornerRadius = 10.0

        initLocationManager()
        marker.isDraggable = true //
        marker.map = mapView
        countView.layer.cornerRadius = countView.frame.width / 2
        countView.clipsToBounds = true
        scoringNoteView.layer.cornerRadius = countView.frame.width / 2
        scoringNoteView.clipsToBounds = true
        //hiddenView()
        getListImage()
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
               self.currentButton.isHidden = true
            case .authorizedAlways, .authorizedWhenInUse: break
//                print("Access")
            }
        } else {
//            print("Location services are not enabled")
        }
          userCacel = userDefault.integer(forKey: Key.LocalKey.userCancel)
        deleteView.isHidden = true
        closeview.isHidden = true
        self.imageiCarouselView.isHidden = true
        imageiCarouselView.delegate = self
        imageiCarouselView.dataSource = self
    }
    
    func checkActiveAcount() {
        let user = UserHelper()
        let active = user.getActive()
        if active != ACTIVED {
            let alert =  UtilHelper.shareInstance.getAlert(title: "Notice", message: activeMessage, textAction: "Ok")
            self.present(alert, animated: true, completion: nil)
             enableButton(enable: false)
                
        } else {
            enableButton(enable: true)
        }
    }
    
    func enableButton(enable: Bool) {
        for i in 0..<listButtonCase.count {
            let button = listButtonCase[i]
            button.isUserInteractionEnabled = enable
        }
        currentButton.isUserInteractionEnabled = enable
        doneButton.isUserInteractionEnabled = enable
        dropButton.isUserInteractionEnabled = enable
        currentPosTextField.isUserInteractionEnabled = enable
        carNoTextField.isUserInteractionEnabled = enable
    }
    
    // MARK: - List case type
    func createCaseTypeView()->[ButtonView]  {
        var listButton:[ButtonView] = []
        for caseType in self.listCaseType {
            let button:ButtonView = Bundle.main.loadNibNamed("Button", owner: self, options: nil)?.first as! ButtonView
            button.frame = CGRect(x: 0, y: 0, width: view.frame.size.width / 2, height: 80)
            button.caseType = caseType
            button.delegate = self
            button.viewSetting()
            button.layer.borderColor = UIColor.init(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1.0).cgColor
            button.layer.borderWidth = 1.0
        
//            button.layer.shadowOpacity = 0.5
//            button.layer.shadowColor = UIColor.black.cgColor
//            button.layer.shadowOffset = CGSize.zero
//            button.layer.shadowRadius = 1.0
//            button.backgroundColor = UIColor.init(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0)
            
            listButton.append(button)
            
        }
        
        return listButton
        
    }
    
    func setupButtonScrollView(buttons: [ButtonView]) {
        let subViews = self.caseTypeScroll.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        
//        caseTypeScroll.frame = CGRect(x: 0, y: 0, width: buttons[0].frame.size.width * CGFloat(buttons.count), height: caseTypeScroll.frame.height)
//        caseTypeScroll.contentSize = CGSize(width: buttons[0].frame.size.width * CGFloat(buttons.count), height: caseTypeScroll.frame.height)
        caseTypeScroll.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: caseTypeScroll.frame.height)
        caseTypeScroll.contentSize = CGSize(width:view.frame.size.width, height: caseTypeScroll.frame.height)
        caseTypeScroll.isPagingEnabled = true
        
        for i in 0..<buttons.count {
            let button = buttons[i]
            let padding:CGFloat = 0.0//button.frame.width / 3
            if i == 0 {
                button.frame = CGRect(x:  padding, y: caseTypeScroll.frame.origin.y, width: button.frame.size.width, height: button.frame.size.height)
                caseTypeScroll.addSubview(buttons[i])
            } else if i == 1 {
                button.frame = CGRect(x: view.frame.width - button.frame.width - padding, y: caseTypeScroll.frame.origin.y, width: button.frame.size.width, height: button.frame.size.height - 2)
                caseTypeScroll.addSubview(buttons[i])
            } else {
                button.frame = CGRect(x: button.frame.width * CGFloat(i), y: caseTypeScroll.frame.origin.y, width: button.frame.size.width, height: button.frame.size.height)
                caseTypeScroll.addSubview(buttons[i])
            }
          
        }
        let userDefault = UserDefaults.standard
        userType = userDefault.integer(forKey: Key.USER_TYPE)
        if userType == systemUser {
            checkActiveAcount()
        }
        
        
       
    }

    
    func initData() {
        getListCar()
        getListCaseType()
    }
    
    func initLocationManager() {
        //Location manager code for fetch current location
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        // init map
        initMaps()
    }
    
    func initMaps() {
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        //mapView.settings.myLocationButton = true
    }
    
    
    // MARK: - Map delegate
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        if userCacel == USER_CACEL_CASE {
            isFirstLoad = false
           return
        }
        if let location = mapView.myLocation {
            if isFirstLoad {
                // Create maker
                marker.position = CLLocationCoordinate2D(latitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude))
                marker.title = currentPosTextField.text
             }
           
        }
    }
    
   
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        //mapView.animate(toZoom: MAP_ZOOM_DEFAULT)
//        CATransaction.begin()
//        CATransaction.setValue(Int(0.0), forKey: kCATransactionAnimationDuration)
//        // YOUR CODE IN HERE
//        CATransaction.commit()

    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
       // let location = marker.position
       // marker.position = CLLocationCoordinate2D(latitude: (location.latitude), longitude: (location.longitude))
        locationManager.stopUpdatingLocation()
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        marker.position = CLLocationCoordinate2D(latitude: (coordinate.latitude), longitude: (coordinate.longitude))
        marker.title = currentPosTextField.text
        latlonToAddress(lat: coordinate.latitude, lon: coordinate.longitude)
        locationManager.stopUpdatingLocation()
        self.mapView.isMyLocationEnabled = false
        self.noteText.resignFirstResponder()
        self.carNoTextField.resignFirstResponder()
        self.currentPosTextField.resignFirstResponder()

    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
 //      let position = marker.position
//       let camera = GMSCameraPosition.camera(withLatitude: (position.latitude), longitude:(position.longitude), zoom: Float(MAP_ZOOM_DEFAULT))
        

     //   let update = GMSCameraUpdate.setCamera(camera)
//        let update = GMSCameraUpdate.fit(<#T##bounds: GMSCoordinateBounds##GMSCoordinateBounds#>, withPadding: <#T##CGFloat#>)
      //  mapView.animate(with: update)
       
       // latlonToAddress(lat: position.latitude, lon: position.longitude)
//        let vancouver = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
//        let calgary = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
//        let bounds = GMSCoordinateBounds(coordinate: vancouver, coordinate: calgary)
//        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
//        mapView.camera = camera
        
//        let target = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
//        mapView.camera = GMSCameraPosition.camera(withTarget: target, zoom: 17)
       let update =  GMSCameraUpdate.setTarget(marker.position, zoom: 17)
        self.mapView.moveCamera(update)
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        
        latlonToAddress(lat: marker.position.latitude, lon: marker.position.longitude)
    }
    
    
    // MARK: - Location manager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom: Float(MAP_ZOOM_DEFAULT))
        mapView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
       
        if userCacel == USER_CACEL_CASE {
            if let currentLocation = userDefault.string(forKey: Key.LocalKey.currentLogcation) {
                currentPosTextField.text = currentLocation
                getLatLonFromAdress(address: currentLocation)
                userDefault.set(NEW_REQUEST, forKey: Key.LocalKey.userCancel)
            }
        } else {
            self.latlonToAddress(lat: (location?.coordinate.latitude)!, lon: (location?.coordinate.longitude)!)
            self.userDefault.set(self.currentPosTextField.text, forKey: Key.LocalKey.currentLogcation)
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom: Float(MAP_ZOOM_DEFAULT))
            mapView.animate(to: camera)
            marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
            marker.title = currentPosTextField.text
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.currentButton.isHidden = false
        switch status {
        case .notDetermined:
            manager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            self.currentButton.isHidden = true
            break
        }
    }

    
    
    func latlonToAddress(lat: Double, lon: Double) {
       
        let location = CLLocation(latitude: lat, longitude: lon) //changed!!!
       // print(location)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            //print(location)
            
            if error != nil {
                self.currentPosTextField.text = unknownAddress
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0]
                if let address = pm?.addressDictionary {
                    var text:String = ""
                    if let street: String = address["Street"] as! String? {
                       text = text.appending(street)
                        text = text.appending(", ")
                    }
//                    print(address["Name"] ?? "name")
//                    print(address["SubAdministrativeArea"] ?? "SubAdministrativeArea")
//                    print(address["Thoroughfare"] ?? "Thoroughfare")
//                    print(address["FormattedAddressLines"] ?? "FormattedAddressLines")
//                    print(address["CountryCode"] ?? "CountryCode")
                    if let subLocality: String = address["SubLocality"] as? String {
                       
                       text = text.appending(subLocality)
                        text = text.appending(", ")
                    }
                    
                    
                    if let city: String = address["SubAdministrativeArea"] as? String {
                        text = text.appending(city)
                        text = text.appending(", ")
                        
                    }
                    if let city: String = address["City"] as? String {
                        text = text.appending(city)
                        text = text.appending(", ")
                        
                    }
                    if let country: String = address["Country"] as? String{
                       
                       text = text.appending(country)
                    }
                    self.currentPosTextField.text = text.characters.count > 2 ? text : unknownAddress
                } else {
                    self.currentPosTextField.text = unknownAddress
                }
            }
            else {
                self.currentPosTextField.text = unknownAddress
            }
        })
    }
    

    @IBAction func setCurrentLocation(_ sender: Any) {
        self.mapView.isMyLocationEnabled = true
        self.locationManager.startUpdatingLocation()
    }
    // MARK: - Text field delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == locationTag {
           self.placeAutocomplete(text: textField.text!)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        if textField.tag == locationTag {
            textField.resignFirstResponder()
            self.getLatLonFromAdress(address: textField.text!)
            self.addressDropdown.hide()
        }
        self.view.endEditing(true)
        return false
    }
    
    func placeAutocomplete(text: String) {
        let visibleRegion = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        placesClient.autocompleteQuery(text, bounds: bounds, filter: filter, callback: {
            (results, error) -> Void in
            guard error == nil else {
//                print("Autocomplete error \(String(describing: error))")
                return
            }
            if let results = results {
                self.resultsArray.removeAll()
                for result in results {
                    self.resultsArray.append(result.attributedFullText.string)
                }
                self.addressDropdown.dataSource = self.resultsArray
                self.addressDropdown.show()
            }
        })
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image:UIImage = (info[UIImagePickerControllerOriginalImage] as! UIImage?)!
        image = image.cropToSize(CGSize(width: UIParameter.PhotoUploadSize, height: UIParameter.PhotoUploadSize))
        if let imageData:Data = image.jpeg(.medium) {
             self.listImageAccident.append(imageData)
        } else {
             self.listImageAccident.append(UIImagePNGRepresentation(image)!)
        }
        
        self.saveImage()
        self.hiddenView()
        self.imageiCarouselView.reloadData()
        self.dismiss(animated: true, completion: nil);
    }

    
    
    // MARK: - Button delegate
    func chooseService(buttonView: ButtonView) {
        for button in listButtonCase {
            if (button.caseType.getId() == buttonView.caseType.getId()) {
                button.backgroundColor = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0)
            } else {
                button.backgroundColor = UIColor.white
            }
            
        }
        caseTypeChoosed = buttonView
    }
    
    // MARK: - CAROUSEL delegate
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        imageControll.numberOfPages =  listImageAccident.count
        return listImageAccident.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var imageview: UIImageView
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
           imageview = view
        } else {
            imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 800))
            var image = UIImage(data: listImageAccident[index])
            guard image != nil else {
                return imageview
            }
           
            imageview.layer.cornerRadius = 5.0
            imageview.clipsToBounds = true
            if isPotraitImage(image: image!) {
                let scale = (HEIGHT_IMAGE_VIEW) / (image?.size.height)!
                let width = image?.size.width
                image = image?.cropToSize(CGSize(width: width! * scale , height: HEIGHT_IMAGE_VIEW))
                imageview.image = image
                imageview.frame = CGRect(x: 0, y: 0, width: Int((image?.size.width)!), height: Int(HEIGHT_IMAGE_VIEW))
            } else {
                let scale = (WIDTH_VIEW_IMAGE) / (image?.size.width)!
                let height = image?.size.height
                image = image?.cropToSize(CGSize(width: WIDTH_VIEW_IMAGE , height: height! * scale))
                imageview.image = image
                imageview.frame = CGRect(x: 0, y: 0, width: Int(WIDTH_VIEW_IMAGE ), height: Int((image?.size.height)!))

            }
            
           // imageview.contentMode = .scaleAspectFill
            //itemView.image = UIImage(named: "page.png")
            
            
        }
        
        return imageview
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        self.imageControll.currentPage = carousel.currentItemIndex
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            
            if let view = carousel.currentItemView {
                
                if isPotraitView(image: view) {
                    if listImageAccident.count == 3 {
                        return value * 1.7
                    } else if listImageAccident.count == 4{
                        return value * 1.55
                    } else {
                        return value * 1.85
                    }
                } else {
                    if listImageAccident.count == 3 {
                        return value * 1.50
                    } else if listImageAccident.count == 4{
                        return value * 1.40
                    } else {
                        return value * 1.68
                    }
                }

            }
            
        }
        return value
    }
    
    func isPotraitView(image: UIView)->Bool {
        let width = Int(image.frame.width)
        let height = Int(image.frame.height)
        if width > height {
            return false
        }
        return true
    }
    
    func isPotraitImage(image: UIImage)->Bool {
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        if width > height {
            return false
        }
        return true
    }
    
    // MARK: - Request Address 
    func getLatLonFromAdress(address: String) {
        let str =  "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&sensor=false"
        let usrString: String = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        guard let url = URL(string:usrString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            // 3
            do {
                if data != nil{
                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
//                    print(dic)
                    //                    let lat = ((((dic["results"] as AnyObject).value(forKey: "geometry") as AnyObject).value(forKey: "location") as AnyObject).value(forKey: "lat") as AnyObject).object(0) as! Double
                    //                    let lon = ((((dic["results"] as AnyObject).value(forKey: "geometry") as AnyObject).value(forKey: "location") as AnyObject).value(forKey: "lng") as AnyObject).object(0) as! Double
                    // 4
                    // self.delegate.locateWithLongitude(lon, andLatitude: lat, andTitle: self.searchResults[indexPath.row])
                    if let results = dic["results"] as? NSArray {
                        if results.count>0 {
                            let result = results[0] as? [String: AnyObject]
                            if let geometry = result?["geometry"] as? [String: AnyObject] {
                                let location = geometry["location"] as? [String: AnyObject]
                                let lat = location?["lat"]
                                let lng = location?["lng"]
                                self.locateWithLongitude(lng! as! Double, andLatitude: lat as! Double, andTitle: self.currentPosTextField.text!)
                            }
                        }
                    }
                }
                
            }catch {
//                print("Error")
            }
        })
        // 5
        task.resume()

    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, lon)
             //self.marker = GMSMarker(position: position)
            self.marker.position = position
            let camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: MAP_ZOOM_DEFAULT)
            self.mapView.camera = camera
            
            self.marker.title = self.currentPosTextField.text
           // self.marker.map = self.mapView
        }
    }

    
    // MARK: - Action button view
    @IBAction func tapedMenu(_ sender: Any) {
        carDropDrow.show()
    }
   
    
    @IBAction func tappedMenuButton(_ sender: Any) {
        onLeftMenu(sender: sender)
    }
    
    func tapedCall(_sender: Any) {
            }
    @IBAction func tapedCallButton(_ sender: Any) {
        // Log event call action to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.CALL_AGENT_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.CALL_AGENT_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.CALL_AGENT_KEY as NSObject
            ])

        guard let number = URL(string: "telprompt://" + contactSupportNumber) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
        sendInfoDevice()

    }
    
    @IBAction func tapedCamera(_ sender: Any) {
        // Log event Capture picture action to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.CAPTURE_PICTURE_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.CAPTURE_PICTURE_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.CAPTURE_PICTURE_KEY as NSObject
            ])

        guard listImageAccident.count < MAX_IMAGE_ACCIDENT else {
            let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message: maxImageMessage, textAction: alertTitleA)
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.openCamera()
    }
    

    @IBAction func tappedViewImage(_ sender: Any) {
        guard listImageAccident.count > 0 else {
            return
        }
        self.imageiCarouselView.isHidden = false
        deleteView.isHidden = false
        closeview.isHidden = false
        self.view.bringSubview(toFront: self.closeview)
    }
    
    @IBAction func tapedClose(_ sender: Any) {
        self.imageiCarouselView.isHidden = true
        deleteView.isHidden = true
        closeview.isHidden = true
    }


    @IBAction func tapedDeleteImage(_ sender: Any) {
        
        let alert = UIAlertController.init(title: confirm, message: cancelServiceMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: alertTitleA, style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            self.listImageAccident.remove(at: self.imageControll.currentPage)
            self.imageiCarouselView.reloadData()
            self.saveImage()
            self.countView.text = String(self.listImageAccident.count)
            if (self.listImageAccident.count == 0) {
                self.imageiCarouselView.isHidden = true
                self.deleteView.isHidden = true
                self.closeview.isHidden = true
                self.hiddenView()
            }
        }))
        alert.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func tappedCallSupport(_ sender: Any) {
        // Log event call action to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.CALL_AGENT_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.CALL_AGENT_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.CALL_AGENT_KEY as NSObject
            ])

        guard let number = URL(string: "telprompt://" + contactSupportNumber) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
    }

    @IBAction func tapedNote(_ sender: Any) {
        carNoTextField.resignFirstResponder()
        currentPosTextField.resignFirstResponder()
       noteBackground.isHidden = false
        noteView.isHidden = false
    }
    @IBAction func tapedDoneNote(_ sender: Any) {
        noteText.resignFirstResponder()
        carNoTextField.resignFirstResponder()
        currentPosTextField.resignFirstResponder()
        noteBackground.isHidden = true
        noteView.isHidden = true
        if noteText.text.characters.count > 0 {
            scoringNoteView.isHidden = false
        } else {
            scoringNoteView.isHidden = true
        }
    }
    
    @IBAction func tapedCash(_ sender: Any) {
    }
    @IBAction func tapedDone(_ sender: Any) {
        // Log event request assistance action to server
        FIRAnalytics.logEvent(withName: GoogleAnalyticsEventKey.REQUEST_ASSISTANCE_EVENT, parameters: [
            GoogleAnalyticsParameterKey.PARAMETER_EVENT: GoogleAnalyticsEventKey.REQUEST_ASSISTANCE_EVENT as NSObject,
            GoogleAnalyticsParameterKey.PARAMETER_KEY: GoogleAnalyticsEventKey.REQUEST_ASSISTANCE_KEY as NSObject
            ])

//        if carNoTextField.text?.characters.count == 0 {
//            showError(message: "Please fill a car Reg.No!")
//            return
//        }
//        if caseTypeChoosed == nil {
//            showError(message: "Please choose a case under bottom of the screen!")
//            return
//        }
//        
//        if currentPosTextField.text?.characters.count == 0 {
//            showError(message: "Please type your current location!")
//            return
//        }
//    
////        let storyboard = UIStoryboard(name: "Main", bundle: nil)
////        let requestDetail = storyboard.instantiateViewController(withIdentifier: "requestDetail") as! RequestDetailViewController
//        let requestDetail = getControllerID(id: .RequestDetail) as!  RequestDetailViewController  //self.mainStoryboard?.instantiateViewController(withIdentifier: "editInfoController") as! EditInfoViewController
//        let user = UserHelper()
//        
//        userDefault.set(currentPosTextField.text, forKey: Key.LocalKey.currentLogcation)
//        userDefault.set(NEW_REQUEST, forKey: Key.LocalKey.userCancel)
//        user.setCarNumber(carNumber: carNoTextField.text!)
//        requestDetail.carNoText = carNoTextField.text
//        requestDetail.currentLocationText = currentPosTextField.text
//        requestDetail.caseTypeText = caseTypeChoosed?.caseType.getName()
//        requestDetail.caseTypeId = caseTypeChoosed?.caseType.getId()
//        requestDetail.caseTypeImageView = caseTypeChoosed?.getImage()
//        self.navigationController?.pushViewController(requestDetail, animated: true)
////        let storyboard = UIStoryboard(name: "Main", bundle: nil)
////        let waiting = storyboard.instantiateViewController(withIdentifier: "waiting") as! WaitingViewController
////        self.present(waiting, animated: true, completion: nil)
        sendRequest()
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
//        print("Error: \(error)")
    }
    
    // MARK: - Fetch data from server
    func getListCaseType() {
        let url = ServerConfigure.url + ServerConfigure.Path.getListCaseType
       // loading.showOverlay(view: view)
        RequestService.shareInstance.Get(keyForDictTask: ServerConfigure.Path.getListCaseType, url,checkAuthen: true, successResponse:{(response) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                if let dictionResult = response.dictData {
                    let success = dictionResult["code"] as! Int
                    if success == successCode {
                        self.listCaseType = RequestHelper.shareInstance.extractCaseTypeJson(dictionResult)
                        if self.listCaseType.count == 0 {
                            self.showReload(message: notFoundCaseType)
                            return
                        }
                        self.listButtonCase = self.createCaseTypeView()
                        self.setupButtonScrollView(buttons: self.listButtonCase)
                    } else {
                        OperationQueue.main.addOperation {
                            //self.showError(message: dictionResult["message"] as! String)\
                            self.showReload(message: notFoundCaseType)
                        }
                    }
                    
                    
                }

            }
        } , failureResponse: {(error) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                self.showError()
            }
        })
    }
    
    func getListCar() {
        let url = ServerConfigure.url + ServerConfigure.Path.getListCar
        loading.showOverlay(view: view)
        RequestService.shareInstance.Get(keyForDictTask: ServerConfigure.Path.getListCar, url, checkAuthen: true, successResponse: {(response)in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                if let dictionResult = response.dictData {
                    let success = dictionResult["code"] as! Int
                    if success == successCode {
                        let listInsurance = RequestHelper.shareInstance.extractInsuranceJson(dictionResult)
                        self.listCar = listInsurance
                        guard self.listCar.count > 0 else {
                            self.dropButton.isHidden = true
                            return
                        }
                        for car in self.listCar {
                            self.listData.append(car.getRegNo()!)
                        }
                        self.carDropDrow.dataSource = self.listData
                        if self.insurance != nil {
                            self.carNoTextField.text = self.insurance?.getRegNo()
                        } else {
                            self.carNoTextField.text = self.listData[0]
                        }
                        
                    } else {
                        OperationQueue.main.addOperation {
                            self.showError(message: dictionResult["message"] as! String)
                        }
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
    
    //MARK: - Common method
    func getListImage() {
       let numberImage = userDefault.integer(forKey: Key.LocalKey.numberImage)
        guard numberImage > 0 else {
            hiddenView()
            return
        }
        for i in 0..<numberImage {
            if let data = getImageData(index: i){
                listImageAccident.append(data as Data)
            }
        }
        hiddenView()
        imageiCarouselView.reloadData()
    }
    func clearAllImage() {
        for i in 0..<listImageAccident.count {
            userDefault.removeObject(forKey: Key.LocalKey.image + String(i))
        }
        userDefault.set(-1, forKey: Key.LocalKey.numberImage)
    }
    
    func clearImageAtIndext(index: Int) {
        userDefault.removeObject(forKey: Key.LocalKey.image + String(index))
        userDefault.set(listImageAccident.count, forKey: Key.LocalKey.numberImage)
    }
    
    func saveImage() {
        clearAllImage()
        for i in 0..<listImageAccident.count {
            let data = listImageAccident[i]
            UserDefaults.standard.set(data, forKey: Key.LocalKey.image + String(i))
            UserDefaults.standard.synchronize()
        }
        userDefault.set(listImageAccident.count, forKey: Key.LocalKey.numberImage)
    }
    
    func getImageData(index: Int)-> NSData? {
        if let imgData = userDefault.object(forKey: Key.LocalKey.image + String(index)) as? NSData {
            return imgData
        } else {
            return nil
        }
    }
    
    func hiddenView() {
        if listImageAccident.count <= 0 {
            countView.isHidden = true
            imageButton.setImage(UIImage(named: "view_img_inactive"), for: .normal)
        } else {
            countView.text = String(listImageAccident.count)
             countView.isHidden = false
            imageButton.setImage(UIImage(named: "icon_img_collection"), for: .normal)
        }
        
        
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
    
    func sendRequest() {
        if carNoTextField.text?.characters.count == 0 {
            showError(message: "Please fill a car Reg.No!")
            return
        }
        if caseTypeChoosed == nil {
            showError(message: "Please choose a case under bottom of the screen!")
            return
        }
        
        if currentPosTextField.text?.characters.count == 0 {
            showError(message: "Please type your current location!")
            return
        }

        let url = ServerConfigure.url + ServerConfigure.Path.requestAssistance
        let body = getBody()
        loading.showOverlay(view: view)
        RequestService.shareInstance.RequestAssistance(keyForDictTask: ServerConfigure.Path.requestAssistance, url, param: body, imageData: listImageAccident, isCheckOuthen: true, successRespose: {(responseData) in
            
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
            }
            if let dictResult = responseData.dictData {
                let success = dictResult["code"] as! Int
                if success == successCode {
                    OperationQueue.main.addOperation {
                        let waiting = getControllerID(id: .Waiting) as! WaitingViewController
                        waiting.caseId = dictResult[Key.RequestAssitance.id] as? Int
                        self.navigationController?.pushViewController(waiting, animated: true)
                        self.clearAllImage()
                        self.userDefault.set(self.currentPosTextField.text, forKey: Key.LocalKey.currentLogcation)
                        self.userDefault.set(NEW_REQUEST, forKey: Key.LocalKey.userCancel)
                        let user = UserHelper()
                        user.setCarNumber(carNumber: self.carNoTextField.text!)
                    }
                    
                } else {
                    OperationQueue.main.addOperation {
                        self.showError(message: dictResult["message"] as! String)
                    }
                    
                }
            } else {
                OperationQueue.main.addOperation {
                    self.showError(message: self.failMessage)
                }
            }
        }, failureResponse: { (error) in
            OperationQueue.main.addOperation {
                self.loading.hideOverlayView()
                self.showError(message: self.failMessage)
            }
        })

    }
    
    func getBody()-> Dictionary<String, String> {
        let caseTypeId:Int = (caseTypeChoosed?.caseType.getId()!)!
        let body = [Key.RequestAssitance.carplateNumber: carNoTextField.text!, Key.RequestAssitance.currentLocation: currentPosTextField.text!, Key.RequestAssitance.caseTypeId: String(caseTypeId),
                   Key.RequestAssitance.note: noteText.text != nil ? noteText.text! : "", Key.RequestAssitance.paymentType: String(CASHID), Key.RequestAssitance.codeCallGroup: Key.RequestAssitance.codeCallGroupEtiqa] 
        
        return body
    }

    
    func showError(message: String) {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message:message, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showReload(message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
            alert.addAction(UIAlertAction(title: emergencyCall, style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
            guard let number = URL(string: "telprompt://" + emegencyNumber) else { return }
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
            
        })

        alert.addAction(UIAlertAction(title: reload, style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            self.getListCaseType()
        }))
        self.present(alert, animated: true, completion: nil)
        
    }


    func showError() {
        let alert = UtilHelper.shareInstance.getAlert(title: errorTitle, message: self.failMessage, textAction: alertTitleA)
        self.present(alert, animated: true, completion: nil)
    }
    
    

    
}
