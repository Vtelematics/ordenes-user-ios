
import UIKit
import MarqueeLabel

class AllRestaurantVc: UIViewController {
    
    @IBOutlet weak var myTblAllRestaurant: UITableView!
    @IBOutlet weak var myLblDeliveryTo: UILabel!
    @IBOutlet weak var myLblDeliveryAddress: MarqueeLabel!
    @IBOutlet weak var myViewDelivery: UIView!
    @IBOutlet weak var myViewCuisinesContainer: UIView!
    @IBOutlet weak var myViewCuisines: UIView!
    @IBOutlet weak var myTblCuisines: UITableView!
    @IBOutlet weak var myViewCuisineSearch: UIView!
    @IBOutlet weak var myViewSearchClear: UIView!
    @IBOutlet weak var myLblApply: UILabel!
    @IBOutlet weak var myLblCuisineCount: UILabel!
    @IBOutlet weak var myTxtSearchCuisine: UITextField!
    
    @IBOutlet weak var myLblCartCount: UILabel!
    @IBOutlet weak var myViewCart: UIView!
    @IBOutlet weak var myImgCart: UIImageView!
    @IBOutlet weak var myLblNavTitle: UILabel!
    @IBOutlet weak var myLblNotAvailable : UILabel!
    @IBOutlet weak var mySegmentController : UISegmentedControl!
    @IBOutlet weak var myImgError: UIImageView!
    @IBOutlet weak var myImgFav: UIImageView!
    @IBOutlet weak var myBtnLocation: UIButton!
    
    var allRestaurantModel = [AllRestroVendor]()
    var filterModel = [AllRestroFilter]()
    var bannerModel = [Banner]()
    var filter = [FilterListModel]()
    var cuisineArray : [[String: Any]] = []
    var filterList : [[String: Any]] = []
    var tempSelectedCuisines : [[String: Any]] = []
    var selectedCuisines : [[String: Any]] = []
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "20"
    var isFreeDelivery:String = "0"
    var businessType:String = ""
    var restaurantPageType:String = ""
    var NavTitle:String = ""
    var offerKey:String = ""
    var statusView = StatusView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.navigationToRestaurant(_:)), name: .restaurantNavigation, object: nil)
        if let latLong = UserDefaults.standard.value(forKey: UD_SELECTED_LAT_LONG), "\(latLong)" != ""{
            let array = (latLong as AnyObject).components(separatedBy: ",")
            let lat = array[0]
            let long = array[1]
            if lat != "" && long != ""
            {
                globalLatitude = lat
                globalLongitude = long
                if restaurantPageType == "" {
                    self.myBtnLocation.isUserInteractionEnabled = true
                    callGetCartCount(completionBlock: {
                        self.callGetAllRestaurantApi()
                    })
                }else {
                    self.myBtnLocation.isUserInteractionEnabled = false
                    callGetCartCount(completionBlock: {
                        self.callGetOfferRestaurantApi()
                    })
                }
                
                if let location = UserDefaults.standard.value(forKey: UD_SELECTED_ADDRESS), "\(location)" != ""{
                    self.myLblDeliveryAddress.text = location as? String
                }
            }else{
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: MapVc.storyboardID) as! MapVc
                self.present(aViewController, animated: true)
            }
        }else{
            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: MapVc.storyboardID) as! MapVc
            self.present(aViewController, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .restaurantNavigation, object: nil)
    }
    
    func setupUI() {
        
//        if #available(iOS 13.0, *) {
//            let titleTextAttributesSelect: [NSAttributedString.Key : Any] = [
//                NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 15.0) ?? "",
//                NSAttributedString.Key.foregroundColor: UIColor.white,
//            ]
//            let titleTextAttributesNormal: [NSAttributedString.Key : Any] = [
//                NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 15.0) ?? "",
//                NSAttributedString.Key.foregroundColor: UIColor.black,
//            ]
//            mySegmentController.setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
//            mySegmentController.setTitleTextAttributes(titleTextAttributesSelect, for: .selected)
//            self.mySegmentController.tintColor = ConfigTheme.posBtnColor
//            self.mySegmentController.selectedSegmentTintColor = ConfigTheme.posBtnColor
//        } else {
//            self.mySegmentController.tintColor = ConfigTheme.posBtnColor
//        }
//        self.mySegmentController.frame.size.height = 50
//        self.mySegmentController.translatesAutoresizingMaskIntoConstraints = true
//        self.mySegmentController.addTarget(self, action: #selector(segmentValueChanged(sender:)), for: .valueChanged)
        self.myTblAllRestaurant.tableFooterView = UIView()
        self.myTblCuisines.tableFooterView = UIView()
        if restaurantPageType == "" {
            self.myLblNavTitle.isHidden = true
        }else {
            self.myLblNavTitle.isHidden = false
            self.myLblNavTitle.text = NavTitle
        }
        self.myLblDeliveryTo.textColor = ConfigTheme.customLightGray
        setApplyBtn()
        self.myViewCuisinesContainer.isHidden = true
        self.myViewCuisines.roundTopCorners(radius: 15)
        self.myViewCuisineSearch.layer.cornerRadius = 8
        self.myViewCuisineSearch.layer.borderWidth = 0.5
        self.myTblAllRestaurant.tableFooterView = UIView()
        self.myTblCuisines.tableFooterView = UIView()
        self.myTblAllRestaurant.register(UINib(nibName: "AllRestaurantTblCell", bundle: nil), forCellReuseIdentifier: "allRestaurantCell")
        self.myTblAllRestaurant.register(UINib(nibName: "collectionViewTblCell", bundle: nil), forCellReuseIdentifier: "collTblCell")
        self.myTblAllRestaurant.register(UINib(nibName: "HomeBannerTblCell", bundle: nil), forCellReuseIdentifier: "bannerTblCell")
        self.myTblCuisines.register(UINib(nibName: "multiSelectionCell", bundle: nil), forCellReuseIdentifier: "selectionCell")
        let cartImage = UIImage(named: "ic_cart")
        self.myImgCart.image = cartImage?.maskWithColor(color: ConfigTheme.themeColor)
        self.myTxtSearchCuisine.textAlignment = isRTLenabled == true ? .right : .left
        self.myImgError.image = self.myImgError.image!.withRenderingMode(.alwaysTemplate)
        self.myImgError.tintColor = ConfigTheme.themeColor
        self.myImgFav.image = UIImage(named: "ic_fav_fill_48")
        self.myImgFav.image = self.myImgFav.image!.withRenderingMode(.alwaysTemplate)
        self.myImgFav.tintColor = ConfigTheme.themeColor
    }
        
    func setApplyBtn(){
        if self.tempSelectedCuisines.count != 0{
            self.myLblApply.frame.origin.y = 8
            self.myLblCuisineCount.isHidden = false
            self.myLblCuisineCount.text = "\(self.tempSelectedCuisines.count) \(NSLocalizedString("cuisines selected", comment: ""))"
        }else{
            self.myLblApply.frame.origin.y = 15
            self.myLblCuisineCount.isHidden = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView == myTblAllRestaurant{
            let offset: CGPoint = scrollView.contentOffset
            let bounds: CGRect = scrollView.bounds
            let size: CGSize = scrollView.contentSize
            let inset: UIEdgeInsets = scrollView.contentInset
            let y = Float(offset.y + bounds.size.height - inset.bottom)
            let h = Float(size.height)
            let reload_distance: Float = 10
            if y > h + reload_distance
            {
                if isScrolledOnce == false
                {
                    if restaurantPageType == "" {
                        self.pullToRefresh()
                    }else {
                        self.pullToRefreshFiltersVendor()
                    }
                }
            }
        }
    }
    
    func checkAvailablity(_ id:Int) -> Bool
    {
        var isAlreadyHave:Bool = false
        if tempSelectedCuisines.count != 0
        {
            for tempDic in tempSelectedCuisines
            {
                let tempCart:[String: Any] = tempDic
                
                let tempId = tempCart["cuisine_id"] as! Int
                
                if tempId == id
                {
                    isAlreadyHave = true
                }
            }
        }
        return isAlreadyHave
    }
    
    @objc func segmentValueChanged(sender: UISegmentedControl)
    {
        if #available(iOS 13.0, *) {
            
            let titleTextAttributesSelect: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 15.0) ?? "",
                NSAttributedString.Key.foregroundColor: UIColor.white,
            ]
            
            let titleTextAttributesNormal: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 15.0) ?? "",
                NSAttributedString.Key.foregroundColor: UIColor.black,
            ]
            mySegmentController.setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
            mySegmentController.setTitleTextAttributes(titleTextAttributesSelect, for: .selected)
            self.mySegmentController.tintColor = ConfigTheme.posBtnColor
            self.mySegmentController.selectedSegmentTintColor = ConfigTheme.posBtnColor
        }else {
            self.mySegmentController.tintColor = ConfigTheme.posBtnColor
        }
        switch sender.selectedSegmentIndex
        {
        case 0:
            orderType = "1"
            if restaurantPageType == "" {
                self.callGetAllRestaurantApi()
            }else {
                self.callGetOfferRestaurantApi()
            }
        case 1:
            orderType = "2"
            if restaurantPageType == "" {
                self.callGetAllRestaurantApi()
            }else {
                self.callGetOfferRestaurantApi()
            }
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
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_CART_COUNT, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { [self] (response) in
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
                   let count = response["qty_count"] as! String
                   if count == "0"{
                       
                       self.myViewCart.isHidden = true
                   }else{
                       self.myLblCartCount.text = count
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
    
    func callGetAllRestaurantApi() {
        var cuisines = [String]()
        for obj in selectedCuisines{
            let id = "\(obj["cuisine_id"] ?? "")"
            cuisines.append(id)
        }
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        page = 1
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_PAGE] = page
        aDictParameters[K_PARAMS_LIMIT] = limit
        aDictParameters[K_PARAMS_CUISINE] = cuisines
        aDictParameters[K_PARAMS_FREE_DELIVERY] = isFreeDelivery
        aDictParameters[K_PARAMS_BUSINESS_TYPE] = businessType
        aDictParameters[K_PARAMS_SIDE_FILTER] = filterList
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_VENDOR_LISTING, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
                let aDictInfo = response as! [String : Any]
               print(aDictInfo)
                if aDictInfo.count != 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    let modelData = try! JSONDecoder().decode(AllRestraurantModel.self, from: jsonData)
                    self.allRestaurantModel = modelData.vendor ?? []
                    self.filterModel = modelData.filter ?? []
                    self.bannerModel = modelData.banner ?? []
                    let total = modelData.total
                    self.pageCount = Double(Int(total ?? "0")!/Int(self.limit)!)
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }
                } else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_RESTAURANT)
                }
                self.myTblAllRestaurant.dataSource = self
                self.myTblAllRestaurant.delegate = self
                self.myTblAllRestaurant.reloadData()
                
            } catch {
                print(error.localizedDescription)
            }
            HELPER.hideLoadingAnimation()
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func pullToRefresh()
    {
        if (self.isScrolledOnce == true)
        {
            return
        }
        self.isScrolledOnce = true
        if page <= Int(self.pageCount)
        {
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: NSLocalizedString("Please wait..", comment: ""))
            page += 1
            let dayId = Date().dayNumberOfWeek()
            var aDictParameters = [String : Any]()
            aDictParameters[K_PARAMS_LAT] = globalLatitude
            aDictParameters[K_PARAMS_LONG] = globalLongitude
            aDictParameters[K_PARAMS_DAY_ID] = dayId
            aDictParameters[K_PARAMS_PAGE] = page
            aDictParameters[K_PARAMS_LIMIT] = limit
            aDictParameters[K_PARAMS_CUISINE] = selectedCuisines
            aDictParameters[K_PARAMS_FREE_DELIVERY] = isFreeDelivery
            aDictParameters[K_PARAMS_BUSINESS_TYPE] = businessType
            aDictParameters[K_PARAMS_SIDE_FILTER] = filterList
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_VENDOR_LISTING, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
               do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(AllRestraurantModel.self, from: jsonData)
                        self.allRestaurantModel.append(contentsOf: modelData.vendor ?? [])
                        self.myTblAllRestaurant.reloadData()
                        if aDictInfo["error"] != nil{
                            let error = aDictInfo["error"] as! [String: String]
                            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                HELPER.hideLoadingAnimation()
                self.isScrolledOnce = false
            }, failureBlock: { (errorResponse) in
                HELPER.hideLoadingAnimation()
                self.isScrolledOnce = false
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
            })
        }
        else
        {
            self.isScrolledOnce = false
        }
    }
    
    func callGetAllCuisinesApi(searchKey : String, isInitial : Bool) {
        self.cuisineArray = []
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_SEARCH] = searchKey
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_CUISINES, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    self.cuisineArray = aDictInfo["cuisine"] as! [[String : Any]]
                } else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_RESTAURANT)
                }
               if isInitial{
                   if self.cuisineArray.count != 0{
                       self.myViewCuisinesContainer.isHidden = false
                   }else{
                       self.myViewCuisinesContainer.isHidden = true
                   }
               }
               self.myTblCuisines.dataSource = self
               self.myTblCuisines.delegate = self
               self.myTblCuisines.reloadData()
               if aDictInfo["error"] != nil{
                   let error = aDictInfo["error"] as! [String: String]
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
               }
            } catch {
                print(error.localizedDescription)
            }
            HELPER.hideLoadingAnimation()
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callGetOfferRestaurantApi() {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        var cuisines = [String]()
        for obj in selectedCuisines{
            let id = "\(obj["cuisine_id"] ?? "")"
            cuisines.append(id)
        }
        page = 1
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_CUISINE] = cuisines
        aDictParameters[K_PARAMS_PAGE] = page
        aDictParameters[K_PARAMS_LIMIT] = limit
        aDictParameters[K_PARAMS_FILTER] = offerKey
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_VENDOR_OFFER, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    print(aDictInfo)
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    let modelData = try! JSONDecoder().decode(AllRestraurantModel.self, from: jsonData)
                    self.allRestaurantModel = modelData.vendor ?? []
                    self.myLblNotAvailable.isHidden = self.allRestaurantModel.count != 0 ? true : false
                    self.myImgError.isHidden = self.allRestaurantModel.count != 0 ? true : false
                    self.filterModel = modelData.filter ?? []
                    self.bannerModel = modelData.banner ?? []
                    let total = modelData.total
                    self.pageCount = Double(Int(total ?? "0")!/Int(self.limit)!)
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }
                } else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_RESTAURANT)
                }
                self.myTblAllRestaurant.dataSource = self
                self.myTblAllRestaurant.delegate = self
                self.myTblAllRestaurant.reloadData()
                
            } catch {
                print(error.localizedDescription)
            }
            HELPER.hideLoadingAnimation()
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func pullToRefreshFiltersVendor()
    {
        if (self.isScrolledOnce == true)
        {
            return
        }
        self.isScrolledOnce = true
        if page <= Int(self.pageCount)
        {
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: NSLocalizedString("Please wait..", comment: ""))
            var cuisines = [String]()
            for obj in selectedCuisines{
                let id = "\(obj["cuisine_id"] ?? "")"
                cuisines.append(id)
            }
            page += 1
            let dayId = Date().dayNumberOfWeek()
            var aDictParameters = [String : Any]()
            aDictParameters[K_PARAMS_LAT] = globalLatitude
            aDictParameters[K_PARAMS_LONG] = globalLongitude
            aDictParameters[K_PARAMS_DAY_ID] = dayId
            aDictParameters[K_PARAMS_CUISINE] = cuisines
            aDictParameters[K_PARAMS_PAGE] = page
            aDictParameters[K_PARAMS_LIMIT] = limit
            aDictParameters[K_PARAMS_FILTER] = offerKey
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
            print(aDictParameters)
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_VENDOR_OFFER, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
               do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(AllRestraurantModel.self, from: jsonData)
                        self.allRestaurantModel.append(contentsOf: modelData.vendor ?? [])
                        self.myLblNotAvailable.isHidden = self.allRestaurantModel.count != 0 ? true : false
                        self.myImgError.isHidden = self.allRestaurantModel.count != 0 ? true : false
                        self.myTblAllRestaurant.reloadData()
                        if aDictInfo["error"] != nil{
                            let error = aDictInfo["error"] as! [String: String]
                            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                self.isScrolledOnce = false
                HELPER.hideLoadingAnimation()
            }, failureBlock: { (errorResponse) in
                HELPER.hideLoadingAnimation()
                self.isScrolledOnce = false
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
            })
        }
        else
        {
            HELPER.hideLoadingAnimation()
            self.isScrolledOnce = false
        }
    }
    
    func checkVendorInWishList(vendorId : String) -> Bool
    {
        var isAleadyHave:Bool = false
        if UserDefaults.standard.object(forKey: UD_WISHLIST) != nil
        {
            let data = UserDefaults.standard.object(forKey: UD_WISHLIST) as! Data
            var favAry = [String]()
            do {
                if let arry = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] {
                    favAry = arry
                }
            } catch {
                print("Couldn't read file.")
            }
            for i in 0..<favAry.count
            {
                let str1 = favAry[i]
                if str1 == vendorId
                {
                    isAleadyHave = true
                }
            }
        }
        return isAleadyHave
    }
    
    //MARK: Button Action
    @IBAction func clickAddress(_ sender: UIButton){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: MapVc.storyboardID) as! MapVc
        aViewController.modalPresentationStyle = .fullScreen
        aViewController.pageType = "all_restaurant"
        self.present(aViewController, animated: true)
    }
    
    @IBAction func clickViewBasket(_ sender: UIButton){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CartVc.storyboardID) as! CartVc
        navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickFilter(_ sender : Any){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: FilterVc.storyboardID) as! FilterVc
        aViewController.completion = { [weak self] FilterData in
            guard self != nil else {
                return
            }
            self?.filterList = FilterData
            if self?.restaurantPageType == "" {
                self?.callGetAllRestaurantApi()
            }else{
                self?.callGetOfferRestaurantApi()
            }
        }
        aViewController.completionTemp = { [weak self] FilterData in
            guard self != nil else {
                return
            }
            self?.filter = FilterData
        }
        aViewController.filter = filter
        aViewController.selectedFilters = self.filterList
        aViewController.view.backgroundColor = UIColor.clear
        aViewController.modalPresentationStyle = .popover
        present(aViewController, animated: true)
    }
    
    @IBAction func clickCuisine(_ sender : Any){
        self.myTxtSearchCuisine.text = ""
        self.tempSelectedCuisines = []
        self.tempSelectedCuisines.append(contentsOf: selectedCuisines)
        setApplyBtn()
        callGetAllCuisinesApi(searchKey: "", isInitial: true)
    }
    
    @IBAction func clickCloseCuisine(_ sender : Any){
        self.view.endEditing(true)
        self.myViewCuisinesContainer.isHidden = true
    }
    
    @IBAction func clickApplyCuisine(_ sender : Any){
        self.view.endEditing(true)
        self.myViewCuisinesContainer.isHidden = true
        self.selectedCuisines = self.tempSelectedCuisines
        if restaurantPageType == "" {
            self.callGetAllRestaurantApi()
        }else{
            self.callGetOfferRestaurantApi()
        }
    }
    
    @IBAction func clickClearCuisine(_ sender : Any){
        self.tempSelectedCuisines = []
        setApplyBtn()
        self.myTblCuisines.reloadData()
    }
    
    @IBAction func clickClearSearch(_ sender : Any){
        self.myTxtSearchCuisine.text = ""
        self.myViewSearchClear.isHidden = true
        callGetAllCuisinesApi(searchKey: "", isInitial: false)
    }
    
    @IBAction func clickSearchRestaurant(_ sender : Any){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: RestaurantSearchVc.storyboardID) as! RestaurantSearchVc
        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickBack(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickMyFavourite(_ sender : Any){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: FavouriteVc.storyboardID) as! FavouriteVc
        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @objc func clickVendor(_ sender: UIButton){
        let vendorStatus = self.allRestaurantModel[sender.tag].vendorStatus
        if vendorStatus == "1"{
            if self.allRestaurantModel[sender.tag].vendorTypeID == "2"{
                let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
                aViewController.vendorId = self.allRestaurantModel[sender.tag].vendorID ?? "0"
                self.navigationController?.pushViewController(aViewController, animated: true)
            }else{
                let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
                aViewController.vendorId = self.allRestaurantModel[sender.tag].vendorID ?? "0"
                self.navigationController?.pushViewController(aViewController, animated: true)
            }
        }else{
            if self.allRestaurantModel[sender.tag].vendorID != nil{
                self.statusView.myBtnContinue.tag = sender.tag
                self.statusView.myBtnContinue.addTarget(self, action: #selector(clickContinue(_:)), for: .touchUpInside)
                if vendorStatus == "0"{
                    self.statusView.myLblHeader.text = NSLocalizedString("Vendor Closed", comment: "")
                    self.statusView.myLblMsg.text = NSLocalizedString("We're sorry, \(self.allRestaurantModel[sender.tag].name ?? "Vendor") is currently closed and is not accepting orders at this time. You can continue adding items to your basket and order when restaurant is open.", comment: "")
                }else if vendorStatus == "2"{
                    self.statusView.myLblHeader.text = NSLocalizedString("Vendor Busy", comment: "")
                    self.statusView.myLblMsg.text = NSLocalizedString("We're sorry, \(self.allRestaurantModel[sender.tag].name ?? "Vendor") is currently busy and is not accepting orders at this time. You can continue adding items to your basket and order when restaurant is open.", comment: "")
                }
                self.statusView.frame = self.view.frame
                self.view.addSubview(self.statusView)
            }
        }
    }
    
    @objc func clickContinue(_ sender: UIButton){
        if self.allRestaurantModel[sender.tag].vendorTypeID == "2"{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
            aViewController.vendorId = self.allRestaurantModel[sender.tag].vendorID ?? "0"
            self.navigationController?.pushViewController(aViewController, animated: true)
            self.statusView.removeFromSuperview()
        }else{
            let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
            aViewController.vendorId = self.allRestaurantModel[sender.tag].vendorID ?? "0"
            self.navigationController?.pushViewController(aViewController, animated: true)
            self.statusView.removeFromSuperview()
        }
    }
    
    @objc func clickFav(_ sender: UIButton){
        guard let vendorId = self.allRestaurantModel[sender.tag].vendorID else { return }
        if UserDefaults.standard.object(forKey: UD_WISHLIST) != nil
        {
            let data = UserDefaults.standard.object(forKey: UD_WISHLIST) as! Data
            var favAry = [String]()
            do {
                if let arry = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] {
                    favAry = arry
                }
            } catch {
                print("Couldn't read file.")
            }
            var isHave:Bool = false
            var tempArr = [String]()
            tempArr.append(contentsOf: favAry)
            for i in 0..<tempArr.count
            {
                let str1 = tempArr[i]
                if str1 == vendorId
                {
                    isHave = true
                    favAry.remove(at: i)
                    self.showFavToastView(message: NSLocalizedString("Removed from your favourites", comment: ""))
                    break
                }
            }
            if !isHave{
                favAry.append(vendorId)
                self.showFavToastView(message: NSLocalizedString("Added to your favourites", comment: ""))
            }
            do{
                let data = try NSKeyedArchiver.archivedData(withRootObject: favAry, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: UD_WISHLIST)
            } catch {
                print("Couldn't write file")
            }
        }else{
            var favAry = [String]()
            favAry.append(vendorId)
            print(favAry)
            do{
                let data = try NSKeyedArchiver.archivedData(withRootObject: favAry, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: UD_WISHLIST)
                self.showFavToastView(message: NSLocalizedString("Added to your favourites", comment: ""))
            } catch {
                print("Couldn't write file")
            }
        }
        if restaurantPageType == "" {
            let indexPath = IndexPath(row: sender.tag, section: 1)
            self.myTblAllRestaurant.reloadRows(at: [indexPath], with: .none)
        }else {
            let indexPath = IndexPath(row: sender.tag, section: 0)
            self.myTblAllRestaurant.reloadRows(at: [indexPath], with: .none)
        }
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
}

extension AllRestaurantVc : UITextFieldDelegate{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            print(txtAfterUpdate)
            self.myViewSearchClear.isHidden = txtAfterUpdate == "" ? true : false
            callGetAllCuisinesApi(searchKey: txtAfterUpdate, isInitial: false)
        }
      return true
    }
}

extension AllRestaurantVc: UITableViewDelegate, UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int
    {
        if tableView == myTblAllRestaurant{
            if restaurantPageType == "" {
                return 2
            }else {
                return 1
            }
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == myTblAllRestaurant{
            if section == 1{
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
                headerView.backgroundColor = .white
                let headerLable = UILabel(frame: CGRect(x: 8, y: 15, width: tableView.frame.size.width - 16, height: 20))
                headerLable.font = UIFont(name: "Poppins-Bold", size: 17)
                headerLable.text = NSLocalizedString("All Vendors", comment: "")
                headerView.addSubview(headerLable)
                return headerView
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == myTblAllRestaurant{
            if section == 0{
                return 0
            }else{
                return self.allRestaurantModel.count != 0 ? 50 : 0
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == myTblAllRestaurant{
            if restaurantPageType == "" {
                if section == 0{
                    return 2
                }else{
                    return self.allRestaurantModel.count
                }
            }else {
                return self.allRestaurantModel.count
            }
        }else{
            return self.cuisineArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == myTblAllRestaurant{
            if restaurantPageType == "" {
                if indexPath.section == 0{
                    if indexPath.row == 0{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "collTblCell", for: indexPath) as! collectionViewTblCell
                        cell.defaultCollectionView.dataSource = self
                        cell.defaultCollectionView.delegate = self
                        cell.defaultCollectionView.tag = 1
                        cell.defaultCollectionView.reloadData()
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "bannerTblCell", for: indexPath) as! HomeBannerTblCell
                        cell.bannerModel = self.bannerModel
                        cell.pagerView.frame.size.width = (self.myTblAllRestaurant.frame.size.width - 20)
                        cell.pagerView.frame.size.height = (self.myTblAllRestaurant.frame.size.width - 20)/1.78
                        cell.pagerView.translatesAutoresizingMaskIntoConstraints = true
                        cell.pagerControl.numberOfPages = self.bannerModel.count
                        cell.pagerControl.currentPage = 0
                        cell.pagerView.reloadData()
                        return cell
                    }
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "allRestaurantCell", for: indexPath) as! AllRestaurantTblCell
                    cell.lblRestaurantName.text = self.allRestaurantModel[indexPath.row].name
                    cell.lblRestaurantDesc.text = self.allRestaurantModel[indexPath.row].cuisines
                    if let offer = self.allRestaurantModel[indexPath.row].offer, offer != ""{
                        cell.lblRestaurantOffer.text = offer
                        cell.imgOffer.isHidden = false
                        cell.lblLine.isHidden = false
                    }else{
                        cell.lblRestaurantOffer.text = ""
                        cell.imgOffer.isHidden = true
                        cell.lblLine.isHidden = true
                    }
                    let imageUrl = self.allRestaurantModel[indexPath.row].logo
                    let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
                    
                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .medium)
                    activityLoader.center = cell.imgRestaurant.center
                    activityLoader.startAnimating()
                    cell.imgRestaurant.addSubview(activityLoader)
                    
                    cell.imgRestaurant.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                        
                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }
                        else
                        {
                            print("image not found")
                            cell.imgRestaurant.image = UIImage(named: "no_image")
                            activityLoader.stopAnimating()
                        }
                    })
                    if let rating = allRestaurantModel[indexPath.row].rating?.rating, rating != "" && rating != "0"{
                        cell.viewRating.isHidden = false
                        cell.lblRestaurantRating.text = allRestaurantModel[indexPath.row].rating?.vendorRatingName
                        let imageUrl = allRestaurantModel[indexPath.row].rating?.vendorRatingImage
                        let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
                        var activityLoader = UIActivityIndicatorView()
                        activityLoader = UIActivityIndicatorView(style: .medium)
                        activityLoader.center = cell.imgRating.center
                        activityLoader.startAnimating()
                        cell.imgRating.addSubview(activityLoader)
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
                    }else{
                        cell.viewRating.isHidden = true
                    }
                    cell.lblMinOrder.text = NSLocalizedString("Minimum order - ", comment: "") + (self.allRestaurantModel[indexPath.row].minimumAmount ?? "0")
                    if orderType == "2"{
                        cell.lblRestaurantPreparingTime.text = (allRestaurantModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
                        cell.viewPreparing.isHidden = false
                    }else{
                        if allRestaurantModel[indexPath.row].freeDelivery == "1"{
                            cell.lblRestaurantDeliveryCharge.text = NSLocalizedString("Free delivery", comment: "")
                        }else{
                            cell.lblRestaurantDeliveryCharge.text = (self.allRestaurantModel[indexPath.row].deliveryCharge ?? "0")
                        }
                        cell.lblRestaurantDeliveryTime.text = (allRestaurantModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
                        cell.viewPreparing.isHidden = true
                    }
                    let vendorStatus = self.allRestaurantModel[indexPath.row].vendorStatus
                    if vendorStatus == "1"{
                        cell.viewBusy1.isHidden = true
                    }else{
                        if vendorStatus == "0"{
                            cell.lblRestaurantStatus1.text = NSLocalizedString("Closed", comment: "")
                        }else if vendorStatus == "2"{
                            cell.lblRestaurantStatus1.text = NSLocalizedString("Busy", comment: "")
                        }
                        cell.viewBusy1.isHidden = false
                    }
                    let vendorId = self.allRestaurantModel[indexPath.row].vendorID ?? "0"
                    let isFav = checkVendorInWishList(vendorId: vendorId)
                    if isFav{
                        cell.imgFav.image = UIImage(named: "ic_fav_fill")
                        cell.imgFav.image = cell.imgFav.image!.withRenderingMode(.alwaysTemplate)
                        cell.imgFav.tintColor = ConfigTheme.themeColor
                    }else{
                        cell.imgFav.image = UIImage(named: "ic_fav_outline")
                        cell.imgFav.image = cell.imgFav.image!.withRenderingMode(.alwaysTemplate)
                        cell.imgFav.tintColor = ConfigTheme.themeColor
                    }
                    cell.btnFav.isHidden = false
                    cell.btnSelect.isHidden = false
                    cell.imgFav.isHidden = false
                    cell.btnFav.addTarget(self, action: #selector(clickFav(_:)), for: .touchUpInside)
                    cell.btnFav.tag = indexPath.row
                    cell.btnSelect.addTarget(self, action: #selector(clickVendor(_:)), for: .touchUpInside)
                    cell.btnSelect.tag = indexPath.row
                    return cell
                }
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "allRestaurantCell", for: indexPath) as! AllRestaurantTblCell
                cell.lblRestaurantName.text = self.allRestaurantModel[indexPath.row].name
                cell.lblRestaurantDesc.text = self.allRestaurantModel[indexPath.row].cuisines
                cell.lblRestaurantDeliveryTime.text = (allRestaurantModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
                if let offer = self.allRestaurantModel[indexPath.row].offer, offer != ""{
                    cell.lblRestaurantOffer.text = offer
                    cell.imgOffer.isHidden = false
                    cell.lblLine.isHidden = false
                }else{
                    cell.lblRestaurantOffer.text = ""
                    cell.imgOffer.isHidden = true
                    cell.lblLine.isHidden = true
                }
                
                let imageUrl = self.allRestaurantModel[indexPath.row].logo
                let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
                
                var activityLoader = UIActivityIndicatorView()
                activityLoader = UIActivityIndicatorView(style: .medium)
                activityLoader.center = cell.imgRestaurant.center
                activityLoader.startAnimating()
                cell.imgRestaurant.addSubview(activityLoader)
                
                cell.imgRestaurant.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                    
                    if image != nil
                    {
                        activityLoader.stopAnimating()
                    }
                    else
                    {
                        print("image not found")
                        cell.imgRestaurant.image = UIImage(named: "no_image")
                        activityLoader.stopAnimating()
                    }
                })
                if let rating = allRestaurantModel[indexPath.row].rating?.rating, rating != "" && rating != "0"{
                    cell.viewRating.isHidden = false
                    cell.lblRestaurantRating.text = allRestaurantModel[indexPath.row].rating?.vendorRatingName
                    let imageUrl = allRestaurantModel[indexPath.row].rating?.vendorRatingImage
                    let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .medium)
                    activityLoader.center = cell.imgRating.center
                    activityLoader.startAnimating()
                    cell.imgRating.addSubview(activityLoader)
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
                }else{
                    cell.viewRating.isHidden = true
                }
                cell.lblMinOrder.text = NSLocalizedString("Minimum order - ", comment: "") + (self.allRestaurantModel[indexPath.row].minimumAmount ?? "0")
                if orderType == "2"{
                    
                    cell.lblRestaurantPreparingTime.text = (allRestaurantModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
                    cell.viewPreparing.isHidden = false
                }else{
                    if allRestaurantModel[indexPath.row].freeDelivery == "1"{
                        cell.lblRestaurantDeliveryCharge.text = NSLocalizedString("Free delivery", comment: "")
                    }else{
                        cell.lblRestaurantDeliveryCharge.text = (self.allRestaurantModel[indexPath.row].deliveryCharge ?? "0")
                    }
                    cell.lblRestaurantDeliveryTime.text = (allRestaurantModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
                    cell.viewPreparing.isHidden = true
                }
                let vendorStatus = self.allRestaurantModel[indexPath.row].vendorStatus
                if vendorStatus == "1"{
                    cell.viewBusy1.isHidden = true
                }else{
                    if vendorStatus == "0"{
                        cell.lblRestaurantStatus1.text = NSLocalizedString("Closed", comment: "")
                    }else if vendorStatus == "2"{
                        cell.lblRestaurantStatus1.text = NSLocalizedString("Busy", comment: "")
                    }
                    cell.viewBusy1.isHidden = false
                }
                let vendorId = self.allRestaurantModel[indexPath.row].vendorID ?? "0"
                let isFav = checkVendorInWishList(vendorId: vendorId)
                if isFav{
                    cell.imgFav.image = UIImage(named: "ic_fav_fill")
                    cell.imgFav.image = cell.imgFav.image!.withRenderingMode(.alwaysTemplate)
                    cell.imgFav.tintColor = ConfigTheme.themeColor
                }else{
                    cell.imgFav.image = UIImage(named: "ic_fav_outline")
                    cell.imgFav.image = cell.imgFav.image!.withRenderingMode(.alwaysTemplate)
                    cell.imgFav.tintColor = ConfigTheme.themeColor
                }
                cell.btnFav.isHidden = false
                cell.btnSelect.isHidden = false
                cell.imgFav.isHidden = false
                cell.btnFav.addTarget(self, action: #selector(clickFav(_:)), for: .touchUpInside)
                cell.btnFav.tag = indexPath.row
                cell.btnSelect.addTarget(self, action: #selector(clickVendor(_:)), for: .touchUpInside)
                cell.btnSelect.tag = indexPath.row
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectionCell", for: indexPath) as! multiSelectionCell
            cell.lblSelectionTitle.text = self.cuisineArray[indexPath.row]["name"] as? String
            let cuisineId = self.cuisineArray[indexPath.row]["cuisine_id"] as? Int ?? 0
            let isAlreadyHave = checkAvailablity(cuisineId)
            let selectedImg = isAlreadyHave == true ? "ic_checkbox" : "ic_uncheck"
            HELPER.changeTintColor(imgVw: cell.imgSelection, img: selectedImg, color: ConfigTheme.themeColor)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == myTblAllRestaurant{
            if restaurantPageType == "" {
                if indexPath.section == 0{
                    if indexPath.row == 0{
                        if self.filterModel.count != 0{
                            return 170
                        }else{
                            return 0
                        }
                    }else{
                        if self.bannerModel.count != 0{
                            return ((self.myTblAllRestaurant.frame.size.width - 20) / 1.78) + 35
                        }else{
                            return 0
                        }
                    }
                }else{
                    if let offer = self.allRestaurantModel[indexPath.row].offer, offer != ""{
                        return 186
                    }else{
                        return 147
                    }
                }
            }else {
                if let offer = self.allRestaurantModel[indexPath.row].offer, offer != ""{
                    return 186
                }else{
                    return 147
                }
            }
        }else{
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == myTblCuisines{
            let cuisineId = self.cuisineArray[indexPath.row]["cuisine_id"] as? Int ?? 0
            var isAlreadyHave:Bool = false
            
            for i in 0..<tempSelectedCuisines.count
            {
                print(tempSelectedCuisines)
                let tempCart:[String: Any] = tempSelectedCuisines[i]
                
                let tempId = tempCart["cuisine_id"] as! Int
                
                if tempId == cuisineId
                {
                    tempSelectedCuisines.remove(at: i)
                    isAlreadyHave = true
                    break
                }
            }
            if !isAlreadyHave{
                tempSelectedCuisines.append(self.cuisineArray[indexPath.row])
            }
            setApplyBtn()
            myTblCuisines.reloadData()
        }else if tableView == myTblAllRestaurant{
            
        }
    }
}

extension AllRestaurantVc : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1{
            return filterModel.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "vendorSplFilterCell", for: indexPath) as! VendorSplFilterCollCell
            cell.lblFilterName.text = filterModel[indexPath.row].name
            let imageUrl = filterModel[indexPath.row].logo
            let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""

            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: .medium)
            activityLoader.center = cell.imgFilter.center
            activityLoader.startAnimating()
            cell.imgFilter.addSubview(activityLoader)

            cell.imgFilter.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                if image != nil
                {
                    activityLoader.stopAnimating()
                }
                else
                {
                    print("image not found")
                    cell.imgFilter.image = UIImage(named: "no_image")
                    activityLoader.stopAnimating()
                }
            })
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topPicksCollCell", for: indexPath) as! HomeTopPicksCollCell
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1{
            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: AllRestaurantVc.storyboardID) as! AllRestaurantVc
            aViewController.restaurantPageType = "offerRestaurant"
            aViewController.NavTitle = filterModel[indexPath.row].name ?? ""
            aViewController.offerKey = filterModel[indexPath.row].key ?? ""
            self.navigationController?.pushViewController(aViewController, animated: true)
        }
    }
}

extension AllRestaurantVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 150)
    }
}
