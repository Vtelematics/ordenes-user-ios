//
//  RestaurantVc.swift
//  Talabat clone
//
//  Created by Adyas infotech on 08/07/22.
//

import UIKit
//import FloatRatingView

class RestaurantVc: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var myTblRestaurant : UITableView!
    @IBOutlet var myRestaurantImg : UIImageView!
    @IBOutlet var myCollCategory : UICollectionView!
    @IBOutlet var myViewTop : UIView!
    @IBOutlet var lblRestaurantName : UILabel!
    @IBOutlet var lblCuisines : UILabel!
    @IBOutlet var lblRating : UILabel!
    @IBOutlet var lblRatingCount : UILabel!
    @IBOutlet var myRatingView : FloatRatingView!
    @IBOutlet var viewInfo : UIView!
    @IBOutlet var viewReviews : UIView!
    @IBOutlet var myViewTab : UIView!
    @IBOutlet var myViewBack : UIView!
    @IBOutlet var myViewSearch : UIView!
    @IBOutlet var myViewFavourite : UIView!
    @IBOutlet var myImgFavourite : UIImageView!
    @IBOutlet var myViewCategoryContainer : UIView!
    @IBOutlet var myTblCategory : UITableView!
    @IBOutlet var myLblRestaurantName2 : UILabel!
    @IBOutlet var myLblRestaurantStatus : UILabel!
    @IBOutlet var myViewStatusBg : UIView!
    @IBOutlet var myBtnBackCategory : UIButton!
    @IBOutlet var myViewOrderType : UIView!
    @IBOutlet var myViewPickup : UIView!
    @IBOutlet var myViewDelivery : UIView!
    @IBOutlet var myLblPickup : UILabel!
    @IBOutlet var myLblDelivery : UILabel!
    @IBOutlet var myLblOrderType : UILabel!
    @IBOutlet var myLblOrderTypeInfo : UILabel!
    @IBOutlet var myViewOrderTypeCommon : UIView!
    
    @IBOutlet var myViewCart : UIView!
    @IBOutlet var myLblCount : UILabel!
    @IBOutlet var myLblAmount : UILabel!
    @IBOutlet weak var myLblMinError : UILabel!
    @IBOutlet weak var myLblViewBasket : UILabel!
    
    var selectedIndex = 0
    var lblWidth = CGFloat()
    var vendorId = ""
    var vendorInfoModel : Vendor?
    var CategoryModel:[Category] = []
    var previousContentOffSetY = CGFloat()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callGetCartCount(completionBlock: {
            self.callGetRestaurantInfo()
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
                       self.myTblRestaurant.contentInset = UIEdgeInsets(top: self.myViewTop.frame.height + self.myViewTab.frame.height,
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
                       self.myTblRestaurant.contentInset = UIEdgeInsets(top: self.myViewTop.frame.height + self.myViewTab.frame.height,
                                                             left: 0,
                                                            bottom: self.myViewCart.frame.height,
                                                             right: 0)
                       self.myViewCart.isHidden = false
                   }
               }else{
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
               }
               HELPER.hideLoadingAnimation()
               completionBlock()
            } catch {
                print(error.localizedDescription)
            }
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
            completionBlock()
        })
        
    }
    
    func callGetRestaurantInfo() {
        self.myTblRestaurant.isHidden = false
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
        aDictParameters[K_PARAMS_VENDOR_TYPE_ID] = ""
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_VENDOR_INFO, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { [self] (response) in
           do {
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    print(aDictInfo)
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    let modelData = try! JSONDecoder().decode(RestaurantModel.self, from: jsonData)
                    self.vendorInfoModel = modelData.vendor
                    self.CategoryModel = []
                    for obj in modelData.vendor?.category ?? []{
                        if obj.product?.count != 0{
                            self.CategoryModel.append(obj)
                        }
                    }
                    self.myViewTab.dropShadow(cornerRadius: 0, opacity: 0.2, radius: 8)
                    let imageUrl =  modelData.vendor?.image
                    let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20")
                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .medium)
                    activityLoader.center = self.myRestaurantImg.center
                    activityLoader.startAnimating()
                    self.myRestaurantImg.addSubview(activityLoader)
                    self.myRestaurantImg.sd_setImage(with: URL(string: trimmedUrl ?? ""), completed: { (image, error, imageCacheType, imageUrl) in
                        
                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }
                        else
                        {
                            print("image not found")
                            self.myRestaurantImg.image = UIImage(named: "no_image")
                            activityLoader.stopAnimating()
                        }
                    })
                    if self.vendorInfoModel?.pickup == "1" && self.vendorInfoModel?.delivery == "1"{
                        self.myViewOrderTypeCommon.isHidden = true
                        if orderType == "2"{
                            self.myViewPickup.backgroundColor = .white
                            self.myViewDelivery.backgroundColor = ConfigTheme.customLightGray2
                        }else{
                            
                            self.myViewPickup.backgroundColor = ConfigTheme.customLightGray2
                            self.myViewDelivery.backgroundColor = .white
                        }
                        self.myLblDelivery.text = "\(NSLocalizedString("In", comment: "")) \(String(describing:self.vendorInfoModel?.deliveryTime ?? "")) \(NSLocalizedString("mins", comment: "")) - \(String(describing: self.vendorInfoModel?.deliveryCharge ?? ""))"
                        self.myLblPickup.text = "\(NSLocalizedString("In", comment: "")) \(String(describing:self.vendorInfoModel?.preparingTime ?? "")) \(NSLocalizedString("mins", comment: "")) - \(String(describing: self.vendorInfoModel?.vendorDistance ?? "")) km"
                        self.myViewPickup.isHidden = false
                        self.myViewDelivery.isHidden = false
                    }else{
                        self.myViewOrderTypeCommon.isHidden = false
                        if self.vendorInfoModel?.pickup == "1"{
                            self.myLblOrderType.text = NSLocalizedString("Pickup", comment: "")
                            self.myLblOrderTypeInfo.text = "\(NSLocalizedString("In", comment: "")) \(String(describing:self.vendorInfoModel?.preparingTime ?? "")) \(NSLocalizedString("mins", comment: "")) - \(String(describing: self.vendorInfoModel?.vendorDistance ?? "")) km"
                        }else{
                            self.myLblOrderType.text = NSLocalizedString("Delivery", comment: "")
                            self.myLblOrderTypeInfo.text = "\(NSLocalizedString("In", comment: "")) \(String(describing:self.vendorInfoModel?.deliveryTime ?? "")) \(NSLocalizedString("mins", comment: "")) - \(String(describing: self.vendorInfoModel?.deliveryCharge ?? ""))"
                        }
                    }
                    if self.myViewCart.isHidden == true{
                        self.myTblRestaurant.contentInset = UIEdgeInsets(top: self.myViewTop.frame.height + self.myViewTab.frame.height,
                                                              left: 0,
                                                              bottom: 0,
                                                              right: 0)
                    }else{
                        self.myTblRestaurant.contentInset = UIEdgeInsets(top: self.myViewTop.frame.height + self.myViewTab.frame.height,
                                                              left: 0,
                                                             bottom: self.myViewCart.frame.height,
                                                              right: 0)
                    }
                    let status = self.vendorInfoModel?.vendorStatus
                    if status == "1"{
                        self.myLblRestaurantStatus.isHidden = true
                        self.myViewStatusBg.isHidden = true
                    }else{
                        if status == "0"{
                            self.myLblRestaurantStatus.isHidden = false
                            self.myLblRestaurantStatus.text = NSLocalizedString("Closed", comment: "")
                        }else{
                            self.myLblRestaurantStatus.isHidden = false
                            self.myLblRestaurantStatus.text = NSLocalizedString("Busy", comment: "")
                        }
                        self.myViewStatusBg.isHidden = false
                    }
                    self.lblRestaurantName.text = self.vendorInfoModel?.name
                    var cuisneList = [String]()
                    for obj in self.vendorInfoModel?.cuisine ?? []{
                        let name = obj.name
                        cuisneList.append(name!)
                    }
                    self.lblCuisines.text = cuisneList.joined(separator: ", ")
                    self.myViewTab.isHidden = self.CategoryModel.count == 0 ? true : false
                    
                    if let rating = self.vendorInfoModel?.rating?.rating, rating != "0" &&  rating != ""{
                        self.myRatingView.rating = Float(rating) ?? 0.0
                        self.lblRating.text = rating
                        if isRTLenabled{
                            self.lblRatingCount.text = "(\(NSLocalizedString("ratings", comment: "")) \(self.vendorInfoModel?.rating?.count ?? "0"))"
                        }else{
                            self.lblRatingCount.text = "(\(self.vendorInfoModel?.rating?.count ?? "0") \(NSLocalizedString("ratings", comment: "")))"
                        }
                        self.viewReviews.isHidden = false
                    }else{
                        self.viewReviews.isHidden = true
                        self.myRatingView.rating = 0
                        self.lblRatingCount.text = NSLocalizedString("No rating", comment: "")
                    }
                    guard let vendorId = self.vendorInfoModel?.vendorID else { return }
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
                                break
                            }
                        }
                        if isHave{
                            self.myImgFavourite.image = UIImage(named: "ic_fav_fill")
                            self.myImgFavourite.image = myImgFavourite.image!.withRenderingMode(.alwaysTemplate)
                            self.myImgFavourite.tintColor = ConfigTheme.themeColor
                        }else{
                            self.myImgFavourite.image = UIImage(named: "ic_fav_outline")
                            self.myImgFavourite.image = myImgFavourite.image!.withRenderingMode(.alwaysTemplate)
                            self.myImgFavourite.tintColor = ConfigTheme.themeColor
                        }
                        do{
                            let data = try NSKeyedArchiver.archivedData(withRootObject: favAry, requiringSecureCoding: false)
                            UserDefaults.standard.set(data, forKey: UD_WISHLIST)
                            
                        } catch {
                            print("Couldn't write file")
                        }
                    }else{
                        self.myImgFavourite.image = UIImage(named: "ic_fav_outline")
                        self.myImgFavourite.image = myImgFavourite.image!.withRenderingMode(.alwaysTemplate)
                        self.myImgFavourite.tintColor = ConfigTheme.themeColor
                    }
                    
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }
                }else{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_RESTAURANT)
                }
               self.myViewTop.isHidden = false
               self.myTblRestaurant.isHidden = false
               self.myTblRestaurant.delegate = self
               self.myTblRestaurant.dataSource = self
               self.myTblRestaurant.reloadData()
               self.myCollCategory.delegate = self
               self.myCollCategory.dataSource = self
               self.myCollCategory.reloadData()
               if isRTLenabled {
                   self.myCollCategory.scrollToItem(at: [0, 0], at: .right, animated: true)
               }else {
                   self.myCollCategory.setContentOffset(.zero, animated: false)
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
    
    func setupUI() {
        self.myTblRestaurant.scrollsToTop = false
        self.myLblAmount.textAlignment = isRTLenabled == true ? .left : .right
        self.viewInfo.layer.cornerRadius = 6
        self.viewReviews.layer.cornerRadius = 6
        self.viewInfo.layer.borderWidth = 0.6
        self.viewReviews.layer.borderWidth = 0.6
        self.viewInfo.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.viewReviews.layer.borderColor = ConfigTheme.customLightGray.cgColor
        if #available(iOS 15.0, *) {
            self.myTblRestaurant.sectionFooterHeight = 0
            self.myTblRestaurant.sectionHeaderTopPadding = 0
        }
        self.myTblRestaurant.register(UINib(nibName: "ProductTblCell", bundle: nil), forCellReuseIdentifier: "productCell")
        self.myCollCategory.register(UINib(nibName: "ProductCategoryCollCell", bundle: nil), forCellWithReuseIdentifier: "productCatCell")
        self.myTblRestaurant.contentInset = UIEdgeInsets(top: self.myViewTop.frame.height + self.myViewTab.frame.height,
                                              left: 0,
                                              bottom: 0,
                                              right: 0)
        self.myBtnBackCategory.isHidden = true
        self.myViewCategoryContainer.isHidden = true
        self.myViewCategoryContainer.roundTopCorners(radius: 15)
        myRatingView.emptyImage = UIImage(named: "ic_starEmpty")
        myRatingView.fullImage = UIImage(named: "ic_starFull")
        myRatingView.minRating = 0
        myRatingView.maxRating = 5
        myRatingView.rating = 0
        myRatingView.halfRatings = true
        myRatingView.editable = false
        if isRTLenabled{
            self.myRatingView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        self.myViewOrderTypeCommon.layer.cornerRadius = self.myViewOrderTypeCommon.frame.size.height / 2
        self.myViewOrderType.layer.cornerRadius = self.myViewOrderType.frame.size.height / 2
        self.myViewPickup.layer.cornerRadius = self.myViewPickup.frame.size.height / 2
        self.myViewDelivery.layer.cornerRadius = self.myViewDelivery.frame.size.height / 2
        self.myViewOrderType.backgroundColor = ConfigTheme.customLightGray2
    }
        
    //MARK: Button action
    @IBAction func clickBack(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickMenu(_ sender : Any){
        self.myBtnBackCategory.isHidden = false
        self.myViewCategoryContainer.isHidden = false
        self.myLblRestaurantName2.text = self.vendorInfoModel?.name
        self.myTblCategory.dataSource = self
        self.myTblCategory.delegate = self
        self.myTblCategory.reloadData()
    }
    
    @IBAction func clickRating(_ sender : Any){
        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: ReviewInfoVc.storyboardID) as! ReviewInfoVc
        aViewController.modalPresentationStyle = .fullScreen
        aViewController.vendorId = vendorId
        aViewController.imgStrVendor = self.vendorInfoModel?.image ?? ""
        aViewController.pageType = "reviews"
        present(aViewController, animated: true)
    }
    
    @IBAction func clickSearchProduct(_ sender : Any){
        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: ProductSearchVc.storyboardID) as! ProductSearchVc
        aViewController.MainCategoryModel = CategoryModel
        aViewController.vendorId = vendorId
        self.navigationController?.pushViewController(aViewController, animated: true)
//        
//        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: ProductDetailVc.storyboardID) as! ProductDetailVc
//        aViewController.productModel = CategoryModel[indexPath.section].product?[indexPath.row]
//        aViewController.vendorId = vendorId
//        aViewController.vendorName = self.vendorInfoModel?.name ?? ""
//        aViewController.vendorStatus = self.vendorInfoModel?.vendorStatus ?? ""
//        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickInfo(_ sender : Any){
        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantInfoVc.storyboardID) as! RestaurantInfoVc
        aViewController.vendorInfoModel = vendorInfoModel
        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickViewBasket(_ sender: Any) {
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CartVc.storyboardID) as! CartVc
        navigationController?.pushViewController(aViewController, animated: true)
    }
        
    @IBAction func clickBackFromCategory(_ sender : Any){
        self.myBtnBackCategory.isHidden = true
        self.myViewCategoryContainer.isHidden = true
    }
    
    @IBAction func clickPickup(_ sender : Any){
        orderType = "2"
        self.callGetRestaurantInfo()
    }
    
    @IBAction func clickDelivery(_ sender : Any){
        orderType = "1"
        self.callGetRestaurantInfo()
    }
    
    @IBAction func clickFav(_ sender: Any){
        guard let vendorId = self.vendorInfoModel?.vendorID else { return }
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
                    self.myImgFavourite.image = UIImage(named: "ic_fav_outline")
                    self.myImgFavourite.image = myImgFavourite.image!.withRenderingMode(.alwaysTemplate)
                    self.myImgFavourite.tintColor = ConfigTheme.themeColor
                    self.showFavToastView(message: NSLocalizedString("Removed from your favourites", comment: ""))
                    break
                }
            }
            if !isHave{
                favAry.append(vendorId)
                self.myImgFavourite.image = UIImage(named: "ic_fav_fill")
                self.myImgFavourite.image = myImgFavourite.image!.withRenderingMode(.alwaysTemplate)
                self.myImgFavourite.tintColor = ConfigTheme.themeColor
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
            do{
                let data = try NSKeyedArchiver.archivedData(withRootObject: favAry, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: UD_WISHLIST)
                self.myImgFavourite.image = UIImage(named: "ic_fav_fill")
                self.myImgFavourite.image = myImgFavourite.image!.withRenderingMode(.alwaysTemplate)
                self.myImgFavourite.tintColor = ConfigTheme.themeColor
                self.showFavToastView(message: NSLocalizedString("Added to your favourites", comment: ""))
            } catch {
                print("Couldn't write file")
            }
        }
    }
}

extension RestaurantVc: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if tableView == myTblRestaurant{
            return CategoryModel.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == myTblRestaurant{
            return CategoryModel[section].product?.count ?? 0
        }else{
            return self.CategoryModel.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if tableView == myTblRestaurant{
            let headerView: ProductTblCell? = tableView.dequeueReusableCell(withIdentifier: "productHeader") as! ProductTblCell?
            headerView?.lblHeader.text = CategoryModel[section].name
            selectedIndex = section
            myCollCategory.reloadData()
            if isRTLenabled {
                self.myCollCategory.scrollToItem(at:IndexPath(item: selectedIndex, section: 0), at: .left, animated: true)
            }else {
                self.myCollCategory.scrollToItem(at:IndexPath(item: selectedIndex, section: 0), at: .right, animated: true)
            }
            headerView?.backgroundColor = .white
            if headerView == nil
            {
                print("No cells with matching CellIdentifier loaded from your storyboard")
            }
            return headerView!
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == myTblRestaurant{
            if selectedIndex != indexPath.section{
                selectedIndex = indexPath.section
                myCollCategory.reloadData()
                if isRTLenabled {
                    self.myCollCategory.scrollToItem(at:IndexPath(item: selectedIndex, section: 0), at: .left, animated: true)
                }else {
                    self.myCollCategory.scrollToItem(at:IndexPath(item: selectedIndex, section: 0), at: .right, animated: true)
                }
            }
            let cell:ProductTblCell = self.myTblRestaurant.dequeueReusableCell(withIdentifier: "productCell") as! ProductTblCell
            cell.lblProductName.text = CategoryModel[indexPath.section].product?[indexPath.row].itemName
            cell.lblProductDesc.frame.size.width = cell.lblProductName.frame.size.width
            cell.lblProductDesc.text = CategoryModel[indexPath.section].product?[indexPath.row].productDescription
            cell.lblProductDesc.textAlignment = isRTLenabled ? .right : .left
            cell.lblProductDesc.sizeToFit()
            if isRTLenabled{
                cell.lblProductDesc.frame.origin.x = (cell.frame.width - cell.lblProductDesc.frame.width) - 10
            }
            cell.lblProductDesc.translatesAutoresizingMaskIntoConstraints = true
            print(cell.lblProductDesc.frame.origin.x, cell.lblProductName.frame.origin.x)
            if let priceStatus = CategoryModel[indexPath.section].product?[indexPath.row].priceStatus, priceStatus == "1"{
                if var discount = CategoryModel[indexPath.section].product?[indexPath.row].discount, discount != ""{
                    discount = discount + " "
                    let multipleAttributes: [NSAttributedString.Key : Any] = [
                        NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 14.0) ?? "",
                        NSAttributedString.Key.foregroundColor: UIColor.black,
                    ]
                    let myAttrStringDiscount = NSMutableAttributedString(string: discount , attributes: multipleAttributes)
                    let price = CategoryModel[indexPath.section].product?[indexPath.row].price ?? ""
                    let multipleAttributes2: [NSAttributedString.Key : Any] = [
                        NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 14.0) ?? "",
                        NSAttributedString.Key.foregroundColor: UIColor.gray,
                    ]
                    let myAttrStringPrice = NSMutableAttributedString(string: price , attributes: multipleAttributes2)
                    myAttrStringPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, myAttrStringPrice.length))
                    myAttrStringDiscount.append(myAttrStringPrice)
                    cell.lblPrice.attributedText = myAttrStringDiscount
                }else{
                    cell.lblPrice.text = CategoryModel[indexPath.section].product?[indexPath.row].price
                    cell.lblPrice.textColor = .black
                }
            }else{
                cell.lblPrice.text = NSLocalizedString("Price on selection", comment: "")
                cell.lblPrice.textColor = .black
            }
            cell.lblPrice.textAlignment = isRTLenabled ? .right : .left
            let imageUrl =  CategoryModel[indexPath.section].product?[indexPath.row].logo
            let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20")
            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: .medium)
            activityLoader.center = cell.imgProduct.center
            activityLoader.startAnimating()
            cell.imgProduct.addSubview(activityLoader)
            cell.imgProduct.sd_setImage(with: URL(string: trimmedUrl!), completed: { (image, error, imageCacheType, imageUrl) in
                if image != nil {
                    activityLoader.stopAnimating()
                }else {
                    print("image not found")
                    cell.imgProduct.image = UIImage(named: "no_image")
                    activityLoader.stopAnimating()
                }
            })
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCategoryCell", for: indexPath as IndexPath) as! ProductDetailTableViewCell
            cell.lblCategoryTitle.text = CategoryModel[indexPath.row].name
            let count = CategoryModel[indexPath.row].product?.count ?? 0
            cell.lblProductCount.text = "\(count)"
            cell.lblProductCount.textAlignment = isRTLenabled ? .left : .right
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == myTblRestaurant{
            return 132
        }else{
            return 50
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if tableView == myTblRestaurant{
            let products = CategoryModel[section].product
            return products?.count != 0 ? 41 : 0
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == myTblCategory{
            if indexPath.row != 0{
                self.myTblRestaurant.contentInset.top = self.myViewTab.frame.origin.y + self.myViewTab.frame.height
            }
            self.myBtnBackCategory.isHidden = true
            self.myViewCategoryContainer.isHidden = true
            let sectionIndexPath = IndexPath(row: NSNotFound, section: indexPath.row)
            self.myTblRestaurant.scrollToRow(at: sectionIndexPath, at: .top, animated: true)
        }else{
            let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: ProductDetailVc.storyboardID) as! ProductDetailVc
            aViewController.productModel = CategoryModel[indexPath.section].product?[indexPath.row]
            aViewController.vendorId = vendorId
            aViewController.vendorName = self.vendorInfoModel?.name ?? ""
            aViewController.vendorStatus = self.vendorInfoModel?.vendorStatus ?? ""
            self.navigationController?.pushViewController(aViewController, animated: true)
        }
    }
    
    //MARK:- Sticky Header Effect
    static let offset_HeaderStop: CGFloat = 408  // At this offset the Header stops its transformations (Header height - Approx Nav Bar Height)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == myTblRestaurant{
            let totalOffset = scrollView.contentOffset.y + myViewTop.bounds.height + myViewTab.bounds.height
            
            var headerTransform = CATransform3DIdentity // Both Scale and Translate.
            var segmentTransform = CATransform3DIdentity // Translate only.
            if totalOffset < 0 {
                /*
                 * Table is pulled down below the header.
                 * Animation to transform.
                 */
                let headerScaleFactor:CGFloat = -(totalOffset) / myViewTop.bounds.height
                let headerSizevariation = ((myViewTop.bounds.height * (1.0 + headerScaleFactor)) - myViewTop.bounds.height)/2
                headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
                headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            } else {
                /*
                 * Table scrolled up or down.
                 */
                headerTransform = CATransform3DTranslate(headerTransform, 0, max(-RestaurantVc.offset_HeaderStop, -totalOffset), 0)
            }
            myViewTop.layer.transform = headerTransform
            if totalOffset > 408{
                self.myTblRestaurant.contentInset.top = self.myViewTab.frame.origin.y + self.myViewTab.frame.height
            }else{
                self.myTblRestaurant.contentInset.top = self.myViewTop.frame.height + self.myViewTab.frame.height
            }
            /*
             *  Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking.
             */
            let segmentViewOffset = -totalOffset
            segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -RestaurantVc.offset_HeaderStop), 0)
            myViewTab.layer.transform = segmentTransform
        }
    }
}

extension RestaurantVc : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.CategoryModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCatCell", for: indexPath as IndexPath) as! ProductCategoryCollCell
        cell.lblCategoryTitle.text = CategoryModel[indexPath.row].name
        if selectedIndex == indexPath.row {
            cell.lblLine.isHidden = false
            cell.lblCategoryTitle.textColor = .white
            cell.lblLine.backgroundColor = ConfigTheme.posBtnColor
        }else{
            cell.lblCategoryTitle.textColor = ConfigTheme.customLightGray
            cell.lblLine.isHidden = true
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 0{
            self.myTblRestaurant.contentInset.top = self.myViewTab.frame.origin.y + self.myViewTab.frame.height
        }
        let sectionIndexPath = IndexPath(row: NSNotFound, section: indexPath.row)
        selectedIndex = indexPath.row
        collectionView.reloadData()
        self.myTblRestaurant.scrollToRow(at: sectionIndexPath, at: .top, animated: false)
    }
}

extension RestaurantVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = CategoryModel[indexPath.row].name
        label.sizeToFit()
        return CGSize(width: label.frame.width + 15, height: 38)
        //return CGSize(width: 125, height: 38)
    }
}
