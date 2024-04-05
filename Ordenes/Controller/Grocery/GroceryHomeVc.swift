//
//  GroceryHomeVc.swift
//  Talabat clone
//
//  Created by Adyas infotech on 23/08/22.
//

import UIKit
import MarqueeLabel

class GroceryHomeVc: UIViewController {

    @IBOutlet weak var myViewSearch: UIView!
    @IBOutlet weak var myTblGrocery: UITableView!
    @IBOutlet weak var myLblDeliveryLocation: MarqueeLabel!
    @IBOutlet weak var myViewCart : UIView!
    @IBOutlet weak var myLblMinError : UILabel!
    @IBOutlet weak var myLblViewBasket : UILabel!
    @IBOutlet weak var myLblCount : UILabel!
    @IBOutlet weak var myLblAmount : UILabel!
    @IBOutlet weak var myTxtSearch : UITextField!
    @IBOutlet weak var myViewNoGrocery : UIView!
    @IBOutlet weak var myImgFav: UIImageView!
    
    var groceryInfoModel = [AllRestroVendor]()
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "20"
    var statusView = StatusView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callGetCartCount(completionBlock: {
            self.callGetAllGroceryApi()
        })
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
                       self.myTblGrocery.contentInset = UIEdgeInsets(top: 0,
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
                       self.myTblGrocery.contentInset = UIEdgeInsets(top: 0,
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
    
    func callGetAllGroceryApi() {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        page = 1
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_PAGE] = page
        aDictParameters[K_PARAMS_LIMIT] = limit
        aDictParameters[K_PARAMS_BUSINESS_TYPE] = "2"
        aDictParameters[K_PARAMS_CUISINE] = []
        aDictParameters[K_PARAMS_FREE_DELIVERY] = ""
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_VENDOR_LISTING, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    let modelData = try! JSONDecoder().decode(AllRestraurantModel.self, from: jsonData)
                    self.groceryInfoModel = modelData.vendor ?? []
                    if self.groceryInfoModel.count == 0{
                        self.myViewNoGrocery.isHidden = false
                    }else{
                        self.myViewNoGrocery.isHidden = true
                    }
                    let total = modelData.total
                    self.pageCount = Double(Int(total ?? "0")!/Int(self.limit)!)
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }
                } else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_GROCERY)
                }
                self.myTblGrocery.dataSource = self
                self.myTblGrocery.delegate = self
                self.myTblGrocery.reloadData()
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
            aDictParameters[K_PARAMS_BUSINESS_TYPE] = "2"
            aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
            aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_VENDOR_LISTING, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
               do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(AllRestraurantModel.self, from: jsonData)
                        self.groceryInfoModel.append(contentsOf: modelData.vendor ?? [])
                        self.myTblGrocery.reloadData()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView == myTblGrocery{
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
                    self.pullToRefresh()
                }
            }
        }
    }
    
    func setupUI()
    {
        self.myViewNoGrocery.isHidden = true
        self.myTxtSearch.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblAmount.textAlignment = isRTLenabled == true ? .left : .right
        if let location = UserDefaults.standard.value(forKey: UD_SELECTED_ADDRESS), "\(location)" != ""{
            self.myLblDeliveryLocation.text = location as? String
        }
        self.myViewSearch.layer.cornerRadius = 8
        self.myViewSearch.layer.borderWidth = 1
        self.myViewSearch.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myTblGrocery.register(UINib(nibName: "ShopByStoreTblCell", bundle: nil), forCellReuseIdentifier: "shopByStoreCell")
        self.myTblGrocery.register(UINib(nibName: "AllRestaurantTblCell", bundle: nil), forCellReuseIdentifier: "allRestaurantCell")
        self.myImgFav.image = UIImage(named: "ic_fav_fill_48")
        self.myImgFav.image = self.myImgFav.image!.withRenderingMode(.alwaysTemplate)
        self.myImgFav.tintColor = ConfigTheme.themeColor
    }
    
    func clickCategory(selectedId : String){
        
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
    
    //MARK: Button action
    @IBAction func clickBack(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickViewBasket(_ sender: UIButton){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CartVc.storyboardID) as! CartVc
        navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickSearch(_ sender : Any){
        let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GrocerySearchVc.storyboardID) as! GrocerySearchVc
        navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickMyFavourite(_ sender : Any){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: FavouriteVc.storyboardID) as! FavouriteVc
        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @objc func clickVendor(_ sender: UIButton){
        let vendorStatus = self.groceryInfoModel[sender.tag].vendorStatus
        if vendorStatus == "1"{
            if self.groceryInfoModel[sender.tag].vendorTypeID == "2"{
                let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
                aViewController.vendorId = self.groceryInfoModel[sender.tag].vendorID ?? "0"
                self.navigationController?.pushViewController(aViewController, animated: true)
            }else{
                let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
                aViewController.vendorId = self.groceryInfoModel[sender.tag].vendorID ?? "0"
                self.navigationController?.pushViewController(aViewController, animated: true)
            }
        }else{
            if self.groceryInfoModel[sender.tag].vendorID != nil{
                self.statusView.myBtnContinue.tag = sender.tag
                self.statusView.myBtnContinue.addTarget(self, action: #selector(clickContinue(_:)), for: .touchUpInside)
                if vendorStatus == "0"{
                    self.statusView.myLblHeader.text = NSLocalizedString("Grocery Closed", comment: "")
                    self.statusView.myLblMsg.text = NSLocalizedString("We're sorry, \(self.groceryInfoModel[sender.tag].name ?? "Vendor") is currently closed and is not accepting orders at this time. You can continue adding items to your basket and order when Grocery is open.", comment: "")
                }else if vendorStatus == "2"{
                    self.statusView.myLblHeader.text = NSLocalizedString("Grocery Busy", comment: "")
                    self.statusView.myLblMsg.text = NSLocalizedString("We're sorry, \(self.groceryInfoModel[sender.tag].name ?? "Vendor") is currently busy and is not accepting orders at this time. You can continue adding items to your basket and order when Grocery is open.", comment: "")
                }
                self.statusView.frame = self.view.frame
                self.view.addSubview(self.statusView)
            }
        }
    }
    
    @objc func clickContinue(_ sender: UIButton){
        if self.groceryInfoModel[sender.tag].vendorTypeID == "2"{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
            aViewController.vendorId = self.groceryInfoModel[sender.tag].vendorID ?? "0"
            self.navigationController?.pushViewController(aViewController, animated: true)
            self.statusView.removeFromSuperview()
        }else{
            let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
            aViewController.vendorId = self.groceryInfoModel[sender.tag].vendorID ?? "0"
            self.navigationController?.pushViewController(aViewController, animated: true)
            self.statusView.removeFromSuperview()
        }
    }
    
    @objc func clickFav(_ sender: UIButton){
        guard let vendorId = self.groceryInfoModel[sender.tag].vendorID else { return }
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
        let indexPath = IndexPath(row: sender.tag, section: 0)
        self.myTblGrocery.reloadRows(at: [indexPath], with: .none)
    }
}

extension GroceryHomeVc: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groceryInfoModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allRestaurantCell", for: indexPath) as! AllRestaurantTblCell
        cell.lblRestaurantName.text = self.groceryInfoModel[indexPath.row].name
        cell.lblRestaurantDesc.text = self.groceryInfoModel[indexPath.row].storeTypes
        if let offer = self.groceryInfoModel[indexPath.row].offer, offer != ""{
            cell.lblRestaurantOffer.text = offer
            cell.imgOffer.isHidden = false
            cell.lblLine.isHidden = false
        }else{
            cell.lblRestaurantOffer.text = ""
            cell.imgOffer.isHidden = true
            cell.lblLine.isHidden = true
        }
        let imageUrl = self.groceryInfoModel[indexPath.row].logo
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
        if let rating = groceryInfoModel[indexPath.row].rating?.rating, rating != "" && rating != "0"{
            cell.viewRating.isHidden = false
            cell.lblRestaurantRating.text = groceryInfoModel[indexPath.row].rating?.vendorRatingName
            let imageUrl = groceryInfoModel[indexPath.row].rating?.vendorRatingImage
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
        let minimumAmount = " - Min. " + (self.groceryInfoModel[indexPath.row].minimumAmount ?? "0")
        if orderType == "2"{
            cell.lblRestaurantPreparingTime.text = (groceryInfoModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "") + minimumAmount
            cell.viewPreparing.isHidden = false
        }else{
            if groceryInfoModel[indexPath.row].freeDelivery == "1"{
                cell.lblRestaurantDeliveryCharge.text = NSLocalizedString("Free delivery", comment: "") + minimumAmount
            }else{
                cell.lblRestaurantDeliveryCharge.text = (self.groceryInfoModel[indexPath.row].deliveryCharge ?? "0") + minimumAmount
            }
            cell.lblRestaurantDeliveryTime.text = (groceryInfoModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
            cell.viewPreparing.isHidden = true
        }
        let vendorStatus = self.groceryInfoModel[indexPath.row].vendorStatus
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
        let vendorId = self.groceryInfoModel[indexPath.row].vendorID ?? "0"
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let offer = self.groceryInfoModel[indexPath.row].offer, offer != ""{
            return 186
        }else{
            return 147
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension GroceryHomeVc: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCatCell", for: indexPath) as! ProductCategoryCollCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.clickCategory(selectedId: "1")
    }
}

extension GroceryHomeVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 125, height: 38)
    }
}
