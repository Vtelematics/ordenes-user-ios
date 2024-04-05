//
//  MapVc.swift
//  Talabat clone
//
//  Created by Adyas infotech on 14/07/22.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import Alamofire

class MapVc: UIViewController{

    @IBOutlet weak var myViewSearchBox: UIView!
    @IBOutlet weak var myViewSearchBox2: UIView!
    @IBOutlet weak var myTxtAddress: UITextField!
    @IBOutlet weak var myViewMapContainer: UIView!
    @IBOutlet weak var myViewAddressList: UIView!
    @IBOutlet weak var myTblAddress: UITableView!
    @IBOutlet weak var myViewCurrentLocation: UIView!
    @IBOutlet weak var myMapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    var recentSearchesArr = NSMutableArray()
    var permissionDenied = false
    var pageType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func setupUI(){
        self.myTxtAddress.textAlignment = isRTLenabled == true ? .right : .left
        self.myViewAddressList.isHidden = true
        self.myTblAddress.dataSource = self
        self.myTblAddress.delegate = self
        self.myViewSearchBox.layer.cornerRadius = 8
        self.myViewSearchBox.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myViewSearchBox.layer.borderWidth = 0.8
        self.myViewSearchBox2.layer.cornerRadius = 8
        self.myViewSearchBox2.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myViewSearchBox2.layer.borderWidth = 0.8
        self.myViewCurrentLocation.dropShadow(cornerRadius: 4, opacity: 0.2, radius: 8)
        myMapView.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if let location = UserDefaults.standard.value(forKey: UD_SELECTED_LAT_LONG), "\(location)" != ""{
            let array = (location as AnyObject).components(separatedBy: ",")
            let lat = array[0]
            let long = array[1]
            if lat != "" && long != ""
            {
                let camera = GMSCameraPosition.camera(withLatitude: Double(lat)!, longitude: Double(long)!, zoom: 17.0)
                self.myMapView?.camera = camera
                self.myMapView?.animate(to: camera)
            }else{
                locationManager.startUpdatingLocation()
            }
        }else{
            locationManager.startUpdatingLocation()
        }
        
        recentSearchesArr = []
        if let arr = UserDefaults.standard.value(forKey: UD_RECENT_SEARCHES), (arr as AnyObject).count != 0
        {
            do {
                if let recentArr = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(arr as! Data) as? NSMutableArray {
                    recentSearchesArr = recentArr
                }
            } catch {
                print("Couldn't read file.")
            }
        }
    }
    
    //For delivery availability check
    func callGetHomeApi() {
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        print(aDictParameters)
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_MODULES, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { [self] (response) in
            HELPER.hideLoadingAnimation()
           do {
               print(response)
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    if aDictInfo["success"] != nil{
                        UserDefaults.standard.set("\(self.myTxtAddress.text!)", forKey: UD_SELECTED_ADDRESS)
                        UserDefaults.standard.set("\(globalLatitude),\(globalLongitude)", forKey: UD_SELECTED_LAT_LONG)
                        if self.pageType == "home" || self.pageType == "all_restaurant"{
                            self.dismiss(animated: true)
                        }else{
                            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
                            let navi = UINavigationController.init(rootViewController: aViewController)
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                            appDelegate.window?.rootViewController = navi
                            appDelegate.window?.makeKeyAndVisible()
                        }
                    }else{
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Delivery not available for this location", comment: ""))
                    }
                    
                }else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Delivery not available for this location", comment: ""))
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Delivery not available for this location", comment: ""))
        })
    }
    
    func addressFromLatLong(lat: Double, long: Double){
        let aDictParameters = [String : String]()
        let aStrApiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&key=\(apiKey)"
        let headers:HTTPHeaders? = ["Content-Type": "application/json", "Accept" : "application/json"]
        AF.request(aStrApiUrl, method: .get, parameters: aDictParameters, encoding: Alamofire.URLEncoding.default, headers: headers).responseJSON {
            (dataResponse) in
            var jsonResponse  = [String :Any]()
            
            switch dataResponse.result {
            case .success(let json):
                if dataResponse.response!.statusCode == 200 {
                    
                    if let encryptedData:NSData = dataResponse.data as NSData? {
                        
                        do {
                            jsonResponse = try JSONSerialization.jsonObject(with: encryptedData as Data, options: .mutableContainers) as! [String : Any]
                            if jsonResponse["status"] as! String == "OK"
                            {
                                let aDictInfo = jsonResponse["results"] as! [[String : Any]]
                                print(aDictInfo)
                                self.myTxtAddress.text = aDictInfo[0]["formatted_address"] as? String
                            }
                            else
                            {
                                print(jsonResponse["status"])
                            }
                        }
                        catch let error
                        {
                            print(error)
                        }
                    }
                    else {
                        HELPER.hideLoadingAnimation()
                    }
                } else {
                    let jsonResponseMessage = json as? [String:Any]
                    HELPER.hideLoadingAnimation()
                    let data = jsonResponseMessage?["error"] as? [String: Any]
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: data!["message"] as! String)
                }
            case .failure(let error):
                print(error)
                HELPER.hideLoadingAnimation()
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error.errorDescription ?? "Something went wrong!")
            }
        }
    }
    
    //MARK: Button Action
    @IBAction func clickBack(_ sender : UIButton)
    {
        if let location = UserDefaults.standard.value(forKey: UD_SELECTED_LAT_LONG), "\(location)" != ""
        {
            let array = (location as AnyObject).components(separatedBy: ",")
            let lat = array[0]
            let long = array[1]
            if lat != "" && long != ""
            {
                globalLatitude = lat
                globalLongitude = long
                self.dismiss(animated: true)
                //self.navigationController?.popViewController(animated: true)
            }else{
                
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please select Location", comment: ""))
            }
        }else{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please select Location", comment: ""))
        }
    }
    
    @IBAction func clickSearchAddress(_ sender : UIButton)
    {
        self.myViewAddressList.isHidden = false
    }
    
    @IBAction func clickBackFromAddress(_ sender : UIButton)
    {
        self.myViewAddressList.isHidden = true
     }
    
    @IBAction func clickMyLocation(_ sender: Any)
    {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func clickConfirmLocation(_ sender: Any)
    {
        if myTxtAddress.text == ""
        {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please select Location", comment: ""))
        }
        else
        {
            callGetHomeApi()
        }
    }
    
    @IBAction func clickAutoSearch(_ sender: Any)
    {
        let autocompleteController = GMSAutocompleteViewController()
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                autocompleteController.primaryTextColor = UIColor.white
                autocompleteController.secondaryTextColor = UIColor.lightGray
                autocompleteController.tableCellSeparatorColor = UIColor.lightGray
                autocompleteController.tableCellBackgroundColor = UIColor.darkGray
            } else {
                autocompleteController.primaryTextColor = UIColor.black
                autocompleteController.secondaryTextColor = UIColor.lightGray
                autocompleteController.tableCellSeparatorColor = UIColor.lightGray
                autocompleteController.tableCellBackgroundColor = UIColor.white
            }
        }
        autocompleteController.delegate = self
        UISearchBar.appearance().barStyle = UIBarStyle.default
        autocompleteController.modalPresentationStyle = .fullScreen
        present(autocompleteController, animated: true, completion: nil)
    }
    
}

extension MapVc: GMSAutocompleteViewControllerDelegate{
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

        print(place)
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        globalLatitude = "\(lat)"
        globalLongitude = "\(long)"
        myMapView.delegate = nil
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17.0)
        self.myMapView?.camera = camera
        self.myMapView?.animate(to: camera)
        let primaryAddress = place.name!
        let secondarayAddress = place.formattedAddress!
        self.myTxtAddress.text = "\(String(describing: place.formattedAddress!))"
        
        self.myViewAddressList.isHidden = true
        
        UINavigationBar.appearance().barTintColor = ConfigTheme.themeColor
        UINavigationBar.appearance().tintColor = ConfigTheme.themeColor
        dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2)
        {
            self.myMapView.delegate = self
        }
        
        if let arr = UserDefaults.standard.value(forKey: UD_RECENT_SEARCHES), (arr as AnyObject).count != 0
        {
            var isAlreadyHave = false
            for i in 0..<recentSearchesArr.count
            {
                let title = "\((recentSearchesArr.object(at: i) as AnyObject).value(forKey: "title")!)"
                
                if title == primaryAddress
                {
                    isAlreadyHave = true
                }
            }
            let tempD = NSMutableDictionary()
            tempD.setObject(primaryAddress, forKey: "title" as NSCopying)
            tempD.setObject(secondarayAddress, forKey: "subtitle" as NSCopying)
            tempD.setObject(globalLatitude, forKey: "latitude" as NSCopying)
            tempD.setObject(globalLongitude, forKey: "longitude" as NSCopying)
            if !isAlreadyHave && recentSearchesArr.count > 10{
                recentSearchesArr.removeObject(at: 0)
                recentSearchesArr.add(tempD)
            }else{
                recentSearchesArr.add(tempD)
            }
        }
        else
        {
            let tempD = NSMutableDictionary()
            tempD.setObject(primaryAddress, forKey: "title" as NSCopying)
            tempD.setObject(secondarayAddress, forKey: "subtitle" as NSCopying)
            tempD.setObject(globalLatitude, forKey: "latitude" as NSCopying)
            tempD.setObject(globalLongitude, forKey: "longitude" as NSCopying)
            recentSearchesArr.add(tempD)
        }
        print(recentSearchesArr)
        self.myTblAddress.reloadData()
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: recentSearchesArr as NSArray, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: UD_RECENT_SEARCHES)
        } catch {
            print("Couldn't write file")
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
        UINavigationBar.appearance().barTintColor = ConfigTheme.themeColor
        UINavigationBar.appearance().tintColor = ConfigTheme.themeColor
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        UINavigationBar.appearance().barTintColor = ConfigTheme.themeColor
        UINavigationBar.appearance().tintColor = ConfigTheme.themeColor
        dismiss(animated: true, completion: nil)
    }
}
extension MapVc: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)
    {
        let camera = GMSCameraPosition.camera(withLatitude: (coordinate.latitude), longitude: (coordinate.longitude), zoom: 17.0)
        self.myMapView?.camera = camera
        self.myMapView?.animate(to: camera)
        globalLatitude = "\(coordinate.latitude)"
        globalLongitude = "\(coordinate.longitude)"
        addressFromLatLong(lat: coordinate.latitude, long: coordinate.longitude)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition)
    {
        self.myMapView.settings.consumesGesturesInView = false
                    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panHandler(_:)))
                    self.myMapView.addGestureRecognizer(panGesture)
        
    }
    
    @objc private func panHandler(_ pan : UIPanGestureRecognizer){
            if pan.state == .ended{
                let mapSize = self.myMapView.frame.size
                let point = CGPoint(x: mapSize.width/2, y: mapSize.height/2)
                let newCoordinate = self.myMapView.projection.coordinate(for: point)
                print(newCoordinate)
                globalLatitude = "\(newCoordinate.latitude)"
                globalLongitude = "\(newCoordinate.longitude)"
                addressFromLatLong(lat: newCoordinate.latitude, long: newCoordinate.longitude)
        }
    }
    
}

extension MapVc: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if locations.last != nil
        {
            let location = locations.last
            
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
            
            let lat = location?.coordinate.latitude as! Double
            let long = location?.coordinate.longitude as! Double
            globalLatitude = "\(String(describing: lat))"
            globalLongitude = "\(String(describing: long))"
            self.myMapView?.camera = camera
            self.myMapView?.animate(to: camera)
            self.addressFromLatLong(lat: (location?.coordinate.latitude)!, long: (location?.coordinate.longitude)!)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            print("Denied")
            permissionDenied = true
            showPermissionAlert()
        } else if (status == CLAuthorizationStatus.authorizedAlways) || (status == CLAuthorizationStatus.authorizedWhenInUse) {
            print("Access")
            permissionDenied = false
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func showPermissionAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Location Permission Required", comment: ""), message: NSLocalizedString("Please enable location permissions in settings.", comment: ""), preferredStyle: UIAlertController.Style.alert)

        let okAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: {(cAlertAction) in
            //Redirect to Settings app
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel)
        alertController.addAction(cancelAction)

        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

extension MapVc: UITableViewDelegate, UITableViewDataSource{
    // MARK: TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if recentSearchesArr.count != 0
        {
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0{
            return 1
        }else{
            return recentSearchesArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0{
            return nil
        }else{
            let name = NSLocalizedString("Recently search addresses", comment: "")
            return name
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section == 0{
            return 0
        }else{
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0{
            let cell : mapTableViewCell = myTblAddress.dequeueReusableCell(withIdentifier:  "currentLocationCell") as! mapTableViewCell
            cell.selectionStyle = .none
            cell.imgLocation.image = cell.imgLocation.image!.withRenderingMode(.alwaysTemplate)
            cell.imgLocation.tintColor = ConfigTheme.themeColor
            return cell
        }else{
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "\((recentSearchesArr.object(at: indexPath.row) as AnyObject).value(forKey: "title")!)"
            cell.detailTextLabel?.text = "\((recentSearchesArr.object(at: indexPath.row) as AnyObject).value(forKey: "subtitle")!)"
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0{
            if permissionDenied == true {
                showPermissionAlert()
            }else {
                self.myViewAddressList.isHidden = true
                locationManager.startUpdatingLocation()
            }
        }else{
            self.myTxtAddress.text = "\((recentSearchesArr.object(at: indexPath.row) as AnyObject).value(forKey: "title")!)"
            if let lat = (recentSearchesArr.object(at: indexPath.row) as AnyObject).value(forKey: "latitude")
            {
                if "\(lat)" != ""
                {
                    globalLatitude = "\(lat)"
                }
                print(lat)
            }
            
            if let long = (recentSearchesArr.object(at: indexPath.row) as AnyObject).value(forKey: "longitude")
            {
                if "\(long)" != ""
                {
                    globalLongitude = "\(long)"
                }
                print(long)
            }
            if globalLatitude != "" && globalLongitude != ""
            {
                
                callGetHomeApi()
            }
        }
    }
}
