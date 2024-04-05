//
//  GroceryProductListVc.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 24/08/22.
//

import UIKit

class GroceryProductListVc: UIViewController, loginIntimation {
    
    @IBOutlet weak var myViewSearch: UIView!
    @IBOutlet weak var myImgGrid: UIImageView!
    @IBOutlet weak var myViewProducts: UIView!
    @IBOutlet weak var myLblProductEmpty: UILabel!
    @IBOutlet var myCollCategory: UICollectionView!
    @IBOutlet var myCollSubCategory: UICollectionView!
    @IBOutlet var myCollProductList: UICollectionView!
    @IBOutlet var myViewCart : UIView!
    @IBOutlet var myLblCount : UILabel!
    @IBOutlet var myLblAmount : UILabel!
    @IBOutlet weak var myLblMinError : UILabel!
    @IBOutlet weak var myLblViewBasket : UILabel!
    
    var addToCartParameters = [String : Any]()
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "20"
    var vendorId = ""
    var vendor : GroceryVendor?
    var categorySelectedIndex = 0
    var subCategorySelectedIndex = 0
    var categoryListModel = [GroceryCategoryModel]()
    var subCategoryListModel = [SubCategory]()
    var groceryProductModel = [GroceryProduct]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callGetCartCount(completionBlock: {
            self.callGetSubCategoriesApi()
        })
    }
    
    //MARK: API calls
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
                       self.myCollProductList.contentInset = UIEdgeInsets(top: 0,
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
                       self.myCollProductList.contentInset = UIEdgeInsets(top: 0,
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
    
    func callGetSubCategoriesApi() {
        
        guard let selectedCatId = self.categoryListModel[categorySelectedIndex].categoryID else {return}
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
        aDictParameters[K_PARAMS_VENDOR_TYPE_ID] = "2"
        aDictParameters[K_PARAMS_CATEGORY_ID] = selectedCatId
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_SUB_CATEGORY, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
               let aDictInfo = response as! [String : Any]
               if aDictInfo.count != 0 {
                   let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                   let modelData = try! JSONDecoder().decode(SubCategoryListModel.self, from: jsonData)
                   self.subCategoryListModel = modelData.subCategory ?? []
                   
                   if self.subCategoryListModel.count != 0{
                       self.subCategorySelectedIndex = 0
                       self.callGetGroceryProductsApi()
                       self.myLblProductEmpty.isHidden = true
                   }else{
                       self.groceryProductModel = []
                       self.myCollProductList.dataSource = self
                       self.myCollProductList.delegate = self
                       self.myCollProductList.reloadData()
                       self.myLblProductEmpty.isHidden = false
                       self.myLblProductEmpty.text = NSLocalizedString("Sub category not available in this category", comment: "")
                   }
                   if aDictInfo["error"] != nil{
                       let error = aDictInfo["error"] as! [String: String]
                       HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                   }
               } else {
                   
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_CATEGORY)
               }
               self.myCollSubCategory.dataSource = self
               self.myCollSubCategory.delegate = self
               self.myCollSubCategory.reloadData()
               if self.subCategoryListModel.count != 0{
                   self.myCollSubCategory.scrollToItem(at:IndexPath(item: self.subCategorySelectedIndex, section: 0), at: .left, animated: true)
               }
               
               HELPER.hideLoadingAnimation()
            } catch {
                HELPER.hideLoadingAnimation()
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callGetGroceryProductsApi() {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        page = 1
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
        aDictParameters[K_PARAMS_PAGE] = page
        aDictParameters[K_PARAMS_LIMIT] = limit
        aDictParameters[K_PARAMS_CATEGORY_ID] = self.categoryListModel[categorySelectedIndex].categoryID
        aDictParameters[K_PARAMS_SUB_CATEGORY_ID] = self.subCategoryListModel[subCategorySelectedIndex].subCategoryID
        aDictParameters[K_PARAMS_SEARCH] = ""
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_TYPE] = "1"
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_GROCERY_PRODUCT, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
               print(response)
               let aDictInfo = response as! [String : Any]
               if aDictInfo.count != 0 {
                   let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                   let modelData = try! JSONDecoder().decode(GrocerySearchProductModel.self, from: jsonData)
                   self.vendor = modelData.vendor
                   self.groceryProductModel = modelData.product ?? []
                   let total = modelData.total
                   self.pageCount = Double(Int(total ?? "0")!/Int(self.limit)!)
                   if self.groceryProductModel.count != 0{
                       self.myLblProductEmpty.isHidden = true
                   }else{
                       self.myLblProductEmpty.isHidden = false
                       self.myLblProductEmpty.text = NSLocalizedString("Product not available in this category", comment: "")
                   }
                   if aDictInfo["error"] != nil{
                       let error = aDictInfo["error"] as! [String: String]
                       HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                   }
                   HELPER.hideLoadingAnimation()
               } else {
                   HELPER.hideLoadingAnimation()
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_PRODUCTS)
               }
               
               self.myCollProductList.dataSource = self
               self.myCollProductList.delegate = self
               self.myCollProductList.setContentOffset(.zero, animated: false)
               self.myCollProductList.reloadData()
            } catch {
                HELPER.hideLoadingAnimation()
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callDeleteProducts(idList: [String], clearType: String, index: IndexPath) {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        if clearType == "1"{
            aDictParameters[K_PARAMS_CLEAR] = "1"
        }else{
            aDictParameters[K_PARAMS_CLEAR] = "0"
            aDictParameters[K_PARAMS_PRODUCT_CART_ID] = idList
        }
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_DELETE_PRODUCTS, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { [self] (response) in
           do {
               print(response)
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
                   HELPER.hideLoadingAnimation()
                   if clearType == "1"{
                       self.callAddToCartAPI()
                   }else{
                       if let product = response["product_info"] as? [String:Any] {
                           let jsonData = try JSONSerialization.data(withJSONObject: product, options: .prettyPrinted)
                           let modelData = try! JSONDecoder().decode(GroceryProduct.self, from: jsonData)
                           self.groceryProductModel[index.item] = modelData
                           let indexPath = IndexPath(item: index.item, section: 0)
                           self.myCollProductList.reloadItems(at: [indexPath])
                           self.callGetCartCount(completionBlock: {
                               //self.callGetGroceryProductsApi()
                           })
                       }
                   }
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
    
    func callPostIncrementDecrement(cartId: String, type: String, index: IndexPath) {
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_CART_ID] = cartId
        aDictParameters[K_PARAMS_TYPE] = type
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_INCREMENT_DECREMENT, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
           do {
               print(response)
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
                   if let product = response["product_info"] as? [String:Any] {
                       let jsonData = try JSONSerialization.data(withJSONObject: product, options: .prettyPrinted)
                       let modelData = try! JSONDecoder().decode(GroceryProduct.self, from: jsonData)
                       self.groceryProductModel[index.item] = modelData
                       let indexPath = IndexPath(item: index.item, section: 0)
                       self.myCollProductList.reloadItems(at: [indexPath])
                       self.callGetCartCount(completionBlock: {
                           //self.callGetGroceryProductsApi()
                       })
                   }
               }else{
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
    
    func loginSuccess() {
        self.callAddToCartAPI()
    }
    
    func loginFailure() {
        
    }
    
    func callAddToCartAPI(){
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_PRODUCTS, isAuthorize: true, dictParameters: addToCartParameters, aController: self, sucessBlock: { [self] (response) in
           do {
               print(response)
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
                   if let product = response["product_info"] as? [String:Any] {
                       let jsonData = try JSONSerialization.data(withJSONObject: product, options: .prettyPrinted)
                       let modelData = try! JSONDecoder().decode(GroceryProduct.self, from: jsonData)
                       self.groceryProductModel[addToCartParameters[K_PARAMS_SELECTED_ID] as! Int] = modelData
                       let indexPath = IndexPath(item: addToCartParameters[K_PARAMS_SELECTED_ID] as! Int, section: 0)
                       self.myCollProductList.reloadItems(at: [indexPath])
                       self.callGetCartCount(completionBlock: {
                           //self.callGetGroceryProductsApi()
                       })
                   }
               }else{
                   if success["status"] as! String == "007"{
                       HELPER.showAlertControllerIn(aViewController: self, aStrMessage: response["error_warning"] as! String, okButtonTitle: NSLocalizedString("Agree", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { (okAction) in
                           let indexPath = IndexPath(item: self.addToCartParameters[K_PARAMS_SELECTED_ID] as! Int, section: 0)
                           self.callDeleteProducts(idList: [], clearType: "1", index: indexPath)
                       } cancelActionBlock: { (cancelAction) in
                           self.dismiss(animated: true)
                       }
                   }else{
                       HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
                   }
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView == myCollProductList{
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
    
    func pullToRefresh()
    {
        if (self.isScrolledOnce == true)
        {
            return
        }
        self.isScrolledOnce = true
        print(page, pageCount)
        if page <= Int(self.pageCount)
        {
            print("\(page) time loading")
            page += 1
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            var aDictParameters = [String : Any]()
            let dayId = Date().dayNumberOfWeek()
            aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
            aDictParameters[K_PARAMS_PAGE] = page
            aDictParameters[K_PARAMS_LIMIT] = limit
            aDictParameters[K_PARAMS_CATEGORY_ID] = self.categoryListModel[categorySelectedIndex].categoryID
            aDictParameters[K_PARAMS_SUB_CATEGORY_ID] = self.subCategoryListModel[subCategorySelectedIndex].subCategoryID
            aDictParameters[K_PARAMS_SEARCH] = ""
            aDictParameters[K_PARAMS_DAY_ID] = dayId
            aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
            aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
            aDictParameters[K_PARAMS_TYPE] = "1"
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_GROCERY_PRODUCT, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
               do {
                    let aDictInfo = response as! [String : Any]
                    //print(aDictInfo)
                    if aDictInfo.count != 0 {
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(GrocerySearchProductModel.self, from: jsonData)
                        self.groceryProductModel.append(contentsOf: modelData.product ?? [])
                        self.myCollProductList.reloadData()
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
                self.isScrolledOnce = false
                HELPER.hideLoadingAnimation()
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
            })
        }
        else
        {
            self.isScrolledOnce = false
        }
    }
    
    func setupUI() {
        self.myLblAmount.textAlignment = isRTLenabled == true ? .left : .right
        self.myViewSearch.layer.cornerRadius = 8
        self.myViewSearch.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myViewSearch.layer.borderWidth = 0.8
        self.myImgGrid.image = self.myImgGrid.image!.withRenderingMode(.alwaysTemplate)
        self.myImgGrid.tintColor = ConfigTheme.themeColor
        self.myCollCategory.register(UINib(nibName: "ProductCategoryCollCell", bundle: nil), forCellWithReuseIdentifier: "productCatCell")
        self.myCollSubCategory.register(UINib(nibName: "ProductCategoryCollCell", bundle: nil), forCellWithReuseIdentifier: "productCatCell")
        self.myCollProductList.register(UINib(nibName: "GroceryProductInfoCollCell", bundle: nil), forCellWithReuseIdentifier: "groceryProductInfoCell")
        self.myCollCategory.dataSource = self
        self.myCollCategory.delegate = self
        self.myCollCategory.reloadData()
        if self.categoryListModel.count != 0{
            self.myCollCategory.scrollToItem(at:IndexPath(item: categorySelectedIndex, section: 0), at: .left, animated: true)
        }
    }
    
    //MARK: Button action
    @IBAction func clickSearch(_ sender: UIButton) {
        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: ProductSearchVc.storyboardID) as! ProductSearchVc
        aViewController.vendorId = vendorId
        aViewController.pageType = "grocery"
        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickCategory(_ sender: UIButton) {
        let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryCategoryVc.storyboardID) as! GroceryCategoryVc
        aViewController.completion = { [weak self] categoryData in
            guard self != nil else {
                return
            }
            self?.categorySelectedIndex = categoryData.selectedCategory ?? 0
            self?.myCollCategory.reloadData()
            self?.myCollCategory.scrollToItem(at:IndexPath(item: self?.categorySelectedIndex ?? 0, section: 0), at: .left, animated: true)
            self?.callGetSubCategoriesApi()
        }
        aViewController.categoryModel = self.categoryListModel
        present(aViewController, animated: true)
    }
    
    @IBAction func clickViewBasket(_ sender: UIButton){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CartVc.storyboardID) as! CartVc
        navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GroceryProductListVc: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == myCollCategory {
            return categoryListModel.count
        }else if collectionView == myCollSubCategory {
            return subCategoryListModel.count
        }else {
            return groceryProductModel.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == myCollCategory {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCatCell", for: indexPath as IndexPath) as! ProductCategoryCollCell
            cell.lblCategoryTitle.text = self.categoryListModel[indexPath.row].name
            if categorySelectedIndex == indexPath.row {
                cell.lblLine.isHidden = true
                cell.viewSelected.isHidden = false
                cell.lblCategoryTitle.font = UIFont(name: "Poppins-Regular", size: 14)
                cell.lblCategoryTitle.textColor = ConfigTheme.themeColor
            }else {
                cell.lblLine.isHidden = true
                cell.viewSelected.isHidden = true
                cell.lblCategoryTitle.font = UIFont(name: "Poppins-Regular", size: 14)
                cell.lblCategoryTitle.textColor = .black
            }
            return cell
        }else if collectionView == myCollSubCategory {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCatCell", for: indexPath as IndexPath) as! ProductCategoryCollCell
            cell.lblCategoryTitle.text = self.subCategoryListModel[indexPath.row].name
            if subCategorySelectedIndex == indexPath.row {
                cell.lblLine.isHidden = true
                cell.lblCategoryTitle.font = UIFont(name: "Poppins-Regular", size: 14)
                cell.lblCategoryTitle.layer.borderColor = ConfigTheme.themeColor.cgColor
                cell.lblCategoryTitle.layer.borderWidth = 1
                cell.lblCategoryTitle.backgroundColor = UIColor(named: "clr_light_red")
                cell.lblCategoryTitle.textColor = ConfigTheme.themeColor
                cell.lblCategoryTitle.layer.cornerRadius = 23
                cell.lblCategoryTitle.layer.masksToBounds = true
            }else {
                cell.lblLine.isHidden = true
                cell.lblCategoryTitle.font = UIFont(name: "Poppins-Regular", size: 14)
                cell.lblCategoryTitle.layer.borderColor = ConfigTheme.customLightGray.cgColor
                cell.lblCategoryTitle.layer.borderWidth = 1
                cell.lblCategoryTitle.backgroundColor = .white
                cell.lblCategoryTitle.textColor = .black
                cell.lblCategoryTitle.layer.cornerRadius = 23
                cell.lblCategoryTitle.layer.masksToBounds = true
            }
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groceryProductInfoCell", for: indexPath) as! GroceryProductInfoCollCell
            cell.mylblProductTitle.frame.size.width = cell.mylblProductPrice.frame.size.width
            print(self.groceryProductModel)
            cell.mylblProductTitle.text = self.groceryProductModel[indexPath.row].itemName
            //cell.mylblProductTitle.sizeToFit()
            //cell.mylblProductTitle.translatesAutoresizingMaskIntoConstraints = true
            
            if var discount = self.groceryProductModel[indexPath.row].discount, discount != ""{
                discount = discount + " "
                let multipleAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 15.0) ?? "",
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                ]
                let myAttrStringDiscount = NSMutableAttributedString(string: discount , attributes: multipleAttributes)
                let price = self.groceryProductModel[indexPath.row].price ?? ""
                let multipleAttributes2: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 15.0) ?? "",
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
                let myAttrStringPrice = NSMutableAttributedString(string: price , attributes: multipleAttributes2)
                myAttrStringPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, myAttrStringPrice.length))
                myAttrStringDiscount.append(myAttrStringPrice)
                cell.mylblProductPrice.attributedText = myAttrStringDiscount
            }else{
                cell.mylblProductPrice.text = self.groceryProductModel[indexPath.row].price
                cell.mylblProductPrice.font = UIFont(name: "Poppins-Medium", size: 15)
                cell.mylblProductPrice.textColor = .black
            }
            
            //cell.mylblProductPrice.frame.origin.y = cell.mylblProductTitle.frame.origin.y + cell.mylblProductTitle.frame.size.height + 2
            //cell.mylblProductPrice.translatesAutoresizingMaskIntoConstraints = true
            
            let imageUrl = self.groceryProductModel[indexPath.row].logo
            let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: .medium)
            activityLoader.center = cell.myImgProduct.center
            activityLoader.startAnimating()
            cell.myImgProduct.addSubview(activityLoader)
            cell.myImgProduct.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

                if image != nil
                {
                    activityLoader.stopAnimating()
                }
                else
                {
                    print("image not found")
                    cell.myImgProduct.image = UIImage(named: "no_image")
                    activityLoader.stopAnimating()
                }
            })
            
            if let qty = self.groceryProductModel[indexPath.row].cartQuantity, qty != ""{
                if qty == "1"{
                    cell.myImgDec.image = UIImage(named: "ic_delete")
                }else{
                    cell.myImgDec.image = UIImage(named: "ic_minus")
                }
                cell.myImgDec.image = cell.myImgDec.image!.withRenderingMode(.alwaysTemplate)
                cell.myImgDec.tintColor = ConfigTheme.themeColor
                cell.mylblQuantity1.text = self.groceryProductModel[indexPath.row].cartQuantity
                cell.myViewCart1.isHidden = false
            }else{
                cell.mylblQuantity1.text = nil
                cell.myViewCart1.isHidden = true
            }
            cell.myBtnAdd.addTarget(self, action: #selector(self.clickAdd(_:)), for: .touchUpInside)
            cell.myBtnInc.addTarget(self, action: #selector(self.clickInc(_:)), for: .touchUpInside)
            cell.myBtnDec.addTarget(self, action: #selector(self.clickDec(_:)), for: .touchUpInside)
            cell.myBtnAdd.tag = indexPath.row
            cell.myBtnInc.tag = indexPath.row
            cell.myBtnDec.tag = indexPath.row
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == myCollCategory {
            categorySelectedIndex = indexPath.row
            self.myCollCategory.reloadData()
            self.callGetSubCategoriesApi()
        }else if collectionView == myCollSubCategory {
            subCategorySelectedIndex = indexPath.row
            self.myCollSubCategory.reloadData()
            self.callGetGroceryProductsApi()
        }else {
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryProductInfoVc.storyboardID) as! GroceryProductInfoVc
            aViewController.vendorId = vendorId
            aViewController.productId = self.groceryProductModel[indexPath.row].productItemID ?? ""
            self.navigationController?.pushViewController(aViewController, animated: true)
        }
    }
    
    @objc func clickAdd(_ sender: UIButton){
        addToCartParameters.removeAll()
        var productsDict = [String : Any]()
        productsDict[K_PARAMS_PRODUCT_ID] = self.groceryProductModel[sender.tag].productItemID
        productsDict[K_PARAMS_QUANTITY] = "1"
        productsDict[K_PARAMS_OPTION] = []
        var productsArray = [[String : Any]]()
        productsArray.append(productsDict)
        let dayId = Date().dayNumberOfWeek()
        addToCartParameters[K_PARAMS_LAT] = globalLatitude
        addToCartParameters[K_PARAMS_LONG] = globalLongitude
        addToCartParameters[K_PARAMS_VENDOR_ID] = vendorId
        addToCartParameters[K_PARAMS_PRODUCTS] = productsArray
        addToCartParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        addToCartParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        addToCartParameters[K_PARAMS_DAY_ID] = dayId
        addToCartParameters[K_PARAMS_SELECTED_ID] = sender.tag
        addToCartParameters[K_PARAMS_LANGUAGE_ID] = languageID
        addToCartParameters[K_PARAMS_ORDER_TYPE] = orderType
        if self.vendor?.vendorStatus == "0"{
            let alert = NSLocalizedString("\(self.vendor?.vendorName ?? NSLocalizedString("grocery", comment: "")) is not available for \(self.groceryProductModel[sender.tag].itemName ?? "this product") at this time. You can continue adding items to your basket and order when delivery service is resumed", comment: "")
            HELPER.showAlertControllerIn(aViewController: self, aStrMessage: alert, okButtonTitle: NSLocalizedString("Ok", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { ok in
                self.callAddToCartAPI()
            } cancelActionBlock: { cancel in
                self.dismiss(animated: true)
            }
        }else{
            self.callAddToCartAPI()
        }
    }

    @objc func clickInc(_ sender: UIButton){
        guard let cartId = self.groceryProductModel[sender.tag].cartId else { return }
        let indexPath = IndexPath(item: sender.tag, section: 0)
        self.callPostIncrementDecrement(cartId: cartId, type: "1", index: indexPath)
    }
    
    @objc func clickDec(_ sender: UIButton){
        if self.groceryProductModel[sender.tag].cartQuantity == "1"{
            HELPER.showAlertControllerIn(aViewController: self, aStrMessage: NSLocalizedString("Do you want ot remove this item?", comment: ""), okButtonTitle: NSLocalizedString("Delete", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { (okAction) in
                let cartId = self.groceryProductModel[sender.tag].cartId ?? "0"
                var id = [String]()
                id.append(cartId)
                let indexPath = IndexPath(item: sender.tag, section: 0)
                self.callDeleteProducts(idList: id, clearType: "0", index: indexPath)
            } cancelActionBlock: { (cancelAction) in
                self.dismiss(animated: true)
            }
        }else{
            guard let cartId = self.groceryProductModel[sender.tag].cartId else { return }
            let indexPath = IndexPath(item: sender.tag, section: 0)
            self.callPostIncrementDecrement(cartId: cartId, type: "0", index: indexPath)
        }
    }
    
}

extension GroceryProductListVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == myCollCategory {
            return CGSize(width: 150, height: 50)
        }else if collectionView == myCollSubCategory {
            return CGSize(width: 150, height: 50)
        }else {
            let noOfCellsInRow = 2   //number of column you want
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
            
            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
            return CGSize(width: size, height: size + 50)
        }
    }
}
