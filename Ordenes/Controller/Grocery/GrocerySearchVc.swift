//
//  GrocerySearchVc.swift
//  Talabat clone
//
//  Created by Adyas infotech on 21/09/22.
//

import UIKit

class GrocerySearchVc: UIViewController {
    
    @IBOutlet var myTblSearch: UITableView!
    @IBOutlet weak var myViewSearch: UIView!
    @IBOutlet weak var myViewSearchClear: UIView!
    @IBOutlet weak var myTxtSearch: UITextField!
    @IBOutlet weak var myBtnGrocery: UIButton!
    @IBOutlet weak var myBtnProduct: UIButton!
    
    var grocerySearchModel = [AllRestroVendor]()
    var productSearchModel = [GroceryProduct]()
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "20"
    var pageType = "grocery"
    var addToCartParameters = [String : Any]()
    var vendorId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: API Calls
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
        aDictParameters[K_PARAMS_VENDOR_ID] = self.productSearchModel[index.item].vendorData?.vendorId
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_DELETE_PRODUCTS, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { [self] (response) in
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
                    HELPER.hideLoadingAnimation()
                    if clearType == "1"{
                        self.callAddToCartAPI()
                    }else{
                        if let product = response["product_info"] as? [String:Any] {
                            let jsonData = try JSONSerialization.data(withJSONObject: product, options: .prettyPrinted)
                            let modelData = try! JSONDecoder().decode(GroceryProduct.self, from: jsonData)
                            self.productSearchModel[index.item] = modelData
                            let indexPath = IndexPath(item: index.item, section: 0)
                            self.myTblSearch.reloadRows(at: [indexPath], with: .none)
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
                    if let product = response["product_info"] as? [String:Any] {
                        let jsonData = try JSONSerialization.data(withJSONObject: product, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(GroceryProduct.self, from: jsonData)
                        self.productSearchModel[index.item] = modelData
                        let indexPath = IndexPath(item: index.item, section: 0)
                        self.myTblSearch.reloadRows(at: [indexPath], with: .none)
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
    
    func callAddToCartAPI(){
        print(addToCartParameters)
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_PRODUCTS, isAuthorize: true, dictParameters: addToCartParameters, aController: self, sucessBlock: { [self] (response) in
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
                    HELPER.hideLoadingAnimation()
                    if let product = response["product_info"] as? [String:Any] {
                        let jsonData = try JSONSerialization.data(withJSONObject: product, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(GroceryProduct.self, from: jsonData)
                        self.productSearchModel[addToCartParameters[K_PARAMS_SELECTED_ID] as! Int] = modelData
                        let indexPath = IndexPath(item: addToCartParameters[K_PARAMS_SELECTED_ID] as! Int, section: 0)
                        self.myTblSearch.reloadRows(at: [indexPath], with: .none)
                    }
                }else{
                    if success["status"] as! String == "007"{
                        HELPER.hideLoadingAnimation()
                        HELPER.showAlertControllerIn(aViewController: self, aStrMessage: response["error_warning"] as! String, okButtonTitle: NSLocalizedString("Agree", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { (okAction) in
                            let indexPath = IndexPath(item: self.addToCartParameters[K_PARAMS_SELECTED_ID] as! Int, section: 0)
                            self.callDeleteProducts(idList: [], clearType: "1", index: indexPath)
                        } cancelActionBlock: { (cancelAction) in
                            self.dismiss(animated: true)
                        }
                    }else{
                        HELPER.hideLoadingAnimation()
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
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
    
    @objc func getGroceryList(searchTextField: UITextField) {
        page = 1
        if searchTextField.text == ""{
            self.grocerySearchModel = []
            self.myTblSearch.reloadData()
        }else{
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            let dayId = Date().dayNumberOfWeek()
            var aDictParameters = [String : Any]()
            aDictParameters[K_PARAMS_LAT] = globalLatitude
            aDictParameters[K_PARAMS_LONG] = globalLongitude
            aDictParameters[K_PARAMS_DAY_ID] = dayId
            aDictParameters[K_PARAMS_PAGE] = page
            aDictParameters[K_PARAMS_LIMIT] = limit
            aDictParameters[K_PARAMS_TYPE] = "1"
            aDictParameters[K_PARAMS_SEARCH] = searchTextField.text
            aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
            aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
            print(aDictParameters)
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_GROCERY_SEARCH_LISTING, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
               do {
                    let aDictInfo = response as! [String : Any]
                    print(aDictInfo)
                    if aDictInfo.count != 0 {
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(AllRestraurantModel.self, from: jsonData)
                        self.grocerySearchModel = modelData.vendorList ?? []
                        let total = modelData.total
                        self.pageCount = Double(Int(total ?? "0")!/Int(self.limit)!)
                        if aDictInfo["error"] != nil{
                            let error = aDictInfo["error"] as! [String: String]
                            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                        }
                    } else {
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_RESTAURANT)
                    }
                    self.myTblSearch.separatorStyle = .none
                    self.myTblSearch.dataSource = self
                    self.myTblSearch.delegate = self
                    self.myTblSearch.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
                HELPER.hideLoadingAnimation()
            }, failureBlock: { (errorResponse) in
                HELPER.hideLoadingAnimation()
                
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
            })
        }
    }
    
    @objc func getProductList(searchTextField: UITextField) {
        page = 1
        if searchTextField.text == ""{
            self.productSearchModel = []
            self.myTblSearch.reloadData()
        }else{
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            let dayId = Date().dayNumberOfWeek()
            var aDictParameters = [String : Any]()
            aDictParameters[K_PARAMS_VENDOR_ID] = ""
            aDictParameters[K_PARAMS_PAGE] = page
            aDictParameters[K_PARAMS_LIMIT] = limit
            aDictParameters[K_PARAMS_CATEGORY_ID] = ""
            aDictParameters[K_PARAMS_SUB_CATEGORY_ID] = ""
            aDictParameters[K_PARAMS_SEARCH] = searchTextField.text!
            aDictParameters[K_PARAMS_DAY_ID] = dayId
            aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
            aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
            aDictParameters[K_PARAMS_TYPE] = "2"
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_GROCERY_PRODUCT, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
                do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(GrocerySearchProductModel.self, from: jsonData)
                        self.productSearchModel = modelData.product ?? []
                        let total = modelData.total
                        self.pageCount = Double(Int(total ?? "0")!/Int(self.limit)!)
                        if aDictInfo["error"] != nil{
                            let error = aDictInfo["error"] as! [String: String]
                            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                        }
                    } else {
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_PRODUCTS)
                    }
                    self.myTblSearch.separatorStyle = .singleLine
                    self.myTblSearch.dataSource = self
                    self.myTblSearch.delegate = self
                    self.myTblSearch.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
                HELPER.hideLoadingAnimation()
            }, failureBlock: { (errorResponse) in
                HELPER.hideLoadingAnimation()
                
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
            })
        }
    }
    
    func pullToRefreshGrocery()
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
            aDictParameters[K_PARAMS_TYPE] = "1"
            aDictParameters[K_PARAMS_SEARCH] = self.myTxtSearch.text!
            aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
            aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_GROCERY_SEARCH_LISTING, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
               do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(AllRestraurantModel.self, from: jsonData)
                        self.grocerySearchModel.append(contentsOf: modelData.vendor ?? [])
                        self.myTblSearch.reloadData()
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
    
    func pullToRefreshProduct()
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
            aDictParameters[K_PARAMS_VENDOR_ID] = ""
            aDictParameters[K_PARAMS_PAGE] = page
            aDictParameters[K_PARAMS_LIMIT] = limit
            aDictParameters[K_PARAMS_CATEGORY_ID] = ""
            aDictParameters[K_PARAMS_SUB_CATEGORY_ID] = ""
            aDictParameters[K_PARAMS_SEARCH] = myTxtSearch.text!
            aDictParameters[K_PARAMS_DAY_ID] = dayId
            aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
            aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
            aDictParameters[K_PARAMS_TYPE] = "2"
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_GROCERY_PRODUCT, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
               do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(GrocerySearchProductModel.self, from: jsonData)
                        self.productSearchModel.append(contentsOf: modelData.product ?? [])
                        if aDictInfo["error"] != nil{
                            let error = aDictInfo["error"] as! [String: String]
                            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                        }
                        self.myTblSearch.reloadData()
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
        if scrollView == myTblSearch{
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
                    if pageType == "grocery"{
                        self.pullToRefreshGrocery()
                    }else{
                        self.pullToRefreshProduct()
                    }
                }
            }
        }
    }
    
    func loginSuccess() {
        self.callAddToCartAPI()
    }
    
    func setupUI(){
        self.myTblSearch.tableFooterView = UIView()
        self.myTblSearch.separatorStyle = .none
        self.myTxtSearch.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtSearch.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        self.myViewSearch.layer.cornerRadius = 8
        self.myViewSearch.layer.borderWidth = 0.5
        self.myTblSearch.register(UINib(nibName: "AllRestaurantTblCell", bundle: nil), forCellReuseIdentifier: "allRestaurantCell")
        self.myTblSearch.register(UINib(nibName: "SearchProductTblCell", bundle: nil), forCellReuseIdentifier: "productSearchCell")
        getGroceryList(searchTextField: self.myTxtSearch)
        self.myBtnGrocery.backgroundColor = ConfigTheme.themeColor
        self.myBtnGrocery.layer.borderColor = ConfigTheme.themeColor.cgColor
        self.myBtnGrocery.layer.borderWidth = 1
        self.myBtnGrocery.setTitleColor(.white, for: .normal)
        self.myBtnGrocery.layer.cornerRadius = 12
        self.myBtnProduct.backgroundColor = .white
        self.myBtnProduct.layer.borderColor = ConfigTheme.themeColor.cgColor
        self.myBtnProduct.layer.borderWidth = 1
        self.myBtnProduct.setTitleColor(ConfigTheme.themeColor, for: .normal)
        self.myBtnProduct.layer.cornerRadius = 12
    }
    
    //MARK: Button Action
    @IBAction func clickClearSearch(_ sender : Any){
        view.endEditing(true)
        self.myTxtSearch.text = ""
        self.myViewSearchClear.isHidden = true
        self.getGroceryList(searchTextField: self.myTxtSearch)
    }
    
    @IBAction func clickBack(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickGrocery(_ sender : Any){
        self.myBtnGrocery.backgroundColor = ConfigTheme.themeColor
        self.myBtnGrocery.layer.borderColor = ConfigTheme.themeColor.cgColor
        self.myBtnGrocery.layer.borderWidth = 1
        self.myBtnGrocery.setTitleColor(.white, for: .normal)
        self.myTxtSearch.placeholder = NSLocalizedString("Search Grocery", comment: "")
        self.myBtnProduct.backgroundColor = .white
        self.myBtnProduct.layer.borderColor = ConfigTheme.themeColor.cgColor
        self.myBtnProduct.layer.borderWidth = 1
        self.myBtnProduct.setTitleColor(ConfigTheme.themeColor, for: .normal)
        pageType = "grocery"
        getGroceryList(searchTextField: self.myTxtSearch)
    }
    
    @IBAction func clickProduct(_ sender : Any){
        self.myBtnProduct.backgroundColor = ConfigTheme.themeColor
        self.myBtnProduct.layer.borderColor = ConfigTheme.themeColor.cgColor
        self.myBtnProduct.layer.borderWidth = 1
        self.myBtnProduct.setTitleColor(.white, for: .normal)
        self.myTxtSearch.placeholder = NSLocalizedString("Search Products", comment: "")
        self.myBtnGrocery.backgroundColor = .white
        self.myBtnGrocery.layer.borderColor = ConfigTheme.themeColor.cgColor
        self.myBtnGrocery.layer.borderWidth = 1
        self.myBtnGrocery.setTitleColor(ConfigTheme.themeColor, for: .normal)
        pageType = "product"
        getProductList(searchTextField: self.myTxtSearch)
    }
}

extension GrocerySearchVc : UITextFieldDelegate{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            self.myViewSearchClear.isHidden = txtAfterUpdate == "" ? true : false
            if pageType == "grocery"{
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getGroceryList), object: textField)
                self.perform(#selector(self.getGroceryList), with: textField, afterDelay: 0.5)
            }else{
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getProductList), object: textField)
                self.perform(#selector(self.getProductList), with: textField, afterDelay: 0.5)
            }
        }
        return true
    }
}

extension GrocerySearchVc: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pageType == "grocery"{
            print(self.grocerySearchModel)
            return self.grocerySearchModel.count
        }else{
            return self.productSearchModel.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if pageType == "grocery"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "allRestaurantCell", for: indexPath) as! AllRestaurantTblCell
            cell.lblRestaurantName.text = self.grocerySearchModel[indexPath.row].name
            cell.lblRestaurantDesc.text = self.grocerySearchModel[indexPath.row].cuisines
            if let offer = self.grocerySearchModel[indexPath.row].offer, offer != ""{
                cell.lblRestaurantOffer.text = offer
                cell.imgOffer.isHidden = false
                cell.lblLine.isHidden = false
            }else{
                cell.lblRestaurantOffer.text = ""
                cell.imgOffer.isHidden = true
                cell.lblLine.isHidden = true
            }
            let imageUrl = self.grocerySearchModel[indexPath.row].logo
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
            if let rating = grocerySearchModel[indexPath.row].rating?.rating, rating != "" && rating != "0"{
                cell.viewRating.isHidden = false
                cell.lblRestaurantRating.text = grocerySearchModel[indexPath.row].rating?.vendorRatingName
                let imageUrl = grocerySearchModel[indexPath.row].rating?.vendorRatingImage
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
            if orderType == "2"{
                cell.lblRestaurantPreparingTime.text = (grocerySearchModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
                cell.viewPreparing.isHidden = false
            }else{
                if grocerySearchModel[indexPath.row].freeDelivery == "1"{
                    cell.lblRestaurantDeliveryCharge.text = NSLocalizedString("Free delivery", comment: "")
                }else{
                    cell.lblRestaurantDeliveryCharge.text = NSLocalizedString("Delivery", comment: "") + " - " + (self.grocerySearchModel[indexPath.row].deliveryCharge ?? "0")
                }
                cell.lblRestaurantDeliveryTime.text = (grocerySearchModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
                cell.viewPreparing.isHidden = true
            }
            let vendorStatus = self.grocerySearchModel[indexPath.row].vendorStatus
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
            return cell
        }else{
            let cell:SearchProductTblCell = self.myTblSearch.dequeueReusableCell(withIdentifier: "productSearchCell") as! SearchProductTblCell
            cell.lblProductName.text = self.productSearchModel[indexPath.row].itemName
            if let qty = self.productSearchModel[indexPath.row].cartQuantity, qty != ""{
                cell.lblQuantity.text = qty
                cell.viewAdd1.isHidden = false
                cell.viewAdd2.isHidden = true
            }else{
                cell.viewAdd1.isHidden = true
                cell.viewAdd2.isHidden = false
            }
            
            if var discount = self.productSearchModel[indexPath.section].discount, discount != ""{
                discount = discount + " "
                let multipleAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 14.0) ?? "",
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
                let myAttrStringDiscount = NSMutableAttributedString(string: discount , attributes: multipleAttributes)
                let price = self.productSearchModel[indexPath.section].price ?? ""
                let multipleAttributes2: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 14.0) ?? "",
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
                let myAttrStringPrice = NSMutableAttributedString(string: price , attributes: multipleAttributes2)
                myAttrStringPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, myAttrStringPrice.length))
                myAttrStringDiscount.append(myAttrStringPrice)
                cell.lblProductDesc.attributedText = myAttrStringDiscount
            }else{
                cell.lblProductDesc.text = self.productSearchModel[indexPath.section].price
                cell.lblProductDesc.font = UIFont(name: "Poppins-Medium", size: 14.0)
            }
            let imageUrl =  self.productSearchModel[indexPath.row].picture
            let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20")
            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: .medium)
            activityLoader.center = cell.imgProduct.center
            activityLoader.startAnimating()
            cell.imgProduct.addSubview(activityLoader)
            cell.imgProduct.sd_setImage(with: URL(string: trimmedUrl!), completed: { (image, error, imageCacheType, imageUrl) in
                if image != nil
                {
                    activityLoader.stopAnimating()
                }
                else
                {
                    print("image not found")
                    cell.imgProduct.image = UIImage(named: "no_image")
                    activityLoader.stopAnimating()
                }
            })
            let vendorStatus = self.productSearchModel[indexPath.row].vendorData?.vendorStatus
            if vendorStatus == "1"{
                cell.viewBusy.isHidden = true
            }else{
                if vendorStatus == "0"{
                    cell.lblStatus.text = NSLocalizedString("Closed", comment: "")
                }else if vendorStatus == "2"{
                    cell.lblStatus.text = NSLocalizedString("Busy", comment: "")
                }
                cell.viewBusy.isHidden = false
            }
            cell.btnAdd.addTarget(self, action: #selector(self.clickAdd(_:)), for: .touchUpInside)
            cell.btnInc.addTarget(self, action: #selector(self.clickInc(_:)), for: .touchUpInside)
            cell.btnDec.addTarget(self, action: #selector(self.clickDec(_:)), for: .touchUpInside)
            cell.btnAdd.tag = indexPath.row
            cell.btnInc.tag = indexPath.row
            cell.btnDec.tag = indexPath.row
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if pageType == "grocery"{
            if let offer = self.grocerySearchModel[indexPath.row].offer, offer != ""{
                return 186
            }else{
                return 147
            }
        }else{
            return 132
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pageType == "grocery"{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
            aViewController.vendorId = self.grocerySearchModel[indexPath.row].vendorID ?? ""
            self.navigationController?.pushViewController(aViewController, animated: true)
        }else{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryProductInfoVc.storyboardID) as! GroceryProductInfoVc
            aViewController.vendorId = self.productSearchModel[indexPath.row].vendorData?.vendorId ?? ""
            aViewController.productId = self.productSearchModel[indexPath.row].productItemID ?? ""
            self.navigationController?.pushViewController(aViewController, animated: true)
        }
    }
    
    @objc func clickAdd(_ sender: UIButton){
        if self.productSearchModel[sender.tag].vendorData?.vendorStatus == "0"{
            let alert = NSLocalizedString("\(self.productSearchModel[sender.tag].vendorData?.vendorName ?? "") is not available for \(self.productSearchModel[sender.tag].itemName ?? "") at this time. You can continue adding items to your basket and order when delivery service is resumed", comment: "")
            HELPER.showAlertControllerIn(aViewController: self, aStrMessage: alert, okButtonTitle: NSLocalizedString("Ok", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { ok in
                self.addToCartParameters.removeAll()
                var productsDict = [String : Any]()
                productsDict[K_PARAMS_PRODUCT_ID] = self.productSearchModel[sender.tag].productItemID
                productsDict[K_PARAMS_QUANTITY] = "1"
                productsDict[K_PARAMS_OPTION] = []
                var productsArray = [[String : Any]]()
                productsArray.append(productsDict)
                let dayId = Date().dayNumberOfWeek()
                self.addToCartParameters[K_PARAMS_LAT] = globalLatitude
                self.addToCartParameters[K_PARAMS_LONG] = globalLongitude
                self.addToCartParameters[K_PARAMS_VENDOR_ID] = self.productSearchModel[sender.tag].vendorData?.vendorId
                self.addToCartParameters[K_PARAMS_PRODUCTS] = productsArray
                self.addToCartParameters[K_PARAMS_GUEST_STATUS] = guestStatus
                self.addToCartParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
                self.addToCartParameters[K_PARAMS_DAY_ID] = dayId
                self.addToCartParameters[K_PARAMS_SELECTED_ID] = sender.tag
                self.addToCartParameters[K_PARAMS_LANGUAGE_ID] = languageID
                self.callAddToCartAPI()
            } cancelActionBlock: { cancel in
                self.dismiss(animated: true)
            }
        }else{
            addToCartParameters.removeAll()
            var productsDict = [String : Any]()
            productsDict["product_id"] = self.productSearchModel[sender.tag].productItemID
            productsDict["quantity"] = "1"
            productsDict["option"] = []
            var productsArray = [[String : Any]]()
            productsArray.append(productsDict)
            let dayId = Date().dayNumberOfWeek()
            addToCartParameters[K_PARAMS_LAT] = globalLatitude
            addToCartParameters[K_PARAMS_LONG] = globalLongitude
            addToCartParameters[K_PARAMS_VENDOR_ID] = self.productSearchModel[sender.tag].vendorData?.vendorId
            addToCartParameters[K_PARAMS_PRODUCTS] = productsArray
            addToCartParameters[K_PARAMS_GUEST_STATUS] = guestStatus
            addToCartParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
            addToCartParameters[K_PARAMS_DAY_ID] = dayId
            addToCartParameters[K_PARAMS_SELECTED_ID] = sender.tag
            self.callAddToCartAPI()
        }
    }
    
    @objc func clickInc(_ sender: UIButton){
        guard let cartId = self.productSearchModel[sender.tag].cartId else { return }
        let indexPath = IndexPath(item: sender.tag, section: 0)
        self.callPostIncrementDecrement(cartId: cartId, type: "1", index: indexPath)
    }
    
    @objc func clickDec(_ sender: UIButton){
        if self.productSearchModel[sender.tag].cartQuantity == "1"{
            HELPER.showAlertControllerIn(aViewController: self, aStrMessage: NSLocalizedString("Do you want ot remove this item?", comment: ""), okButtonTitle: NSLocalizedString("Delete", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { (okAction) in
                let cartId = self.productSearchModel[sender.tag].cartId ?? "0"
                var id = [String]()
                id.append(cartId)
                let indexPath = IndexPath(item: sender.tag, section: 0)
                self.callDeleteProducts(idList: id, clearType: "0", index: indexPath)
            } cancelActionBlock: { (cancelAction) in
                self.dismiss(animated: true)
            }
        }else{
            guard let cartId = self.productSearchModel[sender.tag].cartId else { return }
            let indexPath = IndexPath(item: sender.tag, section: 0)
            self.callPostIncrementDecrement(cartId: cartId, type: "0", index: indexPath)
        }
    }
}
