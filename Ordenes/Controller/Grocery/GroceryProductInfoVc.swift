//
//  GroceryProductInfoVc.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 25/08/22.
//

import UIKit

class GroceryProductInfoVc: UIViewController, loginIntimation {
    
    @IBOutlet weak var myTblGroceryProductDetail: UITableView!
    @IBOutlet weak var myImgProduct: UIImageView!
    @IBOutlet weak var mylblProductTitle: UILabel!
    @IBOutlet weak var mylblProductPrice: UILabel!
    @IBOutlet weak var mylblProductDescription: UILabel!
    @IBOutlet weak var myBtnAddToBasket: UIButton!
    @IBOutlet weak var myBtnMore: UIButton!
    
    var groceryProductInfoModel : Product?
    var vendorId = ""
    var productId = ""
    var minProductQuantity = ""
    var incrementQuantity = 1
    var cartOptionIndex = ""
    var cellHeight : CGFloat = 0
    var isLabelAtMaxHeight = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: API Call
    
    func callGetGroceryProductInfoApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
        aDictParameters[K_PARAMS_PRODUCT_ID] = productId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_GROCERY_PRODUCT_INFO, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            
           do {
               print(response)
               let aDictInfo = response as! [String : Any]
               if aDictInfo.count != 0 {
                   let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                   let modelData = try! JSONDecoder().decode(GroceryProductInfoModel.self, from: jsonData)
                   self.groceryProductInfoModel = modelData.product

                   if aDictInfo["error"] != nil{
                       let error = aDictInfo["error"] as! [String: String]
                       HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                   }
                   HELPER.hideLoadingAnimation()
               } else {
                   HELPER.hideLoadingAnimation()
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_PRODUCTS)
               }
               self.myTblGroceryProductDetail.dataSource = self
               self.myTblGroceryProductDetail.delegate = self
               self.myTblGroceryProductDetail.reloadData()
            } catch {
                HELPER.hideLoadingAnimation()
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callPostProductsToCart() {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        
        let valuesForAPI1:[String:AnyObject] = [:]
        var productsDict = [String : Any]()
        productsDict["product_id"] = groceryProductInfoModel?.productItemID
        productsDict["quantity"] = incrementQuantity
        productsDict["option"] = valuesForAPI1
        print(productsDict)
        let dayId = Date().dayNumberOfWeek()
        var productsArray = [[String : Any]]()
        productsArray.append(productsDict)
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
        aDictParameters[K_PARAMS_PRODUCTS] = productsArray
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_PRODUCTS, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { [self] (response) in
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
                   HELPER.showAlertControllerWithOkActionBlock(aViewController: self, aStrMessage: success["message"] as! String, okActionBlock: { (okAction) in
                       self.navigationController?.popViewController(animated: true)
                   })
               }else{
                   if success["status"] as! String == "007"{
                       HELPER.showAlertControllerIn(aViewController: self, aStrMessage: response["error_warning"] as! String, okButtonTitle: NSLocalizedString("Agree", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { (okAction) in
                           self.callDeleteProducts()
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
    
    func callDeleteProducts() {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_CLEAR] = "1"
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
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
                   callPostProductsToCart()
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
    
    func setupUI() {
        callGetGroceryProductInfoApi()
    }
    
    func loginSuccess() {
        callPostProductsToCart()
    }
    
    func loginFailure() {
        
    }
    
    
    //MARK: Button action
    @IBAction func clickAddToBasket(_ sender: UIButton) {
        self.callPostProductsToCart()
    }
    
    @IBAction func clickViewBasket(_ sender: UIButton){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CartVc.storyboardID) as! CartVc
        navigationController?.pushViewController(aViewController, animated: true)
    }
    
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GroceryProductInfoVc: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell:ProductDetailTableViewCell = self.myTblGroceryProductDetail.dequeueReusableCell(withIdentifier: "productImageCell") as! ProductDetailTableViewCell
            let imageUrl =  groceryProductInfoModel?.picture
            let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
            activityLoader.center = cell.imgProduct.center
            activityLoader.startAnimating()
            cell.imgProduct.addSubview(activityLoader)
            cell.imgProduct.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
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
            return cell
        }else{
            let cell:ProductDetailTableViewCell = self.myTblGroceryProductDetail.dequeueReusableCell(withIdentifier: "productTitleCell") as! ProductDetailTableViewCell
            cell.lblProductName.text = groceryProductInfoModel?.itemName
            cell.lblProductDes.text = groceryProductInfoModel?.productDescription
            
            if groceryProductInfoModel?.discount != "" {
                let discount = (groceryProductInfoModel?.discount ?? "") + " "
                let multipleAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 14.0) ?? "",
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
                let myAttrStringDiscount = NSMutableAttributedString(string: discount , attributes: multipleAttributes)
                let price = groceryProductInfoModel?.price ?? ""
                let multipleAttributes2: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 14.0) ?? "",
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
                let myAttrStringPrice = NSMutableAttributedString(string: price , attributes: multipleAttributes2)
                myAttrStringPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, myAttrStringPrice.length))
                myAttrStringDiscount.append(myAttrStringPrice)
                cell.lblPrice.attributedText = myAttrStringDiscount
            }else{
                cell.lblPrice.text = groceryProductInfoModel?.price
            }
            cell.lblPrice.textAlignment = isRTLenabled == true ? .right : .left
//
//            if groceryProductInfoModel?.discount != "" {
//                cell.lblPrice.text = groceryProductInfoModel?.discount
//                cell.lblPrice.sizeToFit()
//                cell.lblPrice.translatesAutoresizingMaskIntoConstraints = true
//
//                cell.lblStrikePrice.text = groceryProductInfoModel?.price
//
//                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: groceryProductInfoModel?.price ?? "")
//                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
//                cell.lblStrikePrice.attributedText = attributeString
//
//                cell.lblStrikePrice.frame.origin.x = cell.lblPrice.frame.origin.x + cell.lblPrice.frame.size.width + 8
//                cell.lblStrikePrice.sizeToFit()
//                cell.lblStrikePrice.translatesAutoresizingMaskIntoConstraints = true
//
//            }else {
//                cell.lblPrice.text = groceryProductInfoModel?.price
//            }
            
            cell.lblQuantity.text = "\(incrementQuantity)"
            cell.lblProductDes.sizeToFit()
            cell.lblProductDes.frame.size.width = cell.lblProductName.frame.size.width
            cell.lblProductDes.translatesAutoresizingMaskIntoConstraints = true
            cellHeight = cell.lblProductDes.frame.origin.y + cell.lblProductDes.frame.size.height + 75
            cell.btnIncrease.addTarget(self, action: #selector(self.increaseQuantity(_:)), for: .touchUpInside)
            cell.btnDecrease.addTarget(self, action: #selector(self.decreaseQuantity(_:)), for: .touchUpInside)
            cell.btnIncrease.tag = indexPath.row
            cell.btnDecrease.tag = indexPath.row
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 310
        }else{
            return cellHeight
        }
    }
    
    @objc func increaseQuantity(_ sender:AnyObject!)
    {
        if incrementQuantity >= 1 {
            incrementQuantity = incrementQuantity + 1
            self.myTblGroceryProductDetail.reloadData()
        }
    }

    @objc func decreaseQuantity(_ sender:AnyObject!)
    {
        if incrementQuantity > 1 {
            incrementQuantity = incrementQuantity - 1
            self.myTblGroceryProductDetail.reloadData()
        }else {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Minimum Quantity should be Atleast ", comment: "") + minProductQuantity)
        }
    }
}
