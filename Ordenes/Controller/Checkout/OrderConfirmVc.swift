
import UIKit
import GoogleMaps
import Lottie

enum TravelModes: Int
{
    case driving
    case walking
    case bicycling
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

class OrderConfirmVc: UIViewController {

    @IBOutlet weak var myTblProducts : UITableView!
    @IBOutlet weak var myViewScroll : UIScrollView!
    @IBOutlet weak var myMapView : GMSMapView!
    @IBOutlet weak var myViewContainer : UIView!
    @IBOutlet weak var myView1 : UIView!
    @IBOutlet weak var myView2 : UIView!
    @IBOutlet weak var myView3 : UIView!
    @IBOutlet weak var myView4 : UIView!
    @IBOutlet weak var myViewLoading : UIView!
    @IBOutlet weak var myLblTime : UILabel!
    @IBOutlet weak var myLblRestaurant : UILabel!
    @IBOutlet weak var myLblRider : UILabel!
    @IBOutlet weak var myLblFindingRider : UILabel!
    @IBOutlet weak var myLblFname : UILabel!
    @IBOutlet weak var myLblAddress1 : UILabel!
    @IBOutlet weak var myLblHeader : UILabel!
    @IBOutlet weak var myImgRider : UIImageView!
    @IBOutlet weak var myViewProgress : UIView!
    @IBOutlet weak var myViewCompleted1 : UIView!
    @IBOutlet weak var myViewCompleted2 : UIView!
    @IBOutlet weak var myViewCompleted3 : UIView!
    @IBOutlet weak var myViewCompleted4 : UIView!
    @IBOutlet weak var myViewProgress1 : UIView!
    @IBOutlet weak var myViewProgress2 : UIView!
    @IBOutlet weak var myViewProgress3 : UIView!
    @IBOutlet weak var myBtnTracker : UIButton!
    @IBOutlet weak var myBtnCallDriver : UIButton!
    private var aniLoading: AnimationView?
    
    var travelMode = TravelModes.driving
    var mapTasks = MapTasks()
    var routePolyline: GMSPolyline!
    var locationMarker: GMSMarker!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var markersArray: Array<GMSMarker> = []
    var waypointsArray: Array<String> = []
    var markerList = [GMSMarker]()
    var orderId = ""
    var orderModel: OrderConfirmModel?
    var driverTimer = Timer()
    var isFromSuccess = true
    var driverId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callGetOrderConfirmApi()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.driverTimer.invalidate()
    }
    
    //MARK: Functions
    func setupUI(){
        self.myViewCompleted1.dropShadow(cornerRadius: 15, opacity: 0.2, radius: 8)
        self.myViewCompleted2.dropShadow(cornerRadius: 15, opacity: 0.2, radius: 8)
        self.myViewCompleted3.dropShadow(cornerRadius: 15, opacity: 0.2, radius: 8)
        self.myViewCompleted4.dropShadow(cornerRadius: 15, opacity: 0.2, radius: 8)
        self.myTblProducts.layer.cornerRadius = 8
        self.myView1.layer.cornerRadius = 8
        self.myView4.layer.cornerRadius = 8
        self.myView3.layer.cornerRadius = 8
        self.myTblProducts.layer.borderWidth = 1
        self.myView1.layer.borderWidth = 1
        self.myView4.layer.borderWidth = 1
        self.myView3.layer.borderWidth = 1
        self.myTblProducts.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myView1.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myView4.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myView3.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myViewContainer.frame.size.width = self.view.frame.size.width
        self.myViewContainer.frame.size.height = self.myTblProducts.frame.origin.y + self.myTblProducts.frame.size.height + 15
        self.myViewContainer.translatesAutoresizingMaskIntoConstraints = true
        self.myViewScroll.addSubview(self.myViewContainer)
    }
    
    func callGetOrderConfirmApi() {
        self.driverTimer.invalidate()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_ID] = self.orderId
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_TRACK_ORDER, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    let modelData = try! JSONDecoder().decode(OrderConfirmModule.self, from: jsonData)
                    self.orderModel = modelData.order
                    self.myTblProducts.delegate = self
                    self.myTblProducts.dataSource = self
                    self.myTblProducts.reloadData()
                    let fromLatLong = (self.orderModel?.vendorLatitude ?? "") + "," + (self.orderModel?.vendorLongitude ?? "")
                    let toLatLong = (self.orderModel?.customerLatitude ?? "") + "," + (self.orderModel?.customerLongitude ?? "")
                    self.createRoutes(fromLatLong, toAdd: toLatLong)
                    self.driverId = self.orderModel?.driverID ?? ""
                    if self.driverId != ""{
                        if isRTLenabled{
                            self.myLblRider.text = (self.orderModel?.driverName ?? "") + " : " + NSLocalizedString("Name", comment: "")
                            self.myLblFindingRider.text = (self.orderModel?.driverMobile ?? "") + " : " + NSLocalizedString("Mobile", comment: "")
                        }else{
                            self.myLblRider.text = NSLocalizedString("Name", comment: "")  + " : " + (self.orderModel?.driverName ?? "")
                            self.myLblFindingRider.text = NSLocalizedString("Mobile", comment: "")  + " : " + (self.orderModel?.driverMobile ?? "")
                        }
                        self.myBtnCallDriver.isHidden = false
                        let imageUrl = self.orderModel?.driverProfile
                        let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
                        var activityLoader = UIActivityIndicatorView()
                        activityLoader = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
                        activityLoader.center = self.myImgRider.center
                        activityLoader.startAnimating()
                        self.myImgRider.addSubview(activityLoader)
                        self.myImgRider.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                            if image != nil
                            {
                                activityLoader.stopAnimating()
                            }
                            else
                            {
                                print("image not found")
                                self.myImgRider.image = UIImage(named: "no_image")
                                activityLoader.stopAnimating()
                            }
                        })
                        if let statusId = self.orderModel?.orderStatusID, statusId != "9"{
                            self.driverTimer.invalidate()
                            self.driverTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.callGetDriver), userInfo: nil, repeats: true)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                                self.driverTimer.fire()
                            }
                        }
                    }else{
                        self.myBtnCallDriver.isHidden = true
                        self.myLblRider.text = NSLocalizedString("Finding an available rider", comment: "")
                        self.myLblFindingRider.text = ""
                        self.driverTimer.invalidate()
                        self.driverTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.callGetDriver), userInfo: nil, repeats: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                            self.driverTimer.fire()
                        }
                    }
                    self.myLblAddress1.text = (self.orderModel?.deliveryAddress ?? "") + "\n" + NSLocalizedString("Mobile:", comment: "") + (self.orderModel?.customerMobile ?? "")
                    self.myLblFname.text = self.orderModel?.zoneName ?? ""
                    if self.orderModel?.scheduleStatus == "1"{
                        if isRTLenabled{
                            if let statusId = self.orderModel?.orderStatusID, statusId == "1"{
                                self.myLblRestaurant.text = (self.orderModel?.vendorName ?? "Restaurant/Store") + " " + NSLocalizedString("Sending your order to", comment: "")
                           
                            } else if let statusId = self.orderModel?.orderStatusID, statusId == "2"{
                                let status = self.orderModel?.orderStatus ?? ""
                                self.myLblRestaurant.text =  (status) + " " + NSLocalizedString("Your order is", comment: "")
                           
                            }
                            self.myLblTime.text = (self.orderModel?.scheduleTime ?? "") + " " + (self.orderModel?.scheduleDate ?? "")
                        }else{
                            if let statusId = self.orderModel?.orderStatusID, statusId == "1"{
                                self.myLblRestaurant.text = NSLocalizedString("Sending your order to", comment: "") + " " + (self.orderModel?.vendorName ?? "Restaurant/Store")
                           
                            } else if let statusId = self.orderModel?.orderStatusID, statusId == "2"{
                                let status = self.orderModel?.orderStatus ?? ""
                                self.myLblRestaurant.text = NSLocalizedString("Your order is", comment: "") + " " + (status)
                           
                            }
                            self.myLblTime.text = (self.orderModel?.scheduleDate ?? "") + " " + (self.orderModel?.scheduleTime ?? "")
                        }
                    }else{
                        if isRTLenabled{
                            if let statusId = self.orderModel?.orderStatusID, statusId == "1"{
                                self.myLblRestaurant.text = (self.orderModel?.vendorName ?? "Restaurant/Store") + " " + NSLocalizedString("Sending your order to", comment: "")
                           
                            } else if let statusId = self.orderModel?.orderStatusID, statusId == "2"{
                                let status = self.orderModel?.orderStatus ?? ""
                                self.myLblRestaurant.text =  (status) + " " + NSLocalizedString("Your order is", comment: "")
                           
                            }
                            self.myLblTime.text = NSLocalizedString("minutes", comment: "") + " " + (self.orderModel?.deliveryTime ?? "") + " " + NSLocalizedString("Approximately delivery time is", comment: "")
                            
                        }else{
                            if let statusId = self.orderModel?.orderStatusID, statusId == "1"{
                                self.myLblRestaurant.text = NSLocalizedString("Sending your order to", comment: "") + " " + (self.orderModel?.vendorName ?? "Restaurant/Store")
                           
                            } else if let statusId = self.orderModel?.orderStatusID, statusId == "2"{
                                let status = self.orderModel?.orderStatus ?? ""
                                self.myLblRestaurant.text = NSLocalizedString("Your order is", comment: "") + " " + (status)
                           
                            }
                            self.myLblTime.text = NSLocalizedString("Approximately delivery time is", comment: "") + " " + (self.orderModel?.deliveryTime ?? "") + " " + NSLocalizedString("minutes", comment: "")
                        }
                    }
                    self.progressSetup(orderStatusId: self.orderModel?.orderStatusID ?? "", orderStatus: self.orderModel?.orderStatus ?? "")
                    
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }else{
                        self.myViewContainer.isHidden = false
                    }
                } else {
                    HELPER.hideLoadingAnimation()
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_ORDER_MODULE_EMPTY)
                }
            } catch {
                print(error.localizedDescription)
            }
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    @objc func callGetDriver() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_ID] = self.orderId
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_TRACK_ORDER, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                print(response)
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    let modelData = try! JSONDecoder().decode(OrderConfirmModule.self, from: jsonData)
                    self.orderModel = modelData.order
                    if let statusId = self.orderModel?.orderStatusID, statusId == "5" || statusId == "6" || statusId == "8"{
                        self.myLblHeader.text = NSLocalizedString("Track order", comment: "")
                    }else if let statusId = self.orderModel?.orderStatusID, statusId == "9"{
                        self.myLblHeader.text = NSLocalizedString("Order information", comment: "")
                    }else{
                        self.myLblHeader.text = NSLocalizedString("Order confirmation", comment: "")
                    }
                    if let driverId = self.orderModel?.driverID, driverId != ""{
                        self.myBtnCallDriver.isHidden = false
                        self.driverId = self.orderModel?.driverID ?? ""
                        if isRTLenabled{
                            self.myLblRider.text = (self.orderModel?.driverName ?? "") + " : " + NSLocalizedString("Name", comment: "")
                            self.myLblFindingRider.text = (self.orderModel?.driverMobile ?? "") + " : " + NSLocalizedString("Mobile", comment: "")
                        }else{
                            self.myLblRider.text = NSLocalizedString("Name", comment: "")  + " : " + (self.orderModel?.driverName ?? "")
                            self.myLblFindingRider.text = NSLocalizedString("Mobile", comment: "")  + " : " + (self.orderModel?.driverMobile ?? "")
                        }
                        if self.orderModel?.orderStatusID == "9"{
                            self.driverTimer.invalidate()
                        }else{
                            if self.driverId != ""{
                                self.driverTimer.invalidate()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 120.0){
                                    self.callGetDriver()
                                }
                            }
                        }
                        let imageUrl = self.orderModel?.driverProfile
                        let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
                        var activityLoader = UIActivityIndicatorView()
                        activityLoader = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
                        activityLoader.center = self.myImgRider.center
                        activityLoader.startAnimating()
                        self.myImgRider.addSubview(activityLoader)
                        self.myImgRider.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                            if image != nil
                            {
                                activityLoader.stopAnimating()
                            }
                            else
                            {
                                self.myImgRider.image = UIImage(named: "no_image")
                                activityLoader.stopAnimating()
                            }
                        })
                    }else{
                        self.myBtnCallDriver.isHidden = true
                        self.myLblRider.text = NSLocalizedString("Finding an available rider", comment: "")
                        self.myLblFindingRider.text = ""
                    }
                    self.progressSetup(orderStatusId: self.orderModel?.orderStatusID ?? "", orderStatus: self.orderModel?.orderStatus ?? "")
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }, failureBlock: { (errorResponse) in
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func createRoutes(_ fromAdd: String, toAdd: String)
    {
        if self.routePolyline != nil
        {
            self.clearRoute()
            self.waypointsArray.removeAll(keepingCapacity: false)
        }
        self.mapTasks.getDirections(fromAdd , destination: toAdd, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
            if success
            {
                self.configureMapAndMarkersForRoute()
                self.drawRoute()
            }
            else
            {
                print(status)
            }
        })
    }
    
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepingCapacity: false)
        }
    }
    
    func configureMapAndMarkersForRoute() {
        myMapView.camera = GMSCameraPosition.camera(withTarget: self.mapTasks.originCoordinate, zoom: 17.0)
        
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.myMapView
        
        let markerImg1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        markerImg1.image = UIImage(named: "ic_restaurant_location")
        markerImg1.contentMode = .scaleAspectFit
        self.originMarker.iconView = markerImg1
        //originMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.myMapView
        let markerImg2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        markerImg2.image = UIImage(named: "ic_customer_location")
        markerImg2.contentMode = .scaleAspectFit
        self.destinationMarker.iconView = markerImg2
        
        //destinationMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        self.markerList.append(self.originMarker)
        self.markerList.append(self.destinationMarker)
//        if waypointsArray.count > 0
//        {
//            for waypoint in waypointsArray
//            {
//                let lat: Double = (waypoint.components(separatedBy: ",")[0] as NSString).doubleValue
//                let lng: Double = (waypoint.components(separatedBy: ",")[1] as NSString).doubleValue
//
//                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
//                marker.map = myMapView
//                marker.icon = GMSMarker.markerImage(with: UIColor.purple)
//
//                markersArray.append(marker)
//            }
//        }
    }
    
    func drawRoute()
    {
        let route = mapTasks.overviewPolyline["points"] as! String
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = myMapView
        routePolyline.strokeWidth = 2.0
        routePolyline.strokeColor = UIColor.red
        var bounds = GMSCoordinateBounds()
        for marker in markerList {
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
        self.myMapView.animate(with: update)
    }
    
    func progressSetup(orderStatusId: String, orderStatus: String){
        print(orderStatusId)
        if orderStatusId == "3"{
            self.myViewProgress1.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewCompleted2.backgroundColor = UIColor(named: "clr_light_orange1")
            if isRTLenabled{
                self.myLblRestaurant.text =  orderStatus + NSLocalizedString("Your order is ", comment: "")
            }else{
                self.myLblRestaurant.text = NSLocalizedString("Your order is ", comment: "") + orderStatus
            }
        }else if orderStatusId == "5"{
            self.myViewProgress1.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewCompleted2.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewProgress2.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewCompleted3.backgroundColor = UIColor(named: "clr_light_orange1")
            if isRTLenabled{
                self.myLblRestaurant.text =  orderStatus + NSLocalizedString("Your order is ", comment: "")
            }else{
                self.myLblRestaurant.text = NSLocalizedString("Your order is ", comment: "") + orderStatus
            }
        }else if orderStatusId == "6" {
            self.myViewProgress1.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewCompleted2.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewProgress2.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewCompleted3.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myLblRestaurant.text =  orderStatus
        }else if orderStatusId == "8"{
            self.myViewProgress1.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewCompleted2.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewProgress2.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewCompleted3.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myLblRestaurant.text = NSLocalizedString("Your order is on the way", comment: "")
        }else if orderStatusId == "9"{
            self.myViewProgress1.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewCompleted2.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewProgress2.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewCompleted3.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewProgress3.backgroundColor = UIColor(named: "clr_light_orange1")
            self.myViewCompleted4.backgroundColor = UIColor(named: "clr_light_orange1")
            if isRTLenabled{
                self.myLblRestaurant.text =  orderStatus + NSLocalizedString("Your order is ", comment: "")
            }else{
                self.myLblRestaurant.text = NSLocalizedString("Your order is ", comment: "") + orderStatus
            }
        }else if orderStatusId == "4" || orderStatusId == "7" || orderStatusId == "13"{
            var msg = ""
            if isRTLenabled{
                msg =  orderStatus + NSLocalizedString("Your order was ", comment: "")
            }else{
                msg = NSLocalizedString("Your order was ", comment: "") + orderStatus
            }
            HELPER.showAlertControllerWithOkActionBlock(aViewController: self, aStrMessage: msg) { okAction in
                if self.isFromSuccess{
                    let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
                    let navi = UINavigationController.init(rootViewController: aViewController)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                    appDelegate.window?.rootViewController = navi
                    appDelegate.window?.makeKeyAndVisible()
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        setupViews(orderStatusId : orderStatusId)
    }
    
    func setupViews(orderStatusId: String){
        if orderStatusId == "9" || orderStatusId == "4" || orderStatusId == "7" || orderStatusId == "13"{
            self.myBtnTracker.isHidden = true
            self.myLblTime.isHidden = true
            self.myViewProgress.frame.origin.y = 12
            self.myLblRestaurant.frame.origin.y = self.myViewProgress.frame.origin.y + 40
            self.myView1.frame.size.height = self.myLblRestaurant.frame.origin.y + 35
            self.myView2.frame.origin.y = self.myView1.frame.origin.y + self.myView1.frame.size.height + 8
            self.myView3.frame.origin.y = self.myView2.frame.origin.y + self.myView2.frame.size.height + 8
            self.myTblProducts.frame.origin.y = self.myView3.frame.origin.y + self.myView3.frame.size.height + 8
        }else{
            if self.orderModel?.driverID != ""{
                self.myBtnTracker.isHidden = false
                self.myLblTime.isHidden = false
                self.myView2.frame.origin.y = self.myView1.frame.origin.y + self.myView1.frame.size.height + 8
                self.myView2.frame.size.height = self.myBtnTracker.frame.origin.y + self.myBtnTracker.frame.size.height
                self.myView3.frame.origin.y = self.myView2.frame.origin.y + self.myView2.frame.size.height + 8
                self.myTblProducts.frame.origin.y = self.myView3.frame.origin.y + self.myView3.frame.size.height + 8
            }else{
                self.myBtnTracker.isHidden = true
                self.myLblTime.isHidden = false
                self.myView2.frame.origin.y = self.myView1.frame.origin.y + self.myView1.frame.size.height + 8
                self.myView2.frame.size.height = self.myView4.frame.origin.y + self.myView4.frame.size.height
                self.myView3.frame.origin.y = self.myView2.frame.origin.y + self.myView2.frame.size.height + 8
                self.myTblProducts.frame.origin.y = self.myView3.frame.origin.y + self.myView3.frame.size.height + 8
            }
        }
        self.myTblProducts.frame.size.height = self.myTblProducts.contentSize.height
        self.myTblProducts.translatesAutoresizingMaskIntoConstraints = true
        self.myViewContainer.frame.size.height = self.myTblProducts.frame.origin.y + self.myTblProducts.frame.size.height + 10
        self.myViewContainer.translatesAutoresizingMaskIntoConstraints = true
        self.myViewScroll.contentSize.height = self.myViewContainer.frame.size.height
        HELPER.hideLoadingAnimation()
    }
    
    //MARK: Button action
    @IBAction func clickBack(_ sender: UIButton) {
        if isFromSuccess{
            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
            let navi = UINavigationController.init(rootViewController: aViewController)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
            appDelegate.window?.rootViewController = navi
            appDelegate.window?.makeKeyAndVisible()
        }else{
            self.navigationController?.popViewController(animated: true)
        }        
    }
    
    @IBAction func clickCallDriver(_ sender: UIButton) {
        guard let phoneNumber = self.orderModel?.driverMobile, phoneNumber != "" else{return}
        if let phoneURL = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func clickTrack(_ sender: UIButton) {
        if let driverId = self.orderModel?.driverID, driverId != ""{
            if let orderStatus = self.orderModel?.orderStatusID{
                if orderStatus == "8"{
                    let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: TrackingVc.storyboardID) as! TrackingVc
                    aViewController.fromLatLong = (self.orderModel?.vendorLatitude ?? "") + "," + (self.orderModel?.vendorLongitude ?? "")
                    aViewController.toLatLong = (self.orderModel?.customerLatitude ?? "") + "," + (self.orderModel?.customerLongitude ?? "")
                    aViewController.driverId = driverId
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }else if orderStatus == "9"{
                    
                }else{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("You can track the rider, once order has picked", comment: ""))
                }
            }
        }else{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Waiting for the rider to accept the order", comment: ""))
        }
    }
}

extension OrderConfirmVc: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! OrderConfirmTblCell
        headerCell.myLblHeader.text = self.orderModel?.vendorName
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 53
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableCell(withIdentifier: "paymentCell") as! OrderConfirmTblCell
        footerCell.myLblOrderNo.text = self.orderModel?.orderID
        footerCell.myLblAmount.text = self.orderModel?.total
        footerCell.myLblPaymentMode.text = self.orderModel?.paymentMethod
        return footerCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 77
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orderModel?.product?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:OrderConfirmTblCell = self.myTblProducts.dequeueReusableCell(withIdentifier: "productCell") as! OrderConfirmTblCell
        cell.myLblQuantity.text = self.orderModel?.product?[indexPath.row].quantity
        cell.myLblProductName.text = self.orderModel?.product?[indexPath.row].name
        var optionsStr = ""
        for obj in self.orderModel?.product?[indexPath.row].option ?? []{
            let option = (obj.optionName ?? "") + ":" + (obj.optionValue ?? "")
            optionsStr = optionsStr + option + "\n"
        }
        cell.myLblOptions.text = optionsStr
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return 40
    }
}
