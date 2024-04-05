//
//  AddressVc.swift
//  Talabat clone
//
//  Created by Adyas infotech on 26/07/22.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import DropDown

class AddressVc: UIViewController {
    
    @IBOutlet var myTblAddress: UITableView!
    @IBOutlet var myViewNaigation: UIView!
    @IBOutlet var myViewAddressContainer: UIView!
    @IBOutlet var myTxtFname: UITextField!
    @IBOutlet var myTxtLname: UITextField!
    @IBOutlet var myLblCountryCode: UILabel!
    @IBOutlet var myTxtEmail: UITextField!
    @IBOutlet var myTxtMobile: UITextField!
    @IBOutlet var myTxtLandline: UITextField!
    @IBOutlet var myTxtArea: UITextField!
    @IBOutlet var myTxtAddressType: UITextField!
    @IBOutlet var myTxtAddress: UITextField!
    
    @IBOutlet var myLblAddressTypeLine: UILabel!
    @IBOutlet var myLblBlock: UILabel!
    @IBOutlet var myLblBlockLine: UILabel!
    @IBOutlet var myTxtBlock: UITextField!
    
    @IBOutlet var myLblStreet: UILabel!
    @IBOutlet var myLblStreetLine: UILabel!
    @IBOutlet var myTxtStreet: UITextField!
    
    @IBOutlet var myLblBuilding: UILabel!
    @IBOutlet var myLblBuildingLine: UILabel!
    @IBOutlet var myTxtBuilding: UITextField!
    @IBOutlet var myLblFloor: UILabel!
    @IBOutlet var myLblFloorLine: UILabel!
    @IBOutlet var myTxtFloor: UITextField!
    @IBOutlet var myLblApartment: UILabel!
    @IBOutlet var myLblApartmentLine: UILabel!
    @IBOutlet var myTxtApartment: UITextField!
    @IBOutlet var myLblAdditionalDirections: UILabel!
    @IBOutlet var myLblAdditionalDirectionsLine: UILabel!
    @IBOutlet var myTxtAdditionalDirections: UITextField!
    @IBOutlet var myBtnSaveAddress: UIButton!
    @IBOutlet var myMapVwNonEdited: GMSMapView!
    @IBOutlet weak var myMapVwEdited: GMSMapView!
    @IBOutlet var myViewChangeLocation: UIView!
    @IBOutlet var myScrollView: UIScrollView!
    @IBOutlet var myLblTitle: UILabel!
    @IBOutlet var myPickerView: UIPickerView!
    @IBOutlet var myViewPickervw: UIView!
    @IBOutlet var myImgViewArea: UIImageView!
    @IBOutlet var myImgViewAddressType: UIImageView!
    
    //MapView
    @IBOutlet weak var myViewSearchBox: UIView!
    @IBOutlet weak var myLblAddress: UILabel!
    @IBOutlet weak var myLblSearchAddress: UILabel!
    @IBOutlet weak var myLblDeliveryTo: UILabel!
    @IBOutlet weak var myViewMapContainer: UIView!
    @IBOutlet weak var myViewAddressContainerBottom: UIView!
    var zoneId = ""
    var addressId = ""
    var selectedCountryCodeIndex = 0
    var countryArray : [[String: Any]] = []
    var addressListModel = [Address]()
    var addressDict : Address?
    var selectedLat = ""
    var selectedLong = ""
    var latVal = ""
    var longVal = ""
    var locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var permissionDenied = false
    var selectedAddress = 0
    let dropDown = DropDown()
    var vendorId = ""
    var mapType = ""
    var availableZoneList : [[String:Any]] = []
    var addressComponents : [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: API Call
    func callGetCountryApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_COUNTRY, isAuthorize: false, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
            do {
                let aDictInfo = response as! [String : Any]
                self.countryArray = []
                if aDictInfo.count != 0 {
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }else{
                        self.countryArray = aDictInfo["countries"] as! [[String : Any]]
                    }
                    self.myPickerView.dataSource = self
                    self.myPickerView.delegate = self
                    self.myPickerView.reloadAllComponents()
                } else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_COUNTRY_CODE_MODULE_EMPTY)
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callGetAddressApi() {
        view.endEditing(true)
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_ADDRESS_LIST, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
            do {
                print(response)
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    let modelData = try! JSONDecoder().decode(AddressModel.self, from: jsonData)
                    print(modelData)
                    self.addressListModel = modelData.address ?? []
                    if self.addressListModel.count == 0{
                        self.newAddressSetup()
                    }else{
                        self.myViewNaigation.isHidden = true
                        self.myScrollView.isHidden = true
                    }
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }
                } else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_ADDRESS_MODULE_EMPTY)
                }
                self.myTblAddress.dataSource = self
                self.myTblAddress.delegate = self
                self.myTblAddress.reloadData()
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callPostDeliveryAddress(selectedIndex : Int) {
        view.endEditing(true)
        let lat = self.addressListModel[selectedIndex].latitude
        let long = self.addressListModel[selectedIndex].longitude
        let address_id = self.addressListModel[selectedIndex].addressID
        let zone = self.addressListModel[selectedIndex].zoneId
        
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LAT] = lat
        aDictParameters[K_PARAMS_LONG] = long
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ADDRESS_ID] = address_id
        aDictParameters[K_PARAMS_ZONE_ID] = zone
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_IS_DELIVERY, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
            do {
                var success:[String:Any]
                if let successval = response["success"] as? [String:Any] {
                    success = successval
                }else if let error = response["error"] as? [String:Any]{
                    success = error
                }else{
                    var defaultError = [String:Any]()
                    defaultError["message"] = NSLocalizedString("Something went wrong. Please try again", comment: "")
                    defaultError["status"] = "888"
                    success = defaultError
                }
                if success["status"] as! String == "200"
                {
                    self.dismiss(animated: true)
                }else{
                    HELPER.showAlertControllerWithTitleIn(aViewController: self, aStrTitle: "", aStrMessage: success["message"] as! String, okButtonTitle: NSLocalizedString("Okay", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { okAction in
                        self.myViewMapContainer.isHidden = false
                    } cancelActionBlock: { cancelAction in
                        self.dismiss(animated: true) {
                            self.myViewAddressContainer.isHidden = true
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
        
    func callPostDeleteAddress(addressId : String) {
        view.endEditing(true)
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_ADDRESS_ID] = addressId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_ADDRESS_DELETE, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
            do {
                var success:[String:Any]
                if let successval = response["success"] as? [String:Any] {
                    success = successval
                }else if let error = response["error"] as? [String:Any]{
                    success = error
                }else{
                    var defaultError = [String:Any]()
                    defaultError["message"] = NSLocalizedString("Something went wrong. Please try again", comment: "")
                    defaultError["status"] = "888"
                    success = defaultError
                }
                if success["status"] as! String == "200"
                {
                    self.callGetAddressApi()
                }else{
                    HELPER.showAlertControllerWithTitleIn(aViewController: self, aStrTitle: "", aStrMessage: success["message"] as! String, okButtonTitle: NSLocalizedString("Okay", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { okAction in
                        self.myViewMapContainer.isHidden = false
                    } cancelActionBlock: { cancelAction in
                        self.dismiss(animated: true) {
                            self.myViewAddressContainer.isHidden = true
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callGetAvailableZone() {
        view.endEditing(true)
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LAT] = self.selectedLat
        aDictParameters[K_PARAMS_LONG] = self.selectedLong
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        print(aDictParameters)
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_VENDOR_ZONE, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
            do {
                print(response)
                var success:[String:Any]
                if let successval = response["success"] as? [String:Any] {
                    success = successval
                }else if let error = response["error"] as? [String:Any]{
                    success = error
                }else{
                    var defaultError = [String:Any]()
                    defaultError["message"] = NSLocalizedString("Something went wrong. Please try again", comment: "")
                    defaultError["status"] = "888"
                    success = defaultError
                }
                
                print(self.selectedLat, self.selectedLong)
                if self.selectedLat != "" && self.selectedLong != ""{
                    let camera = GMSCameraPosition.camera(withLatitude: Double(self.selectedLat) ?? 0, longitude: Double(self.selectedLong) ?? 0, zoom: 17.0)
                    self.myMapVwNonEdited?.camera = camera
                    self.myMapVwNonEdited?.animate(to: camera)
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: Double(self.selectedLat) ?? 0, longitude: Double(self.selectedLong) ?? 0)
                    marker.map = self.myMapVwNonEdited
                }
                self.latVal = self.selectedLat
                self.longVal = self.selectedLong
                
                /*if success["status"] as! String == "200"
                {
                    self.availableZoneList = response["details"] as! [[String:Any]]
                    if self.availableZoneList.count != 0{
                        print(self.selectedLat, self.selectedLong)
                        if self.selectedLat != "" && self.selectedLong != ""{
                            let camera = GMSCameraPosition.camera(withLatitude: Double(self.selectedLat) ?? 0, longitude: Double(self.selectedLong) ?? 0, zoom: 17.0)
                            self.myMapVwNonEdited?.camera = camera
                            self.myMapVwNonEdited?.animate(to: camera)
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2D(latitude: Double(self.selectedLat) ?? 0, longitude: Double(self.selectedLong) ?? 0)
                            marker.map = self.myMapVwNonEdited
                        }
                        self.latVal = self.selectedLat
                        self.longVal = self.selectedLong
                        self.myTxtArea.text = self.availableZoneList[0]["zone_name"] as? String
                        self.zoneId = self.availableZoneList[0]["zone_id"] as! String
                    }else{
                        self.myTxtArea.text = ""
                        self.zoneId = ""
                    }
                }else{
                    HELPER.showAlertControllerWithTitleIn(aViewController: self, aStrTitle: "", aStrMessage: success["message"] as! String, okButtonTitle: NSLocalizedString("Okay", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { okAction in
                        self.mapType = "main"
                        if self.latVal != "" && self.longVal != ""{
                            self.selectedLat = self.latVal
                            self.selectedLong = self.longVal
                            let camera = GMSCameraPosition.camera(withLatitude: Double(self.selectedLat) ?? 0, longitude: Double(self.selectedLong) ?? 0, zoom: 17.0)
                            self.myMapVwEdited?.camera = camera
                            self.myMapVwEdited?.animate(to: camera)
                            self.myLblAddress.text = self.myTxtArea.text
                            self.myMapVwEdited.delegate = self
                        }else{
                            self.myMapVwEdited.delegate = self
                            self.locationManager.delegate = self
                            self.locationManager.requestAlwaysAuthorization()
                            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                            self.locationManager.startUpdatingLocation()
                        }
                        self.myViewMapContainer.isHidden = false
                    } cancelActionBlock: { cancelAction in
                        if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
                            self.myScrollView.isHidden = true
                            self.myViewNaigation.isHidden = true
                        }else{
                            self.dismiss(animated: true)
                        }
                    }
                }*/
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func postGuestAddress(){
        view.endEditing(true)
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_F_NAME] = self.myTxtFname.text
        aDictParameters[K_PARAMS_L_NAME] = self.myTxtLname.text
        aDictParameters[K_PARAMS_COUNTRY_CODE] = self.myLblCountryCode.text
        aDictParameters[K_PARAMS_EMAIL] = self.myTxtEmail.text
        aDictParameters[K_PARAMS_MOBILE] = self.myTxtMobile.text
        aDictParameters[K_PARAMS_LANDLINE] = self.myTxtLandline.text
        aDictParameters[K_PARAMS_AREA] = self.myTxtArea.text
        aDictParameters[K_PARAMS_ADDRESS] = self.myTxtAddress.text
        aDictParameters[K_PARAMS_VENDOR_ID] = self.vendorId
        aDictParameters[K_PARAMS_BLOCK] = self.myTxtBlock.text
        aDictParameters[K_PARAMS_STREET] = self.myTxtStreet.text
        aDictParameters[K_PARAMS_WAY] = ""
        aDictParameters[K_PARAMS_BUILDING_NAME] = self.myTxtBuilding.text
        aDictParameters[K_PARAMS_LAT] = self.latVal
        aDictParameters[K_PARAMS_LONG] = self.longVal
        aDictParameters[K_PARAMS_ZONE_ID] = self.zoneId
        aDictParameters[K_PARAMS_ADDITIONAL_DIRECTION] = self.myTxtAdditionalDirections.text
        aDictParameters[K_PARAMS_VENDOR_ID] = self.vendorId
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        if self.myTxtAddressType.text == NSLocalizedString("House", comment: ""){
            aDictParameters[K_PARAMS_DOOR_NO] = "0"
            aDictParameters[K_PARAMS_FLOOR] = "0"
            aDictParameters[K_PARAMS_ADDRESS_TYPE] = "1"
        }else{
            aDictParameters[K_PARAMS_DOOR_NO] = self.myTxtApartment.text
            aDictParameters[K_PARAMS_FLOOR] = self.myTxtFloor.text
            if self.myTxtAddressType.text == NSLocalizedString("Apartment", comment: ""){
                aDictParameters[K_PARAMS_ADDRESS_TYPE] = "2"
            }else{
                aDictParameters[K_PARAMS_ADDRESS_TYPE] = "3"
            }
        }
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_GUEST_ADDRESS, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                print(response)
                var success:[String:Any]
                if let successval = response["success"] as? [String:Any] {
                    success = successval
                }else if let error = response["error"] as? [String:Any]{
                    success = error
                }else{
                    var defaultError = [String:Any]()
                    defaultError["message"] = NSLocalizedString("Something went wrong. Please try again", comment: "")
                    defaultError["status"] = "888"
                    success = defaultError
                }
                if success["status"] as! String == "200"
                {
                    HELPER.hideLoadingAnimation()
                    self.dismiss(animated: true)
                }else{
                    HELPER.hideLoadingAnimation()
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callPostAddressApi() {
        view.endEditing(true)
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_F_NAME] = self.myTxtFname.text
        aDictParameters[K_PARAMS_L_NAME] = self.myTxtLname.text
        aDictParameters[K_PARAMS_COUNTRY_CODE] = self.myLblCountryCode.text
        aDictParameters[K_PARAMS_EMAIL] = self.myTxtEmail.text
        aDictParameters[K_PARAMS_MOBILE] = self.myTxtMobile.text
        aDictParameters[K_PARAMS_LANDLINE] = self.myTxtLandline.text
        aDictParameters[K_PARAMS_AREA] = self.myTxtArea.text
        aDictParameters[K_PARAMS_ADDRESS] = self.myTxtAddress.text
        aDictParameters[K_PARAMS_VENDOR_ID] = self.vendorId
        aDictParameters[K_PARAMS_BLOCK] = self.myTxtBlock.text
        aDictParameters[K_PARAMS_STREET] = self.myTxtStreet.text
        aDictParameters[K_PARAMS_WAY] = ""
        aDictParameters[K_PARAMS_BUILDING_NAME] = self.myTxtBuilding.text
        aDictParameters[K_PARAMS_LAT] = self.latVal
        aDictParameters[K_PARAMS_LONG] = self.longVal
        aDictParameters[K_PARAMS_ZONE_ID] = self.zoneId
        aDictParameters[K_PARAMS_ADDITIONAL_DIRECTION] = self.myTxtAdditionalDirections.text
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        if self.myTxtAddressType.text == NSLocalizedString("House", comment: ""){
            aDictParameters[K_PARAMS_DOOR_NO] = "0"
            aDictParameters[K_PARAMS_FLOOR] = "0"
            aDictParameters[K_PARAMS_ADDRESS_TYPE] = "1"
        }else{
            aDictParameters[K_PARAMS_DOOR_NO] = self.myTxtApartment.text
            aDictParameters[K_PARAMS_FLOOR] = self.myTxtFloor.text
            if self.myTxtAddressType.text == NSLocalizedString("Apartment", comment: ""){
                aDictParameters[K_PARAMS_ADDRESS_TYPE] = "2"
            }else{
                aDictParameters[K_PARAMS_ADDRESS_TYPE] = "3"
            }
        }
        var apiURL = ""
        if self.addressId != ""{
            aDictParameters[K_PARAMS_ADDRESS_ID] = self.addressId
            apiURL = CASE_GET_ADDRESS_EDIT
        }else{
            apiURL = CASE_GET_ADDRESS_ADD
        }
        HTTPMANAGER.callPostApiUsingEncryption(strCase: apiURL, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                print(response)
                var success:[String:Any]
                if let successval = response["success"] as? [String:Any] {
                    success = successval
                }else if let error = response["error"] as? [String:Any]{
                    success = error
                }else{
                    var defaultError = [String:Any]()
                    defaultError["message"] = NSLocalizedString("Something went wrong. Please try again", comment: "")
                    defaultError["status"] = "888"
                    success = defaultError
                }
                if success["status"] as! String == "200"
                {
                    self.myScrollView.isHidden = true
                    self.myViewNaigation.isHidden = true
                    self.callGetAddressApi()
                }else{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
                }
                HELPER.hideLoadingAnimation()
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
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
                                self.addressComponents = aDictInfo[0]["address_components"] as! [[String:Any]]
                                
                                if self.mapType == "main" {
                                    self.myLblAddress.text = aDictInfo[0]["formatted_address"] as? String
                                }else {
                                    self.myTxtAddress.text = aDictInfo[0]["formatted_address"] as? String
                                    self.myTxtStreet.text = self.addressComponents[0]["long_name"] as? String
                                }
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
                    print(data)
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: data!["message"] as! String)
                }
            case .failure(let error):
                print(error)
                HELPER.hideLoadingAnimation()
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error.errorDescription ?? "Something went wrong!")
            }
        }
    }
    
    func editAddressType(selectedType: Int){
        if selectedType == 0{
            self.myLblBuilding.text = NSLocalizedString("House", comment: "")
            self.myViewAddressContainerBottom.frame.origin.y = self.myLblBuildingLine.frame.origin.y + 23
            self.myLblFloor.isHidden = true
            self.myLblFloorLine.isHidden = true
            self.myTxtFloor.isHidden = true
            self.myLblApartment.isHidden = true
            self.myLblApartmentLine.isHidden = true
            self.myTxtApartment.isHidden = true
        }else{
            if selectedType == 1{
                self.myLblApartment.text = NSLocalizedString("Apartment no.", comment: "")
            }else{
                self.myLblApartment.text = NSLocalizedString("Office", comment: "")
            }
            self.myLblBuilding.text = NSLocalizedString("Building", comment: "")
            self.myViewAddressContainerBottom.frame.origin.y = self.myLblApartmentLine.frame.origin.y + 23
            self.myLblFloor.isHidden = false
            self.myLblFloorLine.isHidden = false
            self.myTxtFloor.isHidden = false
            self.myLblApartment.isHidden = false
            self.myLblApartmentLine.isHidden = false
            self.myTxtApartment.isHidden = false
        }
        self.myViewAddressContainer.frame.size.height = self.myViewAddressContainerBottom.frame.origin.y + self.myViewAddressContainerBottom.frame.size.height + 10
        self.myViewAddressContainer.translatesAutoresizingMaskIntoConstraints = true
        self.myScrollView.contentSize.height = self.myViewAddressContainer.frame.size.height
        self.myScrollView.frame.size.width = view.frame.size.width
        self.myScrollView.frame.origin.x = 0
    }
    
    func setupUI(){
        self.myTxtFname.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtLname.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtEmail.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtMobile.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtLandline.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtArea.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtAddress.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtAddressType.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtBlock.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtStreet.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtBuilding.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtFloor.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtApartment.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtAdditionalDirections.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblAddress.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblDeliveryTo.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblSearchAddress.textAlignment = isRTLenabled == true ? .right : .left
        self.myViewNaigation.isHidden = true
        self.myScrollView.isHidden = true
        self.myViewMapContainer.isHidden = true
        self.myViewSearchBox.layer.cornerRadius = 8
        self.myViewSearchBox.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myViewSearchBox.layer.borderWidth = 0.8
        self.myScrollView.addSubview(myViewAddressContainer)
        self.myScrollView.contentSize.height = self.myViewAddressContainer.frame.size.height
        self.myScrollView.frame.size.width = view.frame.size.width
        self.myScrollView.frame.origin.x = 0
        self.myViewAddressContainer.frame.origin.y = 0
        self.myViewAddressContainer.frame.size.width = view.frame.size.width
        self.myViewAddressContainer.translatesAutoresizingMaskIntoConstraints = true
        self.myTblAddress.register(UINib(nibName: "AddressTblCell", bundle: nil), forCellReuseIdentifier: "addressCell")
        self.myViewChangeLocation.layer.borderWidth = 1
        self.myViewChangeLocation.layer.cornerRadius = 8
        self.myViewChangeLocation.layer.borderColor = ConfigTheme.themeColor.cgColor
        if isRTLenabled{
            myImgViewArea.transform = myImgViewArea.transform.rotated(by: .pi / 2)
            myImgViewAddressType.transform = myImgViewAddressType.transform.rotated(by: .pi / 2)
        }else{
            myImgViewArea.transform = myImgViewArea.transform.rotated(by: .pi * 1.5)
            myImgViewAddressType.transform = myImgViewAddressType.transform.rotated(by: .pi * 1.5)
        }
        self.myTblAddress.allowsSelection = vendorId == "" ? false : true
        if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
            callGetAddressApi()
        }else{
            if let id = addressDict?.addressID, id != ""{
                setAddressUIForGuest()
            }else{
                newAddressSetup()
            }
        }
        callGetCountryApi()
    }
    
    func newAddressSetup(){
        self.latVal = ""
        self.longVal = ""
        self.myLblTitle.text = NSLocalizedString("New Address", comment: "")
        self.addressId = ""
        self.myTxtFname.text = ""
        self.myTxtLname.text = ""
        self.myTxtMobile.text = ""
        self.myTxtLandline.text = ""
        self.myTxtArea.text = ""
        self.myTxtAddress.text = ""
        self.myTxtAddressType.text = NSLocalizedString("House", comment: "")
        self.editAddressType(selectedType: 0)
        self.myTxtBlock.text = ""
        self.myTxtStreet.text = ""
        self.myTxtBuilding.text = ""
        self.myTxtFloor.text = ""
        self.myTxtApartment.text = ""
        self.myTxtAdditionalDirections.text = ""
        if(UserDefaults.standard.object(forKey: UD_USER_DETAILS) != nil) {
            let data = UserDefaults.standard.value(forKey: UD_USER_DETAILS) as! Data
            do {
                if let userDic = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSDictionary {
                    self.myTxtFname.text = "\(userDic.value(forKey: "firstname") as! String)"
                    self.myTxtLname.text = "\(userDic.value(forKey: "lastname") as! String)"
                    self.myTxtEmail.text = "\(userDic.value(forKey: "email") as! String)"
                    self.myTxtMobile.text = "\(userDic.value(forKey: "telephone") as! String)"
                }
            }catch{
                print("Couldn't read file.")
            }
        }
        self.myScrollView.isHidden = false
        self.myViewNaigation.isHidden = false
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    func setAddressUIForGuest(){
        self.myLblTitle.text = NSLocalizedString("Edit Address", comment: "")
        self.zoneId = self.addressDict?.zoneId ?? ""
        self.addressId = self.addressDict?.addressID ?? ""
        self.myTxtFname.text =  self.addressDict?.firstName
        self.myTxtLname.text =  self.addressDict?.lastName
        self.myTxtEmail.text =  self.addressDict?.email
        self.myTxtMobile.text =  self.addressDict?.mobile
        self.myLblCountryCode.text =  self.addressDict?.countryCode
        self.myTxtLandline.text =  self.addressDict?.landline
        self.myTxtArea.text =  self.addressDict?.area
        self.myTxtAddress.text =  self.addressDict?.address
        self.myTxtBlock.text =  self.addressDict?.block
        self.myTxtStreet.text =  self.addressDict?.street
        self.myTxtBuilding.text =  self.addressDict?.buildingName
        self.myTxtFloor.text =  self.addressDict?.floor
        self.myTxtApartment.text =  self.addressDict?.doorNo
        self.myTxtAdditionalDirections.text =  self.addressDict?.additionalDirection
        let addressType = self.addressDict?.addressType
        if addressType == "1"{
            self.myTxtAddressType.text = NSLocalizedString("House", comment: "")
            self.editAddressType(selectedType: 0)
        }else if addressType == "2"{
            self.myTxtAddressType.text = NSLocalizedString("Apartment", comment: "")
            self.editAddressType(selectedType: 1)
        }else if addressType == "3"{
            self.myTxtAddressType.text = NSLocalizedString("Office", comment: "")
            self.editAddressType(selectedType: 2)
        }
        self.latVal = self.addressDict?.latitude ?? ""
        self.longVal = self.addressDict?.longitude ?? ""
        if self.latVal != "" && self.longVal != ""{
            let camera = GMSCameraPosition.camera(withLatitude: Double(self.latVal) ?? 0, longitude: Double(self.longVal) ?? 0, zoom: 17.0)
            self.myMapVwNonEdited?.camera = camera
            self.myMapVwNonEdited?.animate(to: camera)
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: Double(self.addressDict?.latitude ?? "") ?? 0, longitude: Double(self.addressDict?.longitude ?? "") ?? 0)
            marker.map = myMapVwNonEdited
        }
        self.selectedLat = self.latVal
        self.selectedLong = self.longVal
        callGetAvailableZone()
        self.myScrollView.isHidden = false
        self.myViewNaigation.isHidden = false
        
    }
    
    //MARK: Button action
    @IBAction func clickBack(_ sender: UIButton){
        self.dismiss(animated: true)
    }
    
    @IBAction func clickAddNew(_ sender: UIButton){
        newAddressSetup()
    }
    
    @IBAction func clickSave(_ sender: UIButton){
        if self.myTxtFname.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter first name", comment: ""))
        }else if self.myTxtLname.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter last name", comment: ""))
        }else if self.myTxtEmail.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Email-Id", comment: ""))
        }else if !HELPER.isValidEmail(testStr: myTxtEmail.text!){
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter a Valid Email-Id", comment: ""))
        }else if self.myTxtMobile.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter mobile number", comment: ""))
        }else if self.myTxtAddress.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please select address", comment: ""))
        }else if self.myTxtAddressType.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please select address type", comment: ""))
        }else if self.myTxtBlock.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter block", comment: ""))
        }else if self.myTxtStreet.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter street", comment: ""))
        }else{
            if self.myTxtAddressType.text == NSLocalizedString("House", comment: ""){
                if self.myTxtBuilding.text == ""{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter house", comment: ""))
                }else{
                    if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
                        callPostAddressApi()
                    }else{
                        postGuestAddress()
                    }
                }
            }else if self.myTxtAddressType.text == NSLocalizedString("Apartment", comment: ""){
                if self.myTxtBuilding.text == ""{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter building", comment: ""))
                }else if self.myTxtFloor.text == ""{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter floor", comment: ""))
                }else if self.myTxtApartment.text == ""{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter apartment", comment: ""))
                }else{
                    if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
                        callPostAddressApi()
                    }else{
                        postGuestAddress()
                    }
                }
            }else if self.myTxtAddressType.text == NSLocalizedString("Office", comment: ""){
                if self.myTxtBuilding.text == ""{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter building", comment: ""))
                }else if self.myTxtFloor.text == ""{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter floor", comment: ""))
                }else if self.myTxtApartment.text == ""{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter office", comment: ""))
                }else{
                    if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
                        callPostAddressApi()
                    }else{
                        postGuestAddress()
                    }
                }
            }
        }
    }
    
    @IBAction func clickCloseEditing(_ sender: UIButton){
        view.endEditing(true)
        if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
            self.myScrollView.isHidden = true
            self.myViewNaigation.isHidden = true
        }else{
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func clickChangeLocation(_ sender: UIButton){
        view.endEditing(true)
        self.mapType = "main"
        print(self.latVal)
        print(self.mapType)
        if self.latVal != "" && self.longVal != ""{
            self.selectedLat = self.latVal
            self.selectedLong = self.longVal
            let camera = GMSCameraPosition.camera(withLatitude: Double(self.selectedLat) ?? 0, longitude: Double(self.selectedLong) ?? 0, zoom: 17.0)
            self.myMapVwEdited?.camera = camera
            self.myMapVwEdited?.animate(to: camera)
            self.myLblAddress.text = self.myTxtAddress.text
            self.myMapVwEdited.delegate = self
        }else{
            self.myMapVwEdited.delegate = self
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
        }
        self.myViewMapContainer.isHidden = false
    }
    
    @IBAction func clickCountryCode(_ sender: Any) {
        view.endEditing(true)
        if countryArray.count != 0 {
            self.myViewPickervw.isHidden = false
        }else {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Country code not available", comment: ""))
        }
    }
    
    @IBAction func clickPickerDone(_ sender: Any) {
        view.endEditing(true)
        let countryCode = self.countryArray[selectedCountryCodeIndex]["code"] as? String
        self.myLblCountryCode.text! = countryCode!
        self.myViewPickervw.isHidden = true
    }
    
    @IBAction func clickPickerCancel(_ sender: Any) {
        view.endEditing(true)
        self.myViewPickervw.isHidden = true
    }
    
    @IBAction func clickBackFomMap(_ sender : UIButton)
    {
        self.mapType = ""
        self.myMapVwEdited.delegate = nil
        self.myViewMapContainer.isHidden = true
    }
    
    @IBAction func clickMyLocation(_ sender: Any)
    {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func clickConfirmLocation(_ sender: Any)
    {
        if myLblAddress.text == ""
        {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please select Location", comment: ""))
        }
        else
        {
            self.mapType = ""
            myMapVwEdited.delegate = nil
            self.myViewMapContainer.isHidden = true
            self.myTxtAddress.text = self.myLblAddress.text
            self.myTxtStreet.text = self.addressComponents[0]["long_name"] as? String
            
//            if self.selectedLat != "" && self.selectedLong != ""{
//
//                self.latVal = self.selectedLat
//                self.longVal = self.selectedLong
//
//                let camera = GMSCameraPosition.camera(withLatitude: Double(self.selectedLat) ?? 0, longitude: Double(self.selectedLong) ?? 0, zoom: 17.0)
//                self.myMapVwNonEdited?.camera = camera
//                self.myMapVwNonEdited?.animate(to: camera)
//                let marker = GMSMarker()
//                marker.position = CLLocationCoordinate2D(latitude: Double(self.selectedLat) ?? 0, longitude: Double(self.selectedLong) ?? 0)
//                marker.map = self.myMapVwNonEdited
//            }
            
            callGetAvailableZone()
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
    
    @IBAction func clickArea(_ sender: UIButton) {
        view.endEditing(true)
        var tempArray = [String]()
        for obj in self.availableZoneList{
            tempArray.append(obj["zone_name"] as! String)
        }
        dropDown.dataSource = tempArray
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let _ = self else { return }
            self?.myTxtArea.text = item
            self?.zoneId = self?.availableZoneList[index]["zone_id"] as! String
        }
    }
    
    @IBAction func clickAddressType(_ sender: UIButton) {
        view.endEditing(true)
        dropDown.dataSource = [NSLocalizedString("House", comment: ""), NSLocalizedString("Apartment", comment: ""), NSLocalizedString("Office", comment: "")]
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let _ = self else { return }
            self?.myTxtAddressType.text = item
            self?.editAddressType(selectedType: index)
        }
    }
}

extension AddressVc : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressListModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressTblCell
        cell.lblName.text = (self.addressListModel[indexPath.row].firstName ?? "") + " " +  (self.addressListModel[indexPath.row].lastName ?? "")
        cell.lblMobile.text = NSLocalizedString("Mobile", comment: "") + ": " + (self.addressListModel[indexPath.row].countryCode ?? "") + "-" + (self.addressListModel[indexPath.row].mobile ?? "")
        if self.addressListModel[indexPath.row].addressType == "1"{
//            cell.lblAddress.text = NSLocalizedString("House", comment: "") + " " + (self.addressListModel[indexPath.row].area ?? "")(self.addressListModel[indexPath.row].area ?? "")
            cell.lblAddress.text = self.addressListModel[indexPath.row].address ?? ""
            cell.lblStreet.text = "\(self.addressListModel[indexPath.row].block ?? ""), \(self.addressListModel[indexPath.row].street ?? ""),  \(self.addressListModel[indexPath.row].buildingName ?? "")"
        }else{
//            if self.addressListModel[indexPath.row].addressType == "2"{
//                cell.lblAddress.text = NSLocalizedString("Apartment", comment: "") + " " + (self.addressListModel[indexPath.row].area ?? "")
//            }else if self.addressListModel[indexPath.row].addressType == "3"{
//                cell.lblAddress.text = NSLocalizedString("Office", comment: "") + " " + (self.addressListModel[indexPath.row].area ?? "")
//            }
            
            cell.lblAddress.text = self.addressListModel[indexPath.row].address ?? ""
            cell.lblStreet.text = "\(self.addressListModel[indexPath.row].block ?? ""), \(self.addressListModel[indexPath.row].street ?? ""), \(self.addressListModel[indexPath.row].buildingName ?? ""), \(self.addressListModel[indexPath.row].floor ?? ""), \(self.addressListModel[indexPath.row].doorNo ?? "")"
        }        
        cell.btnEdit.addTarget(self, action: #selector(clickEditAddress(_:)), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(clickDeleteAddress(_:)), for: .touchUpInside)
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 171
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if vendorId != ""{
            self.callPostDeliveryAddress(selectedIndex: indexPath.row)
        }
    }
    
    @objc func clickEditAddress(_ sender: UIButton){
        self.myLblTitle.text = NSLocalizedString("Edit Address", comment: "")
        self.addressDict = self.addressListModel[sender.tag]
        self.zoneId = self.addressDict?.zoneId ?? ""
        self.addressId = self.addressDict?.addressID ?? ""
        self.myTxtFname.text =  self.addressDict?.firstName
        self.myTxtLname.text =  self.addressDict?.lastName
        self.myTxtEmail.text =  self.addressDict?.email
        self.myTxtMobile.text =  self.addressDict?.mobile
        self.myLblCountryCode.text =  self.addressDict?.countryCode
        self.myTxtLandline.text =  self.addressDict?.landline
        self.myTxtArea.text =  self.addressDict?.area
        self.myTxtAddress.text =  self.addressDict?.address
        self.myTxtBlock.text =  self.addressDict?.block
        self.myTxtStreet.text =  self.addressDict?.street
        self.myTxtBuilding.text =  self.addressDict?.buildingName
        self.myTxtFloor.text =  self.addressDict?.floor
        self.myTxtApartment.text =  self.addressDict?.doorNo
        self.myTxtAdditionalDirections.text =  self.addressDict?.additionalDirection
        let addressType = self.addressDict?.addressType
        if addressType == "1"{
            self.myTxtAddressType.text = NSLocalizedString("House", comment: "")
            self.editAddressType(selectedType: 0)
        }else if addressType == "2"{
            self.myTxtAddressType.text = NSLocalizedString("Apartment", comment: "")
            self.editAddressType(selectedType: 1)
        }else if addressType == "3"{
            self.myTxtAddressType.text = NSLocalizedString("Office", comment: "")
            self.editAddressType(selectedType: 2)
        }
        self.latVal = self.addressDict?.latitude ?? ""
        self.longVal = self.addressDict?.longitude ?? ""
        if self.latVal != "" && self.longVal != ""{
            let camera = GMSCameraPosition.camera(withLatitude: Double(self.latVal) ?? 0, longitude: Double(self.longVal) ?? 0, zoom: 17.0)
            self.myMapVwNonEdited?.camera = camera
            self.myMapVwNonEdited?.animate(to: camera)
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: Double(self.addressDict?.latitude ?? "") ?? 0, longitude: Double(self.addressDict?.longitude ?? "") ?? 0)
            marker.map = myMapVwNonEdited
        }
        self.selectedLat = self.latVal
        self.selectedLong = self.longVal
        callGetAvailableZone()
        self.myScrollView.isHidden = false
        self.myViewNaigation.isHidden = false
    }
    
    @objc func clickDeleteAddress(_ sender: UIButton){
        let addressID = self.addressListModel[sender.tag].addressID ?? ""
        guard addressID != "" else {return}
        self.callPostDeleteAddress(addressId: addressID)
    }
}

extension AddressVc : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let name = self.countryArray[row]["name"] as? String
        return name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCountryCodeIndex = row
    }
}


extension AddressVc: GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print(place)
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        selectedLat = "\(lat)"
        selectedLong = "\(long)"
        myMapVwEdited.delegate = nil
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17.0)
        self.myMapVwEdited?.camera = camera
        self.myMapVwEdited?.animate(to: camera)
        self.myLblAddress.text = "\(String(describing: place.formattedAddress!))"
        //self.myTxtAddress.text = "\(String(describing: place.formattedAddress!))"
        addressFromLatLong(lat: lat, long: long)
        
        UINavigationBar.appearance().barTintColor = ConfigTheme.themeColor
        UINavigationBar.appearance().tintColor = ConfigTheme.themeColor
        dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2)
        {
            self.myMapVwEdited.delegate = self
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
extension AddressVc: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)
    {
        let camera = GMSCameraPosition.camera(withLatitude: (coordinate.latitude), longitude: (coordinate.longitude), zoom: 17.0)
        self.myMapVwEdited?.camera = camera
        self.myMapVwEdited?.animate(to: camera)
        selectedLat = "\(coordinate.latitude)"
        selectedLong = "\(coordinate.longitude)"
        addressFromLatLong(lat: coordinate.latitude, long: coordinate.longitude)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition)
    {
        self.myMapVwEdited.settings.consumesGesturesInView = false
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panHandler(_:)))
        self.myMapVwEdited.addGestureRecognizer(panGesture)
    }
    
    @objc private func panHandler(_ pan : UIPanGestureRecognizer){
        if pan.state == .ended{
            let mapSize = self.myMapVwEdited.frame.size
            let point = CGPoint(x: mapSize.width/2, y: mapSize.height/2)
            let newCoordinate = self.myMapVwEdited.projection.coordinate(for: point)
            print(newCoordinate)
            selectedLat = "\(newCoordinate.latitude)"
            selectedLong = "\(newCoordinate.longitude)"
            addressFromLatLong(lat: newCoordinate.latitude, long: newCoordinate.longitude)
        }
    }
    
}

extension AddressVc: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if locations.last != nil
        {
            let location = locations.last
            
            let camera = GMSCameraPosition.camera(withLatitude: location?.coordinate.latitude ?? 0, longitude: location?.coordinate.longitude ?? 0, zoom: 17.0)
            let lat = location?.coordinate.latitude
            let long = location?.coordinate.longitude
//            selectedLat = "\(String(describing: lat))"
//            selectedLong = "\(String(describing: long))"
            selectedLat = "\(lat ?? 0)"
            selectedLong = "\(long ?? 0)"
            if mapType == "main"{
                self.myMapVwEdited?.camera = camera
                self.myMapVwEdited?.animate(to: camera)
                self.addressFromLatLong(lat: (location?.coordinate.latitude)!, long: (location?.coordinate.longitude)!)
                self.locationManager.stopUpdatingLocation()
            }else{
                self.myMapVwNonEdited?.camera = camera
                self.myMapVwNonEdited?.animate(to: camera)
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: location?.coordinate.latitude ?? 0, longitude: location?.coordinate.longitude ?? 0 )
                marker.map = myMapVwNonEdited
                
                let lat = location?.coordinate.latitude
                let long = location?.coordinate.longitude
                self.latVal = "\(lat ?? 0)"
                self.longVal = "\(long ?? 0)"
                
                self.addressFromLatLong(lat: (location?.coordinate.latitude)!, long: (location?.coordinate.longitude)!)
//                callGetAvailableZone()
                self.locationManager.stopUpdatingLocation()
            }
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
