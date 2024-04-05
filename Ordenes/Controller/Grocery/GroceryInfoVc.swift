//
//  GroceryInfoVc.swift
//  Talabat clone
//
//  Created by Adyas infotech on 24/08/22.
//

import UIKit

class GroceryInfoVc: UIViewController {

    @IBOutlet weak var myViewSearch: UIView!
    @IBOutlet weak var myLblTitle: UILabel!
    @IBOutlet weak var myCollCategory: UICollectionView!
    @IBOutlet weak var myLblDeliveryTime: UILabel!
    @IBOutlet weak var myLblDeliveryCharge: UILabel!
    @IBOutlet weak var myLblMinOrder: UILabel!
    @IBOutlet weak var myViewContainer: UIView!
    @IBOutlet weak var myViewCategory: UIView!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var myViewCart : UIView!
    @IBOutlet weak var myLblCount : UILabel!
    @IBOutlet weak var myLblAmount : UILabel!
    @IBOutlet weak var myLblMinError : UILabel!
    @IBOutlet weak var myLblViewBasket : UILabel!
    @IBOutlet weak var myViewNoProduct : UIView!
    @IBOutlet weak var myViewOrderType : UIView!
    @IBOutlet weak var myViewPickup : UIView!
    @IBOutlet weak var myViewDelivery : UIView!
    @IBOutlet weak var myLblPickup : UILabel!
    @IBOutlet weak var myLblDelivery : UILabel!
    @IBOutlet var myLblOrderType : UILabel!
    @IBOutlet var myLblOrderTypeInfo : UILabel!
    @IBOutlet var myViewOrderTypeCommon : UIView!
    
    var groceryInfoModel : GroceryInfoModel?
    var vendorId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callGetCartCount(completionBlock: {
            self.callGetGroceyInfoApi()
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
                       self.myScrollView.contentInset = UIEdgeInsets(top: 0,
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
                       self.myScrollView.contentInset = UIEdgeInsets(top: 0,
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
    
    func callGetGroceyInfoApi() {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_VENDOR_TYPE_ID] = "2"
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_VENDOR_INFO, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    self.groceryInfoModel = try! JSONDecoder().decode(GroceryInfoModel.self, from: jsonData)
                    self.myLblTitle.text = self.groceryInfoModel?.vendorInfo?.vendorName
                    self.myLblDeliveryTime.text = self.groceryInfoModel?.vendorInfo?.deliveryTime
                    self.myLblDeliveryCharge.text = self.groceryInfoModel?.vendorInfo?.deliveryCharge
                    self.myLblMinOrder.text = self.groceryInfoModel?.vendorInfo?.minimumAmount
                    if self.groceryInfoModel?.category?.count != 0{
                        self.myViewCategory.isHidden = false
                        self.myViewNoProduct.isHidden = true
                    }else{
                        self.myViewCategory.isHidden = true
                        self.myViewNoProduct.isHidden = false
                    }
                    self.myViewCategory.isHidden = self.groceryInfoModel?.category?.count != 0 ? false : true
                    if self.groceryInfoModel?.vendorInfo?.pickup == "1" && self.groceryInfoModel?.vendorInfo?.delivery == "1"{
                        self.myViewOrderTypeCommon.isHidden = true
                        if orderType == "2"{
                            self.myViewPickup.backgroundColor = .white
                            self.myViewDelivery.backgroundColor = ConfigTheme.customLightGray2
                        }else{
                            
                            self.myViewPickup.backgroundColor = ConfigTheme.customLightGray2
                            self.myViewDelivery.backgroundColor = .white
                        }
                        self.myLblDelivery.text = "\(NSLocalizedString("In", comment: "")) \(String(describing:self.groceryInfoModel?.vendorInfo?.deliveryTime ?? "")) \(NSLocalizedString("mins", comment: "")) - \(String(describing: self.groceryInfoModel?.vendorInfo?.deliveryCharge ?? ""))"
                        self.myLblPickup.text = "\(NSLocalizedString("In", comment: "")) \(String(describing:self.groceryInfoModel?.vendorInfo?.preparingTime ?? "")) \(NSLocalizedString("mins", comment: "")) - \(String(describing: self.groceryInfoModel?.vendorInfo?.vendorDistance ?? "")) km"
                        self.myViewPickup.isHidden = false
                        self.myViewDelivery.isHidden = false
                    }else{
                        self.myViewOrderTypeCommon.isHidden = false
                        if self.groceryInfoModel?.vendorInfo?.pickup == "1"{
                            orderType = "2"
                            self.myLblOrderType.text = NSLocalizedString("Pickup", comment: "")
                            self.myLblOrderTypeInfo.text = "\(NSLocalizedString("In", comment: "")) \(String(describing:self.groceryInfoModel?.vendorInfo?.preparingTime ?? "")) \(NSLocalizedString("mins", comment: "")) - \(String(describing: self.groceryInfoModel?.vendorInfo?.vendorDistance ?? "")) km"
                        }else{
                            orderType = "1"
                            self.myLblOrderType.text = NSLocalizedString("Delivery", comment: "")
                            self.myLblOrderTypeInfo.text = "\(NSLocalizedString("In", comment: "")) \(String(describing:self.groceryInfoModel?.vendorInfo?.deliveryTime ?? "")) \(NSLocalizedString("mins", comment: "")) - \(String(describing: self.groceryInfoModel?.vendorInfo?.deliveryCharge ?? ""))"
                        }
                    }
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }
                } else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_GROCERY)
                }
                self.myCollCategory.dataSource = self
                self.myCollCategory.delegate = self
                self.myCollCategory.reloadData()
               self.myScrollView.addSubview(self.myViewContainer)
               self.myViewContainer.frame.origin.y = 0
               self.myViewContainer.translatesAutoresizingMaskIntoConstraints = true
               self.myScrollView.contentSize.height = self.myViewContainer.frame.size.height + 10
            } catch {
                print(error.localizedDescription)
            }
            HELPER.hideLoadingAnimation()
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func setupUI(){
        self.myViewOrderTypeCommon.layer.cornerRadius = self.myViewOrderTypeCommon.frame.size.height / 2
        self.myViewOrderType.layer.cornerRadius = self.myViewOrderType.frame.size.height / 2
        self.myViewPickup.layer.cornerRadius = self.myViewPickup.frame.size.height / 2
        self.myViewDelivery.layer.cornerRadius = self.myViewDelivery.frame.size.height / 2
        self.myViewOrderType.backgroundColor = ConfigTheme.customLightGray2
        self.myViewNoProduct.isHidden = true
        self.myViewCategory.isHidden = true
        self.myLblAmount.textAlignment = isRTLenabled == true ? .left : .right
        self.myViewSearch.layer.cornerRadius = 8
        self.myViewSearch.layer.borderWidth = 1
        self.myViewSearch.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myCollCategory.register(UINib(nibName: "GroceryCategoryCollCell", bundle: nil), forCellWithReuseIdentifier: "groceryCategoryCell")
    }
    
    //MARK: Button action
    @IBAction func clickBack(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickSearch(_ sender : Any){
        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: ProductSearchVc.storyboardID) as! ProductSearchVc
        aViewController.vendorId = self.groceryInfoModel?.vendorInfo?.vendorID ?? ""
        aViewController.pageType = "grocery"
        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickViewBasket(_ sender: UIButton){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CartVc.storyboardID) as! CartVc
        navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickPickup(_ sender : Any){
        orderType = "2"
        self.callGetGroceyInfoApi()
    }
    
    @IBAction func clickDelivery(_ sender : Any){
        orderType = "1"
        self.callGetGroceyInfoApi()
    }
}

extension GroceryInfoVc: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let categoryCount = self.groceryInfoModel?.category?.count ?? 0
        return categoryCount >= 12 ? 12 : categoryCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groceryCategoryCell", for: indexPath) as! GroceryCategoryCollCell
        if indexPath.row == 11{
            cell.myImgCategoryMore.image = UIImage(named: "ic_grid")
            cell.myImgCategory.image = nil
            cell.myLblCategory.text = NSLocalizedString("View all Category", comment: "")
        }else{
            cell.myImgCategoryMore.image = nil
            cell.myLblCategory.text = self.groceryInfoModel?.category?[indexPath.row].name
            let imageUrl = self.groceryInfoModel?.category?[indexPath.row].picture
            let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: .medium)
            activityLoader.center = cell.myImgCategory.center
            activityLoader.startAnimating()
            cell.myImgCategory.addSubview(activityLoader)
            cell.myImgCategory.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                if image != nil
                {
                    activityLoader.stopAnimating()
                }
                else
                {
                    print("image not found")
                    cell.myImgCategory.image = UIImage(named: "no_image")
                    activityLoader.stopAnimating()
                }
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 11{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryCategoryVc.storyboardID) as! GroceryCategoryVc
            aViewController.completion = { [weak self] categoryData in
                guard self != nil else {
                    return
                }
                let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryProductListVc.storyboardID) as! GroceryProductListVc
                aViewController.categoryListModel = self?.groceryInfoModel?.category ?? []
                aViewController.vendorId = self?.groceryInfoModel?.vendorInfo?.vendorID ?? ""
                aViewController.categorySelectedIndex = categoryData.selectedCategory ?? 0
                self?.navigationController?.pushViewController(aViewController, animated: true)
            }
            aViewController.categoryModel = self.groceryInfoModel?.category ?? []
            present(aViewController, animated: true)
        }else{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryProductListVc.storyboardID) as! GroceryProductListVc
            aViewController.categoryListModel = self.groceryInfoModel?.category ?? []
            aViewController.categorySelectedIndex = indexPath.row
            aViewController.vendorId = self.groceryInfoModel?.vendorInfo?.vendorID ?? ""
            self.navigationController?.pushViewController(aViewController, animated: true)
        }
    }
}

extension GroceryInfoVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width / 4) - 20
        return CGSize(width: width, height: width + 30)
    }
}
