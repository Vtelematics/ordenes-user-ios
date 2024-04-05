
import UIKit

class ProductSearchVc: UIViewController {
    
    @IBOutlet var myTblProducts : UITableView!
    @IBOutlet var myViewSearchText : UIView!
    @IBOutlet var myTxtSearch : UITextField!
    @IBOutlet var myBtnClear : UIButton!
    
    var addToCartParameters = [String : Any]()
    var vendorId = ""
    var vendorStatus = ""
    var vendorName = ""
    var pageType = ""
    var MainCategoryModel:[Category] = []
    var CategoryModel:[Category] = []
    var searchedProducts : [GroceryProduct] = []
    
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "20"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print(vendorId)
    }
    
    //MARK: Functions
    func setupUI(){
        self.myTxtSearch.textAlignment = isRTLenabled == true ? .right : .left
        self.myViewSearchText.layer.cornerRadius = 6
        self.myViewSearchText.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myViewSearchText.layer.borderWidth = 0.6
        self.myTblProducts.register(UINib(nibName: "SearchProductTblCell", bundle: nil), forCellReuseIdentifier: "productSearchCell")
        if pageType == "grocery"{
            self.searchedProducts = []
        }else{
            self.CategoryModel = self.MainCategoryModel
        }
        self.myTxtSearch.delegate = self
        self.myTblProducts.delegate = self
        self.myTblProducts.dataSource = self
        self.myTblProducts.reloadData()
        self.myTxtSearch.becomeFirstResponder()
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
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
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
                            self.searchedProducts[index.item] = modelData
                            let indexPath = IndexPath(item: index.item, section: 0)
                            self.myTblProducts.reloadRows(at: [indexPath], with: .none)
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
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_CART_ID] = cartId
        aDictParameters[K_PARAMS_TYPE] = type
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
                        self.searchedProducts[index.item] = modelData
                        let indexPath = IndexPath(item: index.item, section: 0)
                        self.myTblProducts.reloadRows(at: [indexPath], with: .none)
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
    
    func loginSuccess() {
        self.callAddToCartAPI()
    }
    
    func loginFailure() {
        
    }
    
    func callAddToCartAPI(){
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
                    self.getProductList(searchTextField: self.myTxtSearch)
                    if let product = response["product_info"] as? [String:Any] {
                        let jsonData = try JSONSerialization.data(withJSONObject: product, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(GroceryProduct.self, from: jsonData)
                        self.searchedProducts[addToCartParameters[K_PARAMS_SELECTED_ID] as! Int] = modelData
                        let indexPath = IndexPath(item: addToCartParameters[K_PARAMS_SELECTED_ID] as! Int, section: 0)
                        self.myTblProducts.reloadRows(at: [indexPath], with: .none)
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
    
    func searchWithProductName(productName:String)
    {
        CategoryModel.removeAll()
        CategoryModel = MainCategoryModel.map({
            var temp = $0
            temp.product = temp.product?.filter({ ($0.itemName?.uppercased().contains(productName.uppercased()))! })
            return temp
        })
        CategoryModel = CategoryModel.filter({ !($0.product?.isEmpty ?? false) })
        self.myTblProducts.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView == myTblProducts{
            let offset: CGPoint = scrollView.contentOffset
            let bounds: CGRect = scrollView.bounds
            let size: CGSize = scrollView.contentSize
            let inset: UIEdgeInsets = scrollView.contentInset
            let y = Float(offset.y + bounds.size.height - inset.bottom)
            let h = Float(size.height)
            let reload_distance: Float = 10
            if y > h + reload_distance
            {
                if isScrolledOnce == false && pageType == "grocery"
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
        if page <= Int(self.pageCount)
        {
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            var aDictParameters = [String : Any]()
            aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
            aDictParameters[K_PARAMS_PAGE] = page
            aDictParameters[K_PARAMS_LIMIT] = limit
            aDictParameters[K_PARAMS_CATEGORY_ID] = ""
            aDictParameters[K_PARAMS_SUB_CATEGORY_ID] = ""
            aDictParameters[K_PARAMS_SEARCH] = self.myTxtSearch.text!
            aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
            aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
            aDictParameters[K_PARAMS_TYPE] = "1"
            let dayId = Date().dayNumberOfWeek()
            aDictParameters[K_PARAMS_DAY_ID] = dayId
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_GROCERY_PRODUCT, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
                do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(GrocerySearchProductModel.self, from: jsonData)
                        self.searchedProducts.append(contentsOf: modelData.product ?? [])
                        self.myTblProducts.reloadData()
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
            self.isScrolledOnce = false
        }
    }
    
    //MARK: Button action
    @IBAction func clickCancel(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickClear(_ sender: Any){
        self.myTxtSearch.text = ""
        self.myBtnClear.isHidden = true
        self.CategoryModel = MainCategoryModel
        self.searchedProducts = []
        self.myTblProducts.reloadData()
    }
    
}

extension ProductSearchVc : UITextFieldDelegate{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            self.myBtnClear.isHidden = txtAfterUpdate == "" ? true : false
            if pageType == "grocery"{
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getProductList), object: textField)
                self.perform(#selector(self.getProductList), with: textField, afterDelay: 0.5)
            }else{
                if txtAfterUpdate.count > 0{
                    searchWithProductName(productName: txtAfterUpdate)
                }else if txtAfterUpdate == ""{
                    self.CategoryModel = MainCategoryModel
                    self.myTblProducts.reloadData()
                }
            }
        }
        return true
    }
    
    @objc func getProductList(searchTextField: UITextField) {
        page = 1
        if searchTextField.text == ""{
            self.searchedProducts = []
            self.myTblProducts.reloadData()
        }else{
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            let dayId = Date().dayNumberOfWeek()
            var aDictParameters = [String : Any]()
            aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
            aDictParameters[K_PARAMS_PAGE] = page
            aDictParameters[K_PARAMS_LIMIT] = limit
            aDictParameters[K_PARAMS_CATEGORY_ID] = ""
            aDictParameters[K_PARAMS_SUB_CATEGORY_ID] = ""
            aDictParameters[K_PARAMS_SEARCH] = searchTextField.text!
            aDictParameters[K_PARAMS_DAY_ID] = dayId
            aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
            aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
            aDictParameters[K_PARAMS_TYPE] = "1"
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_GROCERY_PRODUCT, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
                do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(GrocerySearchProductModel.self, from: jsonData)
                        self.searchedProducts = modelData.product ?? []
                        let total = modelData.total
                        self.pageCount = Double(Int(total ?? "0")!/Int(self.limit)!)
                        if aDictInfo["error"] != nil{
                            let error = aDictInfo["error"] as! [String: String]
                            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                        }
                    } else {
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_PRODUCTS)
                    }
                    self.myTblProducts.dataSource = self
                    self.myTblProducts.delegate = self
                    self.myTblProducts.reloadData()
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
}

extension ProductSearchVc: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if pageType == "grocery"{
            return 1
        }else{
            return CategoryModel.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if pageType == "grocery"{
            return self.searchedProducts.count
        }else{
            return CategoryModel[section].product?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:SearchProductTblCell = self.myTblProducts.dequeueReusableCell(withIdentifier: "productSearchCell") as! SearchProductTblCell
        if pageType == "grocery"{
            if let qty = self.searchedProducts[indexPath.row].cartQuantity, qty != ""{
                cell.lblQuantity.text = qty
                cell.viewAdd1.isHidden = false
                cell.viewAdd2.isHidden = true
            }else{
                cell.viewAdd1.isHidden = true
                cell.viewAdd2.isHidden = false
            }
            cell.lblProductName.text = self.searchedProducts[indexPath.row].itemName
            cell.lblPrice.text = ""
            if var discount = self.searchedProducts[indexPath.section].discount, discount != ""{
                discount = discount + " "
                let multipleAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 14.0) ?? "",
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
                let myAttrStringDiscount = NSMutableAttributedString(string: discount , attributes: multipleAttributes)
                let price = self.searchedProducts[indexPath.section].price ?? ""
                let multipleAttributes2: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 14.0) ?? "",
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
                let myAttrStringPrice = NSMutableAttributedString(string: price , attributes: multipleAttributes2)
                myAttrStringPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, myAttrStringPrice.length))
                myAttrStringDiscount.append(myAttrStringPrice)
                cell.lblProductDesc.attributedText = myAttrStringDiscount
            }else{
                cell.lblProductDesc.text = self.searchedProducts[indexPath.section].price
                cell.lblProductDesc.font = UIFont(name: "Poppins-Medium", size: 14.0)
            }
            let imageUrl =  self.searchedProducts[indexPath.row].picture
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
            cell.btnAdd.addTarget(self, action: #selector(self.clickAdd(_:)), for: .touchUpInside)
            cell.btnInc.addTarget(self, action: #selector(self.clickInc(_:)), for: .touchUpInside)
            cell.btnDec.addTarget(self, action: #selector(self.clickDec(_:)), for: .touchUpInside)
            cell.btnAdd.tag = indexPath.row
            cell.btnInc.tag = indexPath.row
            cell.btnDec.tag = indexPath.row
        }else{
            cell.lblProductName.text = CategoryModel[indexPath.section].product?[indexPath.row].itemName
            if let priceStatus = CategoryModel[indexPath.section].product?[indexPath.row].priceStatus, priceStatus == "1"{
                if var discount = CategoryModel[indexPath.section].product?[indexPath.row].discount, discount != ""{
                    discount = discount + " "
                    let multipleAttributes: [NSAttributedString.Key : Any] = [
                        NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 14.0) ?? "",
                        NSAttributedString.Key.foregroundColor: UIColor.gray,
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
                }
            }else{
                cell.lblPrice.text = NSLocalizedString("Price on selection", comment: "")
            }
            cell.lblProductDesc.text = CategoryModel[indexPath.section].product?[indexPath.row].productDescription
            let imageUrl =  CategoryModel[indexPath.section].product?[indexPath.row].image
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 132
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if pageType == "grocery"{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryProductInfoVc.storyboardID) as! GroceryProductInfoVc
            aViewController.vendorId = vendorId
            aViewController.productId = self.searchedProducts[indexPath.row].productItemID ?? ""
            self.navigationController?.pushViewController(aViewController, animated: true)
        }else{
            let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: ProductDetailVc.storyboardID) as! ProductDetailVc
            aViewController.productModel = CategoryModel[indexPath.section].product?[indexPath.row]
            aViewController.vendorId = vendorId
            aViewController.vendorName = vendorName
            aViewController.vendorStatus = vendorStatus
            print(vendorId)
            self.navigationController?.pushViewController(aViewController, animated: true)
        }
        
    }
    
    @objc func clickAdd(_ sender: UIButton){
        addToCartParameters.removeAll()
        var productsDict = [String : Any]()
        productsDict[K_PARAMS_PRODUCT_ID] = self.searchedProducts[sender.tag].productItemID
        productsDict[K_PARAMS_QUANTITY] = "1"
        productsDict[K_PARAMS_OPTION] = []
        var productsArray = [[String : Any]]()
        productsArray.append(productsDict)
        let dayId = Date().dayNumberOfWeek()
        self.addToCartParameters[K_PARAMS_LAT] = globalLatitude
        self.addToCartParameters[K_PARAMS_LONG] = globalLongitude
        self.addToCartParameters[K_PARAMS_VENDOR_ID] = vendorId
        self.addToCartParameters[K_PARAMS_PRODUCTS] = productsArray
        self.addToCartParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        self.addToCartParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        self.addToCartParameters[K_PARAMS_DAY_ID] = dayId
        self.addToCartParameters[K_PARAMS_SELECTED_ID] = sender.tag
        self.addToCartParameters[K_PARAMS_LANGUAGE_ID] = languageID
        self.callAddToCartAPI()
    }
    
    @objc func clickInc(_ sender: UIButton){
        guard let cartId = self.searchedProducts[sender.tag].cartId else { return }
        let indexPath = IndexPath(item: sender.tag, section: 0)
        self.callPostIncrementDecrement(cartId: cartId, type: "1", index: indexPath)
    }
    
    @objc func clickDec(_ sender: UIButton){
        if self.searchedProducts[sender.tag].cartQuantity == "1"{
            HELPER.showAlertControllerIn(aViewController: self, aStrMessage: NSLocalizedString("Do you want ot remove this item?", comment: ""), okButtonTitle: NSLocalizedString("Delete", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { (okAction) in
                let cartId = self.searchedProducts[sender.tag].cartId ?? "0"
                var id = [String]()
                id.append(cartId)
                let indexPath = IndexPath(item: sender.tag, section: 0)
                self.callDeleteProducts(idList: id, clearType: "0", index: indexPath)
            } cancelActionBlock: { (cancelAction) in
                self.dismiss(animated: true)
            }
        }else{
            guard let cartId = self.searchedProducts[sender.tag].cartId else { return }
            let indexPath = IndexPath(item: sender.tag, section: 0)
            self.callPostIncrementDecrement(cartId: cartId, type: "1", index: indexPath)
        }
    }
    
}
