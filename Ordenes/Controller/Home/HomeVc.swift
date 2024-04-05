
import UIKit
import SDWebImage
import MarqueeLabel
import FSPagerView
import OneSignal

class HomeVc: UIViewController{
    
    @IBOutlet weak var myViewNavigation : UIView!
    @IBOutlet weak var myViewNavigationBG : UIView!
    @IBOutlet weak var myBtnSearch : UIButton!
    @IBOutlet weak var myLblDeliveryAddress : MarqueeLabel!
    @IBOutlet weak var myTblHome : UITableView!
    @IBOutlet weak var myTblMenuList : UITableView!
    @IBOutlet weak var myViewMenuList : UIView!
    @IBOutlet weak var myViewCart : UIView!
    @IBOutlet weak var myLblCount : UILabel!
    @IBOutlet weak var myLblMinError : UILabel!
    @IBOutlet weak var myLblViewBasket : UILabel!
    @IBOutlet weak var myLblAmount : UILabel!
    @IBOutlet weak var myViewLocationUser : UIView!
    @IBOutlet weak var myTblLocationUser : UITableView!
    @IBOutlet weak var myViewLanguage: UIView!
    @IBOutlet weak var myTblLanguage: UITableView!
    @IBOutlet weak var myBtnCancelLanugae: UIButton!
    @IBOutlet weak var myBtnChangeLanguage: UIButton!
    
    var addressListModel = [Address]()
    var homeModelInfo : HomeModel?
    var brandModel = [Brand]()
    var businessModel = [BusinessType]()
    var topPickModel = [TopPick]()
    var bestOfferModel = [BestOffer]()
    var drinksModel = [BestOffer]()
    var bannerModel = [Banner]()
    var menuList = [[String: Any]]()
    var selectedLanguage = ""
    var languageArr = [[String : Any]]()
    var vendorId = ""
    var vendorType = ""
    var statusView = StatusView()
    var appStoreVersion = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.navigationToRestaurant(_:)), name: .restaurantNavigation, object: nil)
        self.languageArr = [["language_id" : "1", "name" : "English"],["language_id" : "2", "name" : "Arabic"]]
        menuList = [["title" : NSLocalizedString("My Addresses", comment: ""), "image" : "ic_location_filled"], ["title" : NSLocalizedString("My Orders", comment: ""), "image" : "ic_shopping_basket"], ["title" : NSLocalizedString("My Favourites", comment: ""), "image" : "ic_fav_fill"], ["title" : NSLocalizedString("Change Password", comment: ""), "image" : "ic_password"], ["title" : NSLocalizedString("Change Language", comment: ""), "image" : "ic_language"], ["title" : NSLocalizedString("Contact Us", comment: ""), "image" : "ic_contactUs"], ["title" : NSLocalizedString("About Us", comment: ""), "image" : "ic_aboutUs"], ["title" : NSLocalizedString("Privacy Policy", comment: ""), "image" : "ic_privacy"], ["title" : NSLocalizedString("Terms and Conditions", comment: ""), "image" : "ic_terms"], ["title" : NSLocalizedString("Delete Account", comment: ""), "image" : "ic_delete"], ["title" : NSLocalizedString("Logout", comment: ""), "image" : "ic_logout"]]
        
        self.navigationController?.isNavigationBarHidden = true
        if let latLong = UserDefaults.standard.value(forKey: UD_SELECTED_LAT_LONG), "\(latLong)" != ""{
            let array = (latLong as AnyObject).components(separatedBy: ",")
            let lat = array[0]
            let long = array[1]
            if lat != "" && long != ""
            {
                globalLatitude = lat
                globalLongitude = long
                if let location = UserDefaults.standard.value(forKey: UD_SELECTED_ADDRESS), "\(location)" != ""{
                    self.myLblDeliveryAddress.text = location as? String
                }
                callGetCartCount(completionBlock: {
                    self.callGetHomeApi(isInitial: true, lat: globalLatitude, long: globalLongitude)
                })
            }else{
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: MapVc.storyboardID) as! MapVc
                self.present(aViewController, animated: true)
            }
        }else{
            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: MapVc.storyboardID) as! MapVc
            self.present(aViewController, animated: true)
        }
        self.myTblMenuList.dataSource = self
        self.myTblMenuList.delegate = self
        self.myTblMenuList.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .restaurantNavigation, object: nil)
    }
    
    func setupUI() {
        print(guestStatus)
        self.myViewMenuList.frame.size.width = self.view.frame.width
        self.myViewMenuList.frame.size.height = self.view.frame.height - self.myViewMenuList.frame.origin.y
        if isRTLenabled{
            self.myViewMenuList.frame.origin.x = -(self.view.frame.size.width + 10)
            self.myTblMenuList.frame.origin.x = 0
        }else{
            self.myViewMenuList.frame.origin.x = self.view.frame.size.width + 10
            self.myTblMenuList.frame.origin.x = self.myViewMenuList.frame.size.width - self.myTblMenuList.frame.size.width
        }
        self.myViewMenuList.translatesAutoresizingMaskIntoConstraints = true
        self.myTblMenuList.translatesAutoresizingMaskIntoConstraints = true
        self.myLblAmount.textAlignment = isRTLenabled == true ? .left : .right
        myViewNavigation.roundBottomCorners(radius: 13)
        myViewNavigationBG.backgroundColor = ConfigTheme.themeColor
        myViewNavigation.backgroundColor = ConfigTheme.themeColor
        self.myViewLocationUser.isHidden = true
        self.myTblHome.register(UINib(nibName: "HomeTopPicksTblCell", bundle: nil), forCellReuseIdentifier: "topPicksTblCell")
        self.myTblHome.register(UINib(nibName: "HomeBusinessTblCell", bundle: nil), forCellReuseIdentifier: "businessTblCell")
        self.myTblHome.register(UINib(nibName: "HomeBrandsTblCell", bundle: nil), forCellReuseIdentifier: "brandsTblCell")
        self.myTblHome.register(UINib(nibName: "HomeRestaurantTblCell", bundle: nil), forCellReuseIdentifier: "restaurantCell")
        self.myTblHome.register(UINib(nibName: "HomeBannerTblCell", bundle: nil), forCellReuseIdentifier: "bannerTblCell")
        self.myTblHome.register(UINib(nibName: "LoginTblCell", bundle: nil), forCellReuseIdentifier: "loginCell")
        self.myTblHome.register(UINib(nibName: "BannerTblCell", bundle: nil), forCellReuseIdentifier: "bannerCell")
        self.myTblMenuList.register(UINib(nibName: "MenuTblCell", bundle: nil), forCellReuseIdentifier: "menuProfileCell")
        self.myTblMenuList.register(UINib(nibName: "MenuListTblCell", bundle: nil), forCellReuseIdentifier: "menuListCell")
        self.myTblLanguage.register(UINib(nibName: "MenuListTblCell", bundle: nil), forCellReuseIdentifier: "menuListCell")
        self.myTblLocationUser.register(UINib(nibName: "LocationTblCell", bundle: nil), forCellReuseIdentifier: "locationCell")
        
        self.myBtnSearch.addTarget(self, action: #selector(self.clickSearch(_:)), for: .touchUpInside)
        self.myViewLanguage.isHidden = true
        if #available(iOS 13.0, *) {
//            let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
//            let statusbarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: statusBarHeight))
//            statusbarView.backgroundColor = ConfigTheme.themeColor
//            view.addSubview(statusbarView)
            
            let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
            let statusBarColor = ConfigTheme.themeColor
            statusBarView.backgroundColor = statusBarColor
            view.addSubview(statusBarView)
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = ConfigTheme.themeColor
        }
        if isUpdateTheApp {
            DispatchQueue.global().async {
                do {
                    try self.isUpdateAvailable { [weak self] (update, error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error checking for app update: \(error.localizedDescription)")
                            } else if update ?? false {
                                self?.popupUpdateDialogue()
                                isUpdateTheApp = false
                            }
                        }
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        print("Error checking for app update: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @discardableResult
    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
            
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                if let error = error { throw error }
                
                guard let data = data else { throw VersionError.invalidResponse }
                            
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                            
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let lastVersion = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                
                DispatchQueue.main.async {
                    print("version in app store", lastVersion, currentVersion)
                    self.appStoreVersion = lastVersion
                    completion(lastVersion > currentVersion, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    func popupUpdateDialogue(){
        
        let alertMessage = NSLocalizedString("A new version of Ordenes Application is available,Please update to version ", comment: "") + appStoreVersion;
        let alert = UIAlertController(title: NSLocalizedString("New Version Available", comment: ""), message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        
        let okBtn = UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: "itms-apps://itunes.apple.com/us/app/ordenes-ordering-app/id6448868399"),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        alert.addAction(okBtn)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func greetingLogic() -> String {
      let hour = Calendar.current.component(.hour, from: Date())
      let NEW_DAY = 0
      let NOON = 12
      let SUNSET = 16
      let MIDNIGHT = 24
      var greetingText = NSLocalizedString("Hey", comment: "") // Default greeting text
      switch hour {
      case NEW_DAY..<NOON:
          greetingText = NSLocalizedString("Hey, Good Morning", comment: "")
      case NOON..<SUNSET:
          greetingText = NSLocalizedString("Hey, Good Afternoon", comment: "")
      case SUNSET..<MIDNIGHT:
          greetingText = NSLocalizedString("Hey, Good Evening", comment: "")
      default:
          _ = NSLocalizedString("Hey", comment: "")
      }
      return greetingText
    }
    
    @objc func segmentValueChanged(sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex
        {
        case 0:
            orderType = "1"
            self.callGetHomeApi(isInitial: true, lat: globalLatitude, long: globalLongitude)
        case 1:
            orderType = "2"
            self.callGetHomeApi(isInitial: true, lat: globalLatitude, long: globalLongitude)
        default:
            break
        }
    }
    
    //MARK: API Calls
    func callGetCartCount(completionBlock: @escaping () -> ()){
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_CART_COUNT, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { [self] (response) in
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
                   let count = response["qty_count"] as! String
                   if count == "0"{
                       self.myTblHome.contentInset = UIEdgeInsets(top: 0,
                                                             left: 0,
                                                             bottom: 0,
                                                             right: 0)
                       self.myViewCart.isHidden = true
                   }else{
                       if let min = response["min_cart_value"], min as! String != ""{
                           self.myLblMinError.text = NSLocalizedString("Min. cart value is ", comment: "") + "\(response["min_cart_value"] ?? "")"
                           self.myLblViewBasket.frame.origin.y = 5
                       }else{
                           self.myLblMinError.text = ""
                           self.myLblViewBasket.frame.origin.y = 15
                       }
                       self.myLblCount.text = count
                       self.myLblAmount.text = response["total"] as? String
                       self.myTblHome.contentInset = UIEdgeInsets(top: 0,
                                                             left: 0,
                                                                  bottom: self.myViewCart.frame.height,
                                                             right: 0)
                       self.myViewCart.isHidden = false
                   }
               }else{
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
               }
               completionBlock()
            } catch {
                print(error.localizedDescription)
            }
            HELPER.hideLoadingAnimation()
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
            completionBlock()
        })
    }
    
    func callGetHomeApi(isInitial: Bool, lat: String, long: String) {
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LAT] = lat
        aDictParameters[K_PARAMS_LONG] = long
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_MODULES, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
           do {
               print(response)
               let aDictInfo = response as! [String : Any]
               if aDictInfo.count != 0 {
                   if aDictInfo["success"] != nil{
                       let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                       self.homeModelInfo = try! JSONDecoder().decode(HomeModel.self, from: jsonData)
                       self.brandModel = self.homeModelInfo?.brands ?? []
                       self.businessModel = self.homeModelInfo?.businessTypes ?? []
                       self.topPickModel = self.homeModelInfo?.topPick ?? []
                       self.bestOfferModel = self.homeModelInfo?.bestOffer ?? []
                       self.drinksModel = self.homeModelInfo?.drinks ?? []
                       self.bannerModel = self.homeModelInfo?.banners ?? []
                       self.myTblHome.dataSource = self
                       self.myTblHome.delegate = self
                       self.myTblHome.reloadData()
                       self.myViewLocationUser.isHidden = true
                   }else{
                       if aDictInfo["error"] != nil{
                           HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Delivery not available for this location", comment: ""))
                           if isInitial{
                               self.brandModel = []
                               self.businessModel = []
                               self.topPickModel = []
                               self.bestOfferModel = []
                               self.drinksModel = []
                               self.bannerModel = []
                               self.myTblHome.dataSource = self
                               self.myTblHome.delegate = self
                               self.myTblHome.reloadData()
                           }
                       }
                   }
               } else {
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_HOME_MODULE_EMPTY)
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
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_ADDRESS_LIST, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            
            do {
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    let modelData = try! JSONDecoder().decode(AddressModel.self, from: jsonData)
                    self.addressListModel = modelData.address ?? []
                    HELPER.hideLoadingAnimation()
                    if self.addressListModel.count == 0{
                        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: MapVc.storyboardID) as! MapVc
                        aViewController.modalPresentationStyle = .fullScreen
                        aViewController.pageType = "home"
                        self.present(aViewController, animated: true)
                    }else{
                        self.myTblLocationUser.dataSource = self
                        self.myTblLocationUser.delegate = self
                        self.myTblLocationUser.reloadData()
                        self.myViewLocationUser.isHidden = false
                        self.myTblLocationUser.delegate = self
                        self.myTblLocationUser.dataSource = self
                        self.myTblLocationUser.reloadData()
                        let height = (self.addressListModel.count * 65) + 140
                        if CGFloat(height) < self.myViewLocationUser.frame.height - 100{
                            self.myTblLocationUser.frame.size.height = CGFloat(height)
                        }else{
                            self.myTblLocationUser.frame.size.height = self.myViewLocationUser.frame.height - 100
                        }
                        self.myTblLocationUser.frame.origin.y = self.myViewLocationUser.frame.size.height - self.myTblLocationUser.frame.size.height
                    }
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }
                } else {
                    HELPER.hideLoadingAnimation()
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_ADDRESS_MODULE_EMPTY)
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func loginAction(){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: LoginVc.storyboardID) as! LoginVc
        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
    func logout(){
        var pushId = ""
        if let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId{
            pushId = userId
        }
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_PUSH_ID] = pushId
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_LOGOUT, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
               var success:[String:Any]!
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
                   let alertController = UIAlertController(title: "", message: NSLocalizedString("Do you want to continue for logout!", comment: ""), preferredStyle: .alert)
                   let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default) {
                       UIAlertAction in
                       
                       UserDefaults.standard.removeObject(forKey: UD_USER_DETAILS)
                       UserDefaults.standard.removeObject(forKey: UD_SECRET_KEY)
                       UserDefaults.standard.removeObject(forKey: UD_RECENT_SEARCHES)
                       self.myTblMenuList.reloadData()
                       guestStatus = "1"
                       self.callGetCartCount(completionBlock: {
                           self.callGetHomeApi(isInitial: true, lat: globalLatitude, long: globalLongitude)
                       })
                   }
                   let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel) {
                       UIAlertAction in
                   }
                   alertController.addAction(okAction)
                   alertController.addAction(cancelAction)
                   self.present(alertController, animated: true, completion: nil)
                   HELPER.hideLoadingAnimation()
               }else{
                   HELPER.hideLoadingAnimation()
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
                   let alertController = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: success["message"] as? String, preferredStyle: .alert)
                   let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default) {
                       UIAlertAction in
                       
                       
                   }
                   alertController.addAction(okAction)
                   self.present(alertController, animated: true, completion: nil)
                   UserDefaults.standard.removeObject(forKey: UD_USER_DETAILS)
                   UserDefaults.standard.removeObject(forKey: UD_SECRET_KEY)
                   UserDefaults.standard.removeObject(forKey: UD_RECENT_SEARCHES)
                   self.myTblMenuList.reloadData()
                   guestStatus = "1"
                   self.callGetCartCount(completionBlock: {
                       self.callGetHomeApi(isInitial: true, lat: globalLatitude, long: globalLongitude)
                   })
                   HELPER.hideLoadingAnimation()
               }
            } catch {
                HELPER.hideLoadingAnimation()
                print(error.localizedDescription)
            }
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    //MARK: Button action
    @IBAction func clickAddress(_ sender: UIButton){
        if isRTLenabled{
            UIView.animate(withDuration: 0.50, animations: { () -> Void in
                self.myViewMenuList.frame.origin.x = -(self.view.frame.size.width + 10)
            }, completion: { (bol) -> Void in
                self.myViewMenuList.isHidden = true
            })
        }else{
            UIView.animate(withDuration: 0.50, animations: { () -> Void in
                self.myViewMenuList.frame.origin.x = self.view.frame.size.width + 5
            }, completion: { (bol) -> Void in
                self.myViewMenuList.isHidden = true
            })
        }
        if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
            callGetAddressApi()
        }else{
            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: MapVc.storyboardID) as! MapVc
            aViewController.modalPresentationStyle = .fullScreen
            aViewController.pageType = "home"
            self.present(aViewController, animated: true)
        }
    }
    
    @IBAction func clickCancelAddress(_ sender: UIButton){
        self.myViewLocationUser.isHidden = true
    }
    
    @IBAction func clickSearch(_ sender: UIButton){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: RestaurantSearchVc.storyboardID) as! RestaurantSearchVc
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickMenu(_ sender: UIButton){
        if isRTLenabled{
            if self.myViewMenuList.isHidden{
                self.myTblMenuList.isHidden = false
                self.myViewMenuList.isHidden = false
                UIView.animate(withDuration: 0.50, animations: { () -> Void in
                    self.myViewMenuList.frame.origin.x = 0
                }, completion: { (bol) -> Void in
                    
                })
            }else{
                UIView.animate(withDuration: 0.50, animations: { () -> Void in
                    self.myViewMenuList.frame.origin.x = -(self.view.frame.size.width - 10)
                }, completion: { (bol) -> Void in
                    self.myViewMenuList.isHidden = true
                })
            }
        }else{
            if self.myViewMenuList.isHidden{
                self.myTblMenuList.isHidden = false
                self.myViewMenuList.isHidden = false
                UIView.animate(withDuration: 0.50, animations: { () -> Void in
                    self.myViewMenuList.frame.origin.x = 0
                }, completion: { (bol) -> Void in
                    
                })
            }else{
                UIView.animate(withDuration: 0.50, animations: { () -> Void in
                    self.myViewMenuList.frame.origin.x = self.view.frame.size.width + 5
                }, completion: { (bol) -> Void in
                    self.myViewMenuList.isHidden = true
                })
            }
        }
    }
    
    @IBAction func clickMenuClose(_ sender: UIButton){
        if isRTLenabled{
            UIView.animate(withDuration: 0.50, animations: { () -> Void in
                self.myViewMenuList.frame.origin.x = -(self.view.frame.size.width + 10)
            }, completion: { (bol) -> Void in
                self.myViewMenuList.isHidden = true
            })
        }else{
            UIView.animate(withDuration: 0.50, animations: { () -> Void in
                self.myViewMenuList.frame.origin.x = self.view.frame.size.width + 5
            }, completion: { (bol) -> Void in
                self.myViewMenuList.isHidden = true
            })
        }
    }
    
    @IBAction func clickViewBasket(_ sender: UIButton){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CartVc.storyboardID) as! CartVc
        navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @objc func navigationToRestaurant(_ notification: Notification) {
        let data = notification.object as! Banner
        if data.vendorTypeId == "2"{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
            aViewController.vendorId = data.vendorID ?? "0"
            self.navigationController?.pushViewController(aViewController, animated: true)
        }else{
            let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
            aViewController.vendorId = data.vendorID ?? "0"
            self.navigationController?.pushViewController(aViewController, animated: true)
        }
    }
    
    @objc func clickViewAccount(_ sender: UIButton) {
        if(UserDefaults.standard.object(forKey: UD_USER_DETAILS) == nil) {
            self.loginAction()
        }else {
            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: ProfileVc.storyboardID) as! ProfileVc
            self.navigationController?.pushViewController(aViewController, animated: true)
        }
    }
    
    @objc func clickContinue(_ sender: UIButton){
        if self.vendorType == "2"{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
            aViewController.vendorId = self.vendorId
            self.navigationController?.pushViewController(aViewController, animated: true)
            self.statusView.removeFromSuperview()
        }else{
            let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
            aViewController.vendorId = self.vendorId
            self.navigationController?.pushViewController(aViewController, animated: true)
            self.statusView.removeFromSuperview()
        }
    }
    
    //MARK: Language
    @IBAction func clickChangeLang(_ sender: Any)
    {
        self.myViewLanguage.isHidden = true
        self.myViewMenuList.isHidden = true
        languageID = self.selectedLanguage
        if languageID == "1"{
            isRTLenabled = false
        }else{
            isRTLenabled = true
        }
        UserDefaults.standard.set(languageID, forKey: "language_id")
        let selectedLanguage:Languages = Int(languageID) == 1 ? .en : .ar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        LanguageManger.shared.setLanguage(language: selectedLanguage)
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
        let navi = UINavigationController.init(rootViewController: aViewController)
        //self.changeRootViewController(aViewController: navi)
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate!.changeRootViewController(aViewController: navi)
    }
    
    @IBAction func clickCancelLanguage(_ sender: Any)
    {
        self.myViewMenuList.isHidden = true
        self.myViewLanguage.isHidden = true
    }
}

extension HomeVc : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.myTblMenuList {
            let headerView: MenuTblCell? = tableView.dequeueReusableCell(withIdentifier: "menuProfileCell") as! MenuTblCell?
            headerView?.myImgUser.layer.cornerRadius = ((headerView?.myImgUser.frame.size.height)!)/2
            headerView?.myBtnViewAccount.addTarget(self, action: #selector(self.clickViewAccount(_:)), for: UIControl.Event.touchUpInside)
            headerView?.myLblViewAccount.textColor = ConfigTheme.themeColor
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                print("App Version: \(version)")
                print("Build Number: \(build)")
                headerView?.myLblAppVersion.isHidden = false
                headerView?.myLblAppVersion.text = ("App Version - \(version)")
            }
            
            if(UserDefaults.standard.object(forKey: UD_USER_DETAILS) == nil) {
                headerView?.myLblUser.text = NSLocalizedString("Login to", comment: "")
                headerView?.myImgUser.image = UIImage(named: "ic_user_profile")
            }else{
                let data = UserDefaults.standard.value(forKey: UD_USER_DETAILS) as! Data
                do {
                    if let userDic = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSDictionary {
                        print(userDic)
                        headerView?.myLblUser.text = "\(userDic.value(forKey: "firstname") as! String)"
                        
                        if let _ =  userDic.value(forKey: "image") as? NSNull {
                            headerView?.myImgUser.image = UIImage (named: "profile")
                        }else {
                            let imageUrl =  userDic.value(forKey: "image") as! String
                            let trimmedUrl = imageUrl.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20")
                            
                            if imageUrl.contains("placeholder") || imageUrl == "" {
                                headerView?.myImgUser.image = UIImage(named: "ic_user_profile")
                            }else {
                                var activityLoader = UIActivityIndicatorView()
                                activityLoader = UIActivityIndicatorView(style: .medium)
                                activityLoader.center = (headerView?.myImgUser.center)!
                                activityLoader.startAnimating()
                                headerView?.myImgUser.addSubview(activityLoader)
                                
                                headerView?.myImgUser.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                                    
                                    if image != nil {
                                        activityLoader.stopAnimating()
                                    }else {
                                        activityLoader.stopAnimating()
                                        headerView?.myImgUser.image = UIImage(named: "ic_user_profile")
                                    }
                                })
                            }
                        }
                    }
                }catch {
                    print("Couldn't read file.")
                }
            }
            return headerView
        }else if tableView == self.myTblLocationUser{
            let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
            let lblHeader = UILabel(frame: CGRect(x: 10, y: 10, width: header.frame.size.width - 20, height: 40))
            lblHeader.text = NSLocalizedString("Choose delivery location", comment: "")
            lblHeader.font = UIFont(name: "Poppins-Bold", size: 16)
            header.addSubview(lblHeader)
            header.backgroundColor = .white
            return header
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.myTblMenuList {
            if section == 0{
                return 65
            }else {
                return 0
            }
        }else if tableView == self.myTblLocationUser{
            return 60
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == self.myTblLocationUser{
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as! LocationTblCell
            cell.lblAddress1.text = NSLocalizedString("Deliver to different location", comment: "")
            cell.lblAddress2.text = NSLocalizedString("Choose location on the map", comment: "")
            cell.btnAddressSelection.addTarget(self, action: #selector(clickDifferentLocation(_:)), for: .touchUpInside)
            cell.imgLocation.image = UIImage(named: "ic_location_near")
            cell.imgLocation.image = cell.imgLocation.image!.withRenderingMode(.alwaysTemplate)
            cell.imgLocation.tintColor = ConfigTheme.themeColor
            return cell
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == self.myTblLocationUser{
            return 80
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.myTblHome {
            return 8
        }else if tableView == self.myTblLocationUser{
            return self.addressListModel.count
        }else if tableView == self.myTblLanguage{
            return self.languageArr.count
        }else {
            if(UserDefaults.standard.object(forKey: UD_USER_DETAILS) == nil) {
                return self.menuList.count - 2
            }else {
                return self.menuList.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.myTblHome {
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "loginCell", for: indexPath) as! LocationTblCell
                cell.btnLogin.addTarget(self, action: #selector(clickLogin(_:)), for: .touchUpInside)
                cell.lblAddress1.text = homeModelInfo?.content?.loginTitle
                cell.lblAddress2.text = homeModelInfo?.content?.loginDescription
                cell.btnLogin.setTitle(NSLocalizedString("Login", comment: ""), for: .normal)
                return cell
            }else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "businessTblCell", for: indexPath) as! HomeBusinessTblCell
                cell.lblGreeting.text = greetingLogic()
                cell.lblPickupGreeting.text = self.homeModelInfo?.pickupDescription
                cell.lblDeliveryGreeting.text = self.homeModelInfo?.deliveryDescription
                cell.viewPickup.layer.borderWidth = 0.8
                cell.viewDelivery.layer.borderWidth = 0.8
                if orderType == "2"{
                    cell.viewDelivery.backgroundColor = .white
                    cell.viewPickup.backgroundColor = UIColor(named: "clr_light_orange")
                }else{
                    cell.viewPickup.backgroundColor = .white
                    cell.viewDelivery.backgroundColor = UIColor(named: "clr_light_orange")
                }
                cell.viewDelivery.layer.borderColor = ConfigTheme.customLightGray.cgColor
                cell.viewPickup.layer.borderColor = ConfigTheme.customLightGray.cgColor
                cell.collBusinessType.dataSource = self
                cell.collBusinessType.delegate = self
                cell.collBusinessType.tag = 1
                cell.collBusinessType.reloadData()
                cell.btnPickup.addTarget(self, action: #selector(clickPickup(_:)), for: .touchUpInside)
                cell.btnDelivey.addTarget(self, action: #selector(clickDelivery(_:)), for: .touchUpInside)
                return cell
            }else if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "bannerTblCell", for: indexPath) as! HomeBannerTblCell
                cell.bannerModel = self.bannerModel
                cell.pagerView.frame.size.width = (self.myTblHome.frame.size.width - 20)
                cell.pagerView.frame.size.height = (self.myTblHome.frame.size.width - 20)/1.78
                cell.pagerView.translatesAutoresizingMaskIntoConstraints = true
                cell.pagerControl.numberOfPages = self.bannerModel.count
                cell.pagerControl.currentPage = 0
                cell.pagerView.reloadData()
                return cell
            }else if indexPath.row == 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: "topPicksTblCell", for: indexPath) as! HomeTopPicksTblCell
                cell.collTopPicks.dataSource = self
                cell.collTopPicks.delegate = self
                cell.collTopPicks.tag = 2
                cell.collTopPicks.reloadData()
                return cell
            }else if indexPath.row == 4{
                let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! HomeRestaurantTblCell
                cell.lblTitle.text = NSLocalizedString("Best Offer%", comment: "")
                cell.collRestaurants.dataSource = self
                cell.collRestaurants.delegate = self
                cell.collRestaurants.tag = 3
                cell.collRestaurants.reloadData()
                return cell
            }else if indexPath.row == 5{
                let cell = tableView.dequeueReusableCell(withIdentifier: "brandsTblCell", for: indexPath) as! HomeBrandsTblCell
                cell.lblTitle.text = homeModelInfo?.content?.brand
                cell.collBrands.dataSource = self
                cell.collBrands.delegate = self
                cell.collBrands.tag = 4
                cell.collBrands.reloadData()
                return cell
            }else if indexPath.row == 6{
                let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! HomeRestaurantTblCell
                cell.lblTitle.text = homeModelInfo?.content?.drinks
                cell.collRestaurants.dataSource = self
                cell.collRestaurants.delegate = self
                cell.collRestaurants.tag = 5
                cell.collRestaurants.reloadData()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "homeSearchCell", for: indexPath) as! HomeBannerTblCell
                cell.btnSearch.addTarget(self, action: #selector(self.clickSearch(_:)), for: .touchUpInside)
                return cell
            }
        }else if tableView == self.myTblLocationUser{
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationTblCell
            let type = self.addressListModel[indexPath.row].addressType
            if type == "0"{
                cell.lblAddress1.text = NSLocalizedString("House", comment: "")
            }else if type == "1"{
                cell.lblAddress1.text = NSLocalizedString("Apartment no.", comment: "")
            }else{
                cell.lblAddress1.text = NSLocalizedString("Office", comment: "")
            }
            cell.lblAddress2.text = self.addressListModel[indexPath.row].area
            cell.btnAddressSelection.addTarget(self, action: #selector(clickSelectAddress(_:)), for: .touchUpInside)
            cell.btnAddressSelection.tag = indexPath.row
            cell.imgLocation.image = UIImage(named: "ic_location_filled")
            cell.imgLocation.image = cell.imgLocation.image!.withRenderingMode(.alwaysTemplate)
            cell.imgLocation.tintColor = ConfigTheme.themeColor
            return cell
        }else if tableView == self.myTblLanguage{
            let cell = self.myTblLanguage.dequeueReusableCell(withIdentifier: "menuListCell") as! MenuTblCell
            cell.myLblMenuTitle.text = self.languageArr[indexPath.row]["name"] as? String
            let id = self.languageArr[indexPath.row]["language_id"] as! String
            if selectedLanguage == id{
                HELPER.changeTintColor(imgVw: cell.myImgMenu, img: "ic_radio_check", color: ConfigTheme.themeColor)
            }else{
                HELPER.changeTintColor(imgVw: cell.myImgMenu, img: "ic_radio_uncheck", color: ConfigTheme.themeColor)
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuListCell", for: indexPath) as! MenuTblCell
            
            cell.myLblMenuTitle.text = self.menuList[indexPath.row]["title"] as? String
            
            cell.myImgMenu.image = UIImage(named: (self.menuList[indexPath.row]["image"] as? String)!)
            cell.myImgMenu.image = cell.myImgMenu.image!.withRenderingMode(.alwaysTemplate)
            cell.myImgMenu.tintColor = ConfigTheme.themeColor
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.myTblHome {
            if indexPath.row == 0{
                if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
                    return 0
                }else{
                    return view.frame.size.width / 1.77
                }
            }else if indexPath.row == 1{
                if businessModel.count != 0{
                    return 315
                }else{
                    return 150
                }
            }else if indexPath.row == 2{
                if bannerModel.count != 0{
                    return ((self.myTblHome.frame.size.width - 20) / 1.78) + 35
                }else{
                    return 0
                }
            }else if indexPath.row == 3{
                if topPickModel.count != 0{
                    return 270
                }else{
                    return 0
                }
            }else if indexPath.row == 4{
                if bestOfferModel.count != 0{
                    return 360
                }else{
                    return 0
                }
            }else if indexPath.row == 5{
                if brandModel.count != 0{
                    return 223
                }else{
                    return 0
                }
            }else if indexPath.row == 6{
                if drinksModel.count != 0{
                    return 330
                }else{
                    return 0
                }
            }else {
                return 92
            }
        }else if tableView == self.myTblLanguage{
            return 60
        } else {
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.myTblMenuList {
            if "\(String(describing: self.menuList[indexPath.row]["title"]))".contains(NSLocalizedString("My Addresses", comment: "")) {
                if(UserDefaults.standard.object(forKey: UD_USER_DETAILS) == nil) {
                    self.loginAction()
                }else {
                    let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: AddressVc.storyboardID) as! AddressVc
                    aViewController.modalPresentationStyle = .fullScreen
                    self.present(aViewController, animated: true, completion: nil)
                }
            }else if "\(String(describing: self.menuList[indexPath.row]["title"]))".contains(NSLocalizedString("My Favourites", comment: "")) {
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: FavouriteVc.storyboardID) as! FavouriteVc
                self.navigationController?.pushViewController(aViewController, animated: true)
            }else if "\(String(describing: self.menuList[indexPath.row]["title"]))".contains(NSLocalizedString("My Orders", comment: "")) {
                let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: OrderListVc.storyboardID) as! OrderListVc
                self.navigationController?.pushViewController(aViewController, animated: true)
            }else if "\(String(describing: self.menuList[indexPath.row]["title"]))".contains(NSLocalizedString("Change Password", comment: "")) {
                if(UserDefaults.standard.object(forKey: UD_USER_DETAILS) == nil) {
                    self.loginAction()
                }else {
                    let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CommonVc.storyboardID) as! CommonVc
                    aViewController.viewType = "ChangePassword"
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }
            }else if "\(String(describing: self.menuList[indexPath.row]["title"]))".contains(NSLocalizedString("Change Language", comment: "")) {
                self.selectedLanguage = languageID
                self.myTblLanguage.dataSource = self
                self.myTblLanguage.delegate = self
                self.myTblLanguage.reloadData()
                self.myTblLanguage.frame.size.height = CGFloat(self.languageArr.count * 60)
                self.myTblLanguage.translatesAutoresizingMaskIntoConstraints = true
                self.myBtnCancelLanugae.frame.origin.y = self.myTblLanguage.frame.origin.y + self.myTblLanguage.frame.size.height + 8
                self.myBtnChangeLanguage.frame.origin.y = self.myTblLanguage.frame.origin.y + self.myTblLanguage.frame.size.height + 8
                self.myViewLanguage.frame.size.height = self.myBtnChangeLanguage.frame.origin.y + self.myBtnChangeLanguage.frame.size.height + 8
                self.myViewLanguage.translatesAutoresizingMaskIntoConstraints = true
                self.myTblMenuList.isHidden = true
                self.myViewLanguage.isHidden = false
                
            }else if "\(String(describing: self.menuList[indexPath.row]["title"]))".contains(NSLocalizedString("Contact Us", comment: "")) {
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CommonVc.storyboardID) as! CommonVc
                aViewController.viewType = "Contact"
                self.navigationController?.pushViewController(aViewController, animated: true)
                
            }else if "\(String(describing: self.menuList[indexPath.row]["title"]))".contains(NSLocalizedString("About Us", comment: "")) {
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CommonVc.storyboardID) as! CommonVc
                aViewController.webViewId = "2"
                self.navigationController?.pushViewController(aViewController, animated: true)
            }else if "\(String(describing: self.menuList[indexPath.row]["title"]))".contains(NSLocalizedString("Privacy Policy", comment: "")) {
                
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CommonVc.storyboardID) as! CommonVc
                aViewController.webViewId = "1"
                self.navigationController?.pushViewController(aViewController, animated: true)
            }else if "\(String(describing: self.menuList[indexPath.row]["title"]))".contains(NSLocalizedString("Terms and Conditions", comment: "")) {
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CommonVc.storyboardID) as! CommonVc
                aViewController.webViewId = "4"
                self.navigationController?.pushViewController(aViewController, animated: true)
            }else if "\(String(describing: self.menuList[indexPath.row]["title"]))".contains(NSLocalizedString("Delete Account", comment: "")) {
                if(UserDefaults.standard.object(forKey: UD_USER_DETAILS) == nil) {
                    self.loginAction()
                }else {
                    let alertController = UIAlertController(title: NSLocalizedString("Information", comment: ""), message: NSLocalizedString("Are you sure, do you want to delete your account? If you delete your account, you will permanently lose your profile.", comment: ""), preferredStyle:.alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default)
                                              { action -> Void in
                        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CommonVc.storyboardID) as! CommonVc
                        aViewController.viewType = "deleteAccount"
                        self.navigationController?.pushViewController(aViewController, animated: true)
                    })
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: { (UIAlertAction) -> Void in
                        
                        alertController.dismiss(animated: true)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }else if "\(String(describing: self.menuList[indexPath.row]["title"]))".contains(NSLocalizedString("Logout", comment: "")){
                self.logout()
            }
         }else if tableView == self.myTblLanguage{
            selectedLanguage = self.languageArr[indexPath.row]["language_id"] as! String
            myTblLanguage.reloadData()
        } else {
            
        }
    }
    
    @objc func clickLogin(_ sender: UIButton){
        loginAction()
//        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: OrderConfirmVc.storyboardID) as! OrderConfirmVc
//        aViewController.modalPresentationStyle = .fullScreen
//        self.present(aViewController, animated: true)
    }
    
    @objc func clickDelivery(_ sender: UIButton){
        orderType = "1"
        self.callGetHomeApi(isInitial: true, lat: globalLatitude, long: globalLongitude)
    }
    
    @objc func clickPickup(_ sender: UIButton){
        orderType = "2"
        self.callGetHomeApi(isInitial: true, lat: globalLatitude, long: globalLongitude)
    }
    
    @objc func clickSelectAddress(_ sender: UIButton){
        globalLatitude = self.addressListModel[sender.tag].latitude ?? ""
        globalLongitude = self.addressListModel[sender.tag].longitude ?? ""
        let address = self.addressListModel[sender.tag].area ?? ""
        UserDefaults.standard.set(address, forKey: UD_SELECTED_ADDRESS)
        UserDefaults.standard.set("\(globalLatitude),\(globalLongitude)", forKey: UD_SELECTED_LAT_LONG)
        self.myLblDeliveryAddress.text = address
        callGetHomeApi(isInitial: false, lat: globalLatitude, long: globalLongitude)
    }
    
    @objc func clickDifferentLocation(_ sender: Any){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: MapVc.storyboardID) as! MapVc
        aViewController.modalPresentationStyle = .fullScreen
        aViewController.pageType = "home"
        self.present(aViewController, animated: true)
    }
}

extension HomeVc : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1{
            return businessModel.count
        }else if collectionView.tag == 2{
            return topPickModel.count
        }else if collectionView.tag == 3{
            return bestOfferModel.count
        }else if collectionView.tag == 4{
            return brandModel.count
        }else{
            return drinksModel.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "businessCollCell", for: indexPath) as! HomeBusinessCollCell
            cell.lblCategoryName.text = businessModel[indexPath.row].name
            let imageUrl = businessModel[indexPath.row].logo
            let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""

            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: .medium)
            activityLoader.center = cell.imgView.center
            activityLoader.startAnimating()
            cell.imgView.addSubview(activityLoader)

            cell.imgView.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                if image != nil
                {
                    activityLoader.stopAnimating()
                }
                else
                {
                    print("image not found")
                    cell.imgView.image = UIImage(named: "no_image")
                    activityLoader.stopAnimating()
                }
            })
            return cell
        }else if collectionView.tag == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topPicksCollCell", for: indexPath) as! HomeTopPicksCollCell
            cell.lblToppicksName.text = topPickModel[indexPath.row].name
            let imageUrl = topPickModel[indexPath.row].logo
            let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""

            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: .medium)
            activityLoader.center = cell.imgView.center
            activityLoader.startAnimating()
            cell.imgView.addSubview(activityLoader)

            cell.imgView.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                if image != nil
                {
                    activityLoader.stopAnimating()
                }
                else
                {
                    print("image not found")
                    cell.imgView.image = UIImage(named: "no_image")
                    activityLoader.stopAnimating()
                }
            })
            return cell
        }else if collectionView.tag == 3{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "restaurantCollCell", for: indexPath) as! HomeRestaurantCollCell
            cell.lblRestaurantName.text = bestOfferModel[indexPath.row].vendorName
            cell.lblRestaurantDesc.text = bestOfferModel[indexPath.row].cuisines
            cell.lblDeliveryTime.text = NSLocalizedString("within", comment: "") + " " + (bestOfferModel[indexPath.row].deliveryTime ?? "0") + " " +  NSLocalizedString("mins", comment: "")
            cell.lblDeliveryCharge.text = bestOfferModel[indexPath.row].deliveryFee
            if let offer = bestOfferModel[indexPath.row].offer, offer != ""{
                cell.lblOffers.text = offer
                cell.imgOfferAlert.isHidden = false
            }else{
                cell.lblOffers.text = ""
                cell.imgOfferAlert.isHidden = true
            }
            if orderType == "2"{
                if let rating = bestOfferModel[indexPath.row].rating?.rating, rating != ""{
                    cell.lblRating2.text = bestOfferModel[indexPath.row].rating?.vendorRatingName
                    let imageUrl = bestOfferModel[indexPath.row].rating?.vendorRatingImage
                    let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .medium)
                    activityLoader.center = cell.imgRating2.center
                    activityLoader.startAnimating()
                    cell.imgView.addSubview(activityLoader)

                    cell.imgRating2.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }
                        else
                        {
                            cell.imgRating2.image = UIImage(named: "no_image")
                            activityLoader.stopAnimating()
                        }
                    })
                    cell.imgRating2.isHidden = false
                    cell.lblRating2.isHidden = false
                }else{
                    cell.imgRating2.isHidden = true
                    cell.lblRating2.isHidden = true
                }
                cell.viewPickup.isHidden = false
            }else{
                cell.viewPickup.isHidden = true
                if let rating = bestOfferModel[indexPath.row].rating?.rating, rating != ""{
                    cell.lblRating.text = bestOfferModel[indexPath.row].rating?.vendorRatingName
                    let imageUrl = bestOfferModel[indexPath.row].rating?.vendorRatingImage
                    let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .medium)
                    activityLoader.center = cell.imgRating.center
                    activityLoader.startAnimating()
                    cell.imgView.addSubview(activityLoader)

                    cell.imgRating.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }
                        else
                        {
                            cell.imgRating.image = UIImage(named: "no_image")
                            activityLoader.stopAnimating()
                        }
                    })
                    cell.imgRating.isHidden = false
                    cell.lblRating.isHidden = false
                    cell.viewSeparater.isHidden = false
                }else{
                    cell.imgRating.isHidden = true
                    cell.lblRating.isHidden = true
                    cell.viewSeparater.isHidden = true
                }
            }
            let imageUrl = bestOfferModel[indexPath.row].banner
            let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: .medium)
            activityLoader.center = cell.imgView.center
            activityLoader.startAnimating()
            cell.imgView.addSubview(activityLoader)

            cell.imgView.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                if image != nil
                {
                    activityLoader.stopAnimating()
                }
                else
                {
                    print("image not found")
                    cell.imgView.image = UIImage(named: "no_image")
                    activityLoader.stopAnimating()
                }
            })
            let vendorStatus = bestOfferModel[indexPath.row].vendorStatus
            if vendorStatus == "1"{
                cell.viewBusy.isHidden = true
            }else{
                if vendorStatus == "0"{
                    cell.lblRestaurantStatus.text = NSLocalizedString("Closed", comment: "")
                }else if vendorStatus == "2"{
                    cell.lblRestaurantStatus.text = NSLocalizedString("Busy", comment: "")
                }
                cell.viewBusy.isHidden = false
            }
            return cell
        }else if collectionView.tag == 4{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "brandsCollCell", for: indexPath) as! HomeBrandsCollCell
            cell.lblBrandName.text = brandModel[indexPath.row].vendorName
            cell.lblDeliveryTime.text = (brandModel[indexPath.row].deliveryTime ?? "0") + NSLocalizedString("mins", comment: "")
            let imageUrl = brandModel[indexPath.row].logo
            let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: .medium)
            activityLoader.center = cell.imgView.center
            activityLoader.startAnimating()
            cell.imgView.addSubview(activityLoader)

            cell.imgView.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                if image != nil
                {
                    activityLoader.stopAnimating()
                }
                else
                {
                    print("image not found")
                    cell.imgView.image = UIImage(named: "no_image")
                    activityLoader.stopAnimating()
                }
            })
            let vendorStatus = brandModel[indexPath.row].vendorStatus
            if vendorStatus == "1"{
                cell.viewBusy.isHidden = true
            }else{
                if vendorStatus == "0"{
                    cell.lblRestaurantStatus.text = NSLocalizedString("Closed", comment: "")
                }else if vendorStatus == "2"{
                    cell.lblRestaurantStatus.text = NSLocalizedString("Busy", comment: "")
                }
                cell.viewBusy.isHidden = false
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "restaurantCollCell", for: indexPath) as! HomeRestaurantCollCell
            cell.lblRestaurantName.text = drinksModel[indexPath.row].vendorName
            cell.lblRestaurantDesc.text = drinksModel[indexPath.row].cuisines
            cell.lblDeliveryTime.text = NSLocalizedString("within", comment: "") + " " +  (drinksModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
            cell.lblDeliveryCharge.text = drinksModel[indexPath.row].deliveryFee
            if let offer = drinksModel[indexPath.row].offer, offer != ""{
                cell.lblOffers.text = offer
                cell.imgOfferAlert.isHidden = false
            }else{
                cell.lblOffers.text = ""
                cell.imgOfferAlert.isHidden = true
            }
            if orderType == "2"{
                if let rating = drinksModel[indexPath.row].rating?.rating, rating != ""{
                    cell.lblRating2.text = drinksModel[indexPath.row].rating?.vendorRatingName
                    let imageUrl = drinksModel[indexPath.row].rating?.vendorRatingImage
                    let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .medium)
                    activityLoader.center = cell.imgRating2.center
                    activityLoader.startAnimating()
                    cell.imgView.addSubview(activityLoader)

                    cell.imgRating2.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }
                        else
                        {
                            cell.imgRating2.image = UIImage(named: "no_image")
                            activityLoader.stopAnimating()
                        }
                    })
                    cell.imgRating2.isHidden = false
                    cell.lblRating2.isHidden = false
                }else{
                    cell.imgRating2.isHidden = true
                    cell.lblRating2.isHidden = true
                }
                cell.viewPickup.isHidden = false
            }else{
                cell.viewPickup.isHidden = true
                if let rating = drinksModel[indexPath.row].rating?.rating, rating != ""{
                    cell.lblRating.text = drinksModel[indexPath.row].rating?.vendorRatingName
                    let imageUrl = drinksModel[indexPath.row].rating?.vendorRatingImage
                    let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .medium)
                    activityLoader.center = cell.imgRating.center
                    activityLoader.startAnimating()
                    cell.imgView.addSubview(activityLoader)

                    cell.imgRating.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }
                        else
                        {
                            cell.imgRating.image = UIImage(named: "no_image")
                            activityLoader.stopAnimating()
                        }
                    })
                    cell.imgRating.isHidden = false
                    cell.lblRating.isHidden = false
                    cell.viewSeparater.isHidden = false
                }else{
                    cell.imgRating.isHidden = true
                    cell.lblRating.isHidden = true
                    cell.viewSeparater.isHidden = true
                }
            }
            let imageUrl = drinksModel[indexPath.row].banner
            let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: .medium)
            activityLoader.center = cell.imgView.center
            activityLoader.startAnimating()
            cell.imgView.addSubview(activityLoader)
            cell.imgView.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                if image != nil
                {
                    activityLoader.stopAnimating()
                }
                else
                {
                    print("image not found")
                    cell.imgView.image = UIImage(named: "no_image")
                    activityLoader.stopAnimating()
                }
            })
            let vendorStatus = drinksModel[indexPath.row].vendorStatus
            if vendorStatus == "1"{
                cell.viewBusy.isHidden = true
            }else{
                if vendorStatus == "0"{
                    cell.lblRestaurantStatus.text = NSLocalizedString("Closed", comment: "")
                }else if vendorStatus == "2"{
                    cell.lblRestaurantStatus.text = NSLocalizedString("Busy", comment: "")
                }
                cell.viewBusy.isHidden = false
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1{
            let typeId = self.businessModel[indexPath.row].typeID
            if typeId == "2"{
                let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryHomeVc.storyboardID) as! GroceryHomeVc
                self.navigationController?.pushViewController(aViewController, animated: true)
            }else{
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: AllRestaurantVc.storyboardID) as! AllRestaurantVc
                aViewController.businessType = self.businessModel[indexPath.row].typeID ?? ""
                self.navigationController?.pushViewController(aViewController, animated: true)
            }
        }else if collectionView.tag == 2{
            let topPickID = self.topPickModel[indexPath.row].id
            if topPickID == "1"{
                let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: OrderListVc.storyboardID) as! OrderListVc
                self.navigationController?.pushViewController(aViewController, animated: true)
            }else if topPickID == "2"{
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: AllRestaurantVc.storyboardID) as! AllRestaurantVc
                self.navigationController?.pushViewController(aViewController, animated: true)
            }else if topPickID == "3"{
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: AllRestaurantVc.storyboardID) as! AllRestaurantVc
                aViewController.isFreeDelivery = "1"
                self.navigationController?.pushViewController(aViewController, animated: true)
            }
        }else if collectionView.tag == 3{
            let vendorStatus = self.bestOfferModel[indexPath.row].vendorStatus
            if vendorStatus == "1"{
                if self.bestOfferModel[indexPath.row].vendorTypeID == "2"{
                    let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
                    aViewController.vendorId = self.bestOfferModel[indexPath.row].vendorID ?? ""
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }else{
                    let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
                    aViewController.vendorId = self.bestOfferModel[indexPath.row].vendorID ?? ""
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }
            }else{
                if let id = self.bestOfferModel[indexPath.row].vendorID{
                    self.vendorId = id
                    self.vendorType = self.bestOfferModel[indexPath.row].vendorTypeID ?? ""
                    self.statusView.myBtnContinue.addTarget(self, action: #selector(clickContinue(_:)), for: .touchUpInside)
                    if vendorStatus == "0"{
                        self.statusView.myLblHeader.text = NSLocalizedString("Vendor Closed", comment: "")
                        self.statusView.myLblMsg.text = NSLocalizedString("We're sorry, \(self.bestOfferModel[indexPath.row].vendorName ?? "Vendor") is currently closed and is not accepting orders at this time. You can continue adding items to your basket and order when restaurant is open.", comment: "")
                    }else if vendorStatus == "2"{
                        self.statusView.myLblHeader.text = NSLocalizedString("Vendor Busy", comment: "")
                        self.statusView.myLblMsg.text = NSLocalizedString("We're sorry, \(self.bestOfferModel[indexPath.row].vendorName ?? "Vendor") is currently busy and is not accepting orders at this time. You can continue adding items to your basket and order when restaurant is open.", comment: "")
                    }
                    self.statusView.frame = self.view.frame
                    self.view.addSubview(self.statusView)
                }
            }
        }else if collectionView.tag == 4{
            let vendorStatus = self.brandModel[indexPath.row].vendorStatus
            if vendorStatus == "1"{
                if self.brandModel[indexPath.row].vendorTypeID == "2"{
                    let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
                    aViewController.vendorId = self.brandModel[indexPath.row].vendorID ?? ""
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }else{
                    let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
                    aViewController.vendorId = self.brandModel[indexPath.row].vendorID ?? ""
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }
            }else{
                if let id = self.brandModel[indexPath.row].vendorID{
                    self.vendorId = id
                    self.vendorType = self.brandModel[indexPath.row].vendorTypeID ?? ""
                    self.statusView.myBtnContinue.addTarget(self, action: #selector(clickContinue(_:)), for: .touchUpInside)
                    if vendorStatus == "0"{
                        self.statusView.myLblHeader.text = NSLocalizedString("Vendor Closed", comment: "")
                        self.statusView.myLblMsg.text = NSLocalizedString("We're sorry, \(self.brandModel[indexPath.row].vendorName ?? "Vendor") is currently closed and is not accepting orders at this time. You can continue adding items to your basket and order when restaurant is open.", comment: "")
                    }else if vendorStatus == "2"{
                        self.statusView.myLblHeader.text = NSLocalizedString("Vendor Busy", comment: "")
                        self.statusView.myLblMsg.text = NSLocalizedString("We're sorry, \(self.brandModel[indexPath.row].vendorName ?? "Vendor") is currently busy and is not accepting orders at this time. You can continue adding items to your basket and order when restaurant is open.", comment: "")
                    }
                    self.statusView.frame = self.view.frame
                    self.view.addSubview(self.statusView)
                }
            }
        }else if collectionView.tag == 5{
            let vendorStatus = self.drinksModel[indexPath.row].vendorStatus
            if vendorStatus == "1"{
                if self.drinksModel[indexPath.row].vendorTypeID == "2"{
                    let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
                    aViewController.vendorId = self.drinksModel[indexPath.row].vendorID ?? ""
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }else{
                    let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
                    aViewController.vendorId = self.drinksModel[indexPath.row].vendorID ?? ""
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }
            }else{
                if let id = self.drinksModel[indexPath.row].vendorID{
                    self.vendorId = id
                    self.vendorType = self.drinksModel[indexPath.row].vendorTypeID ?? ""
                    self.statusView.myBtnContinue.addTarget(self, action: #selector(clickContinue(_:)), for: .touchUpInside)
                    if vendorStatus == "0"{
                        self.statusView.myLblHeader.text = NSLocalizedString("Vendor Closed", comment: "")
                        self.statusView.myLblMsg.text = NSLocalizedString("We're sorry, \(self.drinksModel[indexPath.row].vendorName ?? "Vendor") is currently closed and is not accepting orders at this time. You can continue adding items to your basket and order when restaurant is open.", comment: "")
                    }else if vendorStatus == "2"{
                        self.statusView.myLblHeader.text = NSLocalizedString("Vendor Busy", comment: "")
                        self.statusView.myLblMsg.text = NSLocalizedString("We're sorry, \(self.drinksModel[indexPath.row].vendorName ?? "Vendor") is currently busy and is not accepting orders at this time. You can continue adding items to your basket and order when restaurant is open.", comment: "")
                    }
                    self.statusView.frame = self.view.frame
                    self.view.addSubview(self.statusView)
                }
            }
        }
    }
}

extension HomeVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1{
            return CGSize(width: 154, height: 154)
        }else if collectionView.tag == 2{
            return CGSize(width: 150, height: 200)
        }else if collectionView.tag == 3{
            return CGSize(width: 350, height: 320)
        }else if collectionView.tag == 4{
            return CGSize(width: 130, height: 180)
        }else{
            return CGSize(width: 350, height: 285)
        }
    }
}

