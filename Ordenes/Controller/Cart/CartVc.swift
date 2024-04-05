//
//  CartVc.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 22/07/22.
//

import UIKit

class CartVc: UIViewController,loginIntimation {
    
    @IBOutlet var myTblCart : UITableView!
    @IBOutlet var myViewEmpty : UIView!
    @IBOutlet weak var myLblNavTitle: UILabel!
    @IBOutlet weak var myBtnAddItems: UIButton!
    @IBOutlet weak var myBtnCheckout: UIButton!

    var cellHeight: CGFloat = 0
    var cartModel : CartModel?
    var additionalNote = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.callGetCartItemsApi()
    }
    
    //MARK: API Call
    func callGetCartItemsApi() {
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        print(aDictParameters)
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_CART_PRODUCTS, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
           do {
               print(response)
               let aDictInfo = response as! [String : Any]
               if aDictInfo.count != 0 {
                   let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                   self.cartModel = try! JSONDecoder().decode(CartModel.self, from: jsonData)
                   self.myLblNavTitle.text = self.cartModel?.vendorName
                   if self.cartModel?.products == nil || self.cartModel?.products?.count == 0{
                       self.myTblCart.isHidden = true
                       self.myViewEmpty.isHidden = false
                   }else{
                       self.myTblCart.isHidden = false
                       self.myViewEmpty.isHidden = true
                   }
                   if let warning = self.cartModel?.errorWarning, warning != ""{
                       self.myBtnCheckout.isUserInteractionEnabled = false
                       self.myBtnCheckout.alpha = 0.4
                   }else{
                       self.myBtnCheckout.isUserInteractionEnabled = true
                       self.myBtnCheckout.alpha = 1
                   }
                   if aDictInfo["error"] != nil{
                       let error = aDictInfo["error"] as! [String: String]
                       HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                   }
               } else {
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_CART_MODULE_EMPTY)
               }
               self.myTblCart.dataSource = self
               self.myTblCart.delegate = self
               self.myTblCart.reloadData()
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callDeleteProducts(idList: [String]) {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_CLEAR] = "0"
        aDictParameters[K_PARAMS_PRODUCT_CART_ID] = idList
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_VENDOR_ID] = self.cartModel?.vendorID ?? ""
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
                   callGetCartItemsApi()
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
    
    func callPostIncrementDecrement(cartId: String, type: String) {
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_CART_ID] = cartId
        aDictParameters[K_PARAMS_TYPE] = type
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
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
                   self.callGetCartItemsApi()
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
    
    func setupUI(){
        self.myTblCart.register(UINib(nibName: "CartProductTblCell", bundle: nil), forCellReuseIdentifier: "cartProductCell")
        self.myTblCart.register(UINib(nibName: "CartProductWithOptionTblCell", bundle: nil), forCellReuseIdentifier: "cartProductOptCell")
        self.myTblCart.register(UINib(nibName: "CartNoteTblCell", bundle: nil), forCellReuseIdentifier: "CartNoteCell")
        self.myTblCart.register(UINib(nibName: "CartTotalTblCell", bundle: nil), forCellReuseIdentifier: "cartTotalCell")
        self.myTblCart.register(UINib(nibName: "CartWarningTableCell", bundle: nil), forCellReuseIdentifier: "cartWarningCell")
        self.myBtnAddItems.layer.borderWidth = 1
        self.myBtnAddItems.layer.borderColor = UIColor(named: "clr_orange")?.cgColor
    }
    
    func loginSuccess() {
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CheckoutVc.storyboardID) as! CheckoutVc
        aViewController.noteStr = self.additionalNote
        aViewController.vendorId = self.cartModel?.vendorID ?? ""
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
    func loginFailure() {
        
    }
    
    //MARK: Button action
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickCheckout(_ sender: UIButton) {
        
        if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CheckoutVc.storyboardID) as! CheckoutVc
            aViewController.noteStr = self.additionalNote
            aViewController.vendorId = cartModel?.vendorID ?? ""
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(aViewController, animated: true)
        }else{
            let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancelActionButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in}
            actionSheet.addAction(cancelActionButton)
            let login = UIAlertAction(title: NSLocalizedString("Login", comment: ""), style: .default)
            { _ in
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: LoginVc.storyboardID) as! LoginVc
                aViewController.delegate = self
                self.navigationController?.pushViewController(aViewController, animated: true)
            }
            actionSheet.addAction(login)
            let guest = UIAlertAction(title: NSLocalizedString("Guest", comment: ""), style: .default)
            { _ in
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: CheckoutVc.storyboardID) as! CheckoutVc
                aViewController.noteStr = self.additionalNote
                aViewController.vendorId = self.cartModel?.vendorID ?? ""
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(aViewController, animated: true)
            }
            actionSheet.addAction(guest)
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    @IBAction func clickAddItems(_ sender: UIButton) {
        if cartModel?.vendorTypeID == "2"{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
            aViewController.vendorId = self.cartModel?.vendorID ?? ""
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(aViewController, animated: true)
        }else{
            let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
            aViewController.vendorId = self.cartModel?.vendorID ?? ""
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(aViewController, animated: true)
        }
    }
    
    @IBAction func clickAddItemsOnEmpty(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CartVc: UITableViewDelegate, UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 3{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            headerView.backgroundColor = .white
            let headerLable = UILabel(frame: CGRect(x: 8, y: 15, width: tableView.frame.size.width - 16, height: 20))
            headerLable.font = UIFont(name: "Poppins-Bold", size: 18)
            headerLable.text = NSLocalizedString("Payment summary", comment: "")
            headerView.addSubview(headerLable)
            return headerView
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3{
            return 40
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return cartModel?.errorWarning != "" ? 1 : 0
        }else if section == 1{
            return cartModel?.products?.count ?? 0
        }else if section == 2{
            return 1
        }else{
            return cartModel?.totals?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cartWarningCell", for: indexPath) as! CartWarningTableCell
            cell.myLblWarning.text = self.cartModel?.errorWarning
            return cell
        }else if indexPath.section == 1{
            if self.cartModel?.products?[indexPath.row].option?.count != 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cartProductOptCell", for: indexPath) as! CartProductWithOptionTblCell
                cell.myLblTitle.text = self.cartModel?.products?[indexPath.row].name
                cell.myLblOutofStock.isHidden = self.cartModel?.products?[indexPath.row].stockStatus == "0" ? false : true
               
                if var discount = self.cartModel?.products?[indexPath.row].discountPrice, discount != ""{
                    //discount = discount + " "
                    var discountTotal = self.cartModel?.products?[indexPath.row].total ?? ""
                    discountTotal = discountTotal + " "
                    let multipleAttributes: [NSAttributedString.Key : Any] = [
                        NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 14.0) ?? "",
                        NSAttributedString.Key.foregroundColor: UIColor.black,
                    ]
                    let myAttrStringDiscount = NSMutableAttributedString(string: discountTotal , attributes: multipleAttributes)
                    let price = self.cartModel?.products?[indexPath.row].actualTotal ?? ""
                    let multipleAttributes2: [NSAttributedString.Key : Any] = [
                        NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 14.0) ?? "",
                        NSAttributedString.Key.foregroundColor: UIColor.gray,
                    ]
                    let myAttrStringPrice = NSMutableAttributedString(string: price , attributes: multipleAttributes2)
                    myAttrStringPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, myAttrStringPrice.length))
                    myAttrStringDiscount.append(myAttrStringPrice)
                    cell.myLblPrice.attributedText = myAttrStringDiscount
                }else{
                    cell.myLblPrice.text = self.cartModel?.products?[indexPath.row].total
                    cell.myLblPrice.font = UIFont(name: "Poppins-Medium", size: 13.0)
                }
//                cell.myLblPrice.text = self.cartModel?.products?[indexPath.row].total
                
                cell.myLblPrice.font = UIFont(name: "Poppins-Medium", size: 13.0)
                cell.mylblQuantity.text = self.cartModel?.products?[indexPath.row].quantity
                cell.myBtnDecrease.tag = indexPath.row
                cell.myBtnIncrease.tag = indexPath.row
                cell.myBtnIncrease.addTarget(self, action: #selector(clickIncrement(_:)), for: .touchUpInside)
                cell.myBtnDecrease.addTarget(self, action: #selector(clickDecrement(_:)), for: .touchUpInside)
                var options = [String]()
                for obj in self.cartModel?.products?[indexPath.row].option ?? []{
                    let name = obj.value
                    options.append(name!)
                }
                cell.myLblOptions.text = options.joined(separator: ", ")
                cell.myLblOptions.sizeToFit()
                cell.myLblOptions.translatesAutoresizingMaskIntoConstraints = true
                cell.myLblPrice.frame.origin.y = cell.myLblOptions.frame.origin.y + cell.myLblOptions.frame.size.height + 10
                cell.myLblPrice.translatesAutoresizingMaskIntoConstraints = true
                cell.myLblPrice.textAlignment = isRTLenabled == true ? .right : .left
                cellHeight = cell.myLblPrice.frame.origin.y + 50
                let imageUrl = self.cartModel?.products?[indexPath.row].image
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
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cartProductCell", for: indexPath) as! CartProductTblCell
                cell.myLblTitle.text = self.cartModel?.products?[indexPath.row].name
                cell.myLblOutofStock.isHidden = self.cartModel?.products?[indexPath.row].stockStatus == "0" ? false : true
                
                if var discount = self.cartModel?.products?[indexPath.row].discountPrice, discount != ""{
                    //discount = discount + " "
                    var discountTotal = self.cartModel?.products?[indexPath.row].total ?? ""
                    discountTotal = discountTotal + " "
                    let multipleAttributes: [NSAttributedString.Key : Any] = [
                        NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 14.0) ?? "",
                        NSAttributedString.Key.foregroundColor: UIColor.black,
                    ]
                    let myAttrStringDiscount = NSMutableAttributedString(string: discountTotal , attributes: multipleAttributes)
                    let price = self.cartModel?.products?[indexPath.row].actualTotal ?? ""
                    let multipleAttributes2: [NSAttributedString.Key : Any] = [
                        NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 14.0) ?? "",
                        NSAttributedString.Key.foregroundColor: UIColor.gray,
                    ]
                    let myAttrStringPrice = NSMutableAttributedString(string: price , attributes: multipleAttributes2)
                    myAttrStringPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, myAttrStringPrice.length))
                    myAttrStringDiscount.append(myAttrStringPrice)
                    cell.myLblPrice.attributedText = myAttrStringDiscount
                }else{
                    cell.myLblPrice.text = self.cartModel?.products?[indexPath.row].total
                    cell.myLblPrice.font = UIFont(name: "Poppins-Medium", size: 14.0)
                }
//                cell.myLblPrice.text = self.cartModel?.products?[indexPath.row].total
                
                cell.myLblPrice.textAlignment = isRTLenabled == true ? .right : .left
                cell.mylblQuantity.text = self.cartModel?.products?[indexPath.row].quantity
                cell.myBtnDecrease.tag = indexPath.row
                cell.myBtnIncrease.tag = indexPath.row
                cell.myBtnIncrease.addTarget(self, action: #selector(clickIncrement(_:)), for: .touchUpInside)
                cell.myBtnDecrease.addTarget(self, action: #selector(clickDecrement(_:)), for: .touchUpInside)
                let imageUrl = self.cartModel?.products?[indexPath.row].image
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
                return cell
            }
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartNoteCell", for: indexPath) as! CartNoteTblCell
            cell.myTxtNote.delegate = self
            cell.myTxtNote.text = self.additionalNote
            cell.myTxtNote.textAlignment = isRTLenabled == true ? .right : .left
            cell.mybtnClear.isHidden = cell.myTxtNote.text != "" ? false : true
            cell.mybtnClear.addTarget(self, action: #selector(clickClear(_:)), for: .touchUpInside)
            cell.mybtnClear.tag = indexPath.row
            return cell
        }else if indexPath.section == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cartTotalCell", for: indexPath) as! CartTotalTblCell
            if indexPath.row == ((self.cartModel?.totals?.count ?? 0) - 1){
                cell.myLblPriceType.font = UIFont(name: "Poppins-Medium", size: 15)
                cell.myLblTotalPrice.font = UIFont(name: "Poppins-Medium", size: 15)
            }else{
                cell.myLblPriceType.font = UIFont(name: "Poppins-Regular", size: 13)
                cell.myLblTotalPrice.font = UIFont(name: "Poppins-Regular", size: 13)
            }
            if self.cartModel?.totals?[indexPath.row].titleKey == "coupon" || self.cartModel?.totals?[indexPath.row].titleKey == "offer"{
                cell.myLblPriceType.textColor = ConfigTheme.themeColor
                cell.myLblTotalPrice.textColor = ConfigTheme.themeColor
            }else{
                cell.myLblPriceType.textColor = .black
                cell.myLblTotalPrice.textColor = .black
            }
            cell.myLblPriceType.text = self.cartModel?.totals?[indexPath.row].title
            cell.myLblTotalPrice.text = (self.cartModel?.totals?[indexPath.row].text ?? "")
            if isRTLenabled{
                //cell.myLblTotalPrice.text = ((self.cartModel?.totals?[indexPath.row].currency ?? "") + " " + (self.cartModel?.totals?[indexPath.row].amount ?? ""))
                cell.myLblTotalPrice.textAlignment = .left
            }else{
                //cell.myLblTotalPrice.text = ((self.cartModel?.totals?[indexPath.row].amount ?? "") + " " + (self.cartModel?.totals?[indexPath.row].currency ?? ""))
                cell.myLblTotalPrice.textAlignment = .right
            }
            
            //cell.myLblCurrency.text =
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cartTotalCell", for: indexPath) as! CartTotalTblCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 65
        }else if indexPath.section == 1{
            if self.cartModel?.products?[indexPath.row].option?.count != 0{
                return cellHeight
            }
            return 100
        }else if indexPath.section == 2{
            return 121
        }else{
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @objc func clickIncrement(_ sender: UIButton){
        guard let cartId = self.cartModel?.products?[sender.tag].cartID else { return }
        if self.cartModel?.products?[sender.tag].stockStatus == "0"{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: "", aStrMessage: NSLocalizedString("Out of stock", comment: ""))
        }else{
            self.callPostIncrementDecrement(cartId: cartId, type: "1")
        }
    }
    
    @objc func clickDecrement(_ sender: UIButton){
        if self.cartModel?.products?[sender.tag].quantity == "1"{
            HELPER.showAlertControllerIn(aViewController: self, aStrMessage: NSLocalizedString("Do you want ot remove this item?", comment: ""), okButtonTitle: NSLocalizedString("Agree", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { (okAction) in
                let cartId = self.cartModel?.products?[sender.tag].cartID ?? "0"
                var id = [String]()
                id.append(cartId)
                self.callDeleteProducts(idList: id)
            } cancelActionBlock: { (cancelAction) in
                self.dismiss(animated: true)
            }
        }else{
            guard let cartId = self.cartModel?.products?[sender.tag].cartID else { return }
            self.callPostIncrementDecrement(cartId: cartId, type: "0")
        }
    }
    
    @objc func clickClear(_ sender: UIButton){
        self.additionalNote = ""
        UIView.setAnimationsEnabled(false)
        self.myTblCart.beginUpdates()
        self.myTblCart.reloadSections(NSIndexSet(index: 1) as IndexSet, with: UITableView.RowAnimation.none)
        self.myTblCart.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}

extension CartVc: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.additionalNote = textField.text ?? ""
        UIView.setAnimationsEnabled(false)
        self.myTblCart.beginUpdates()
        self.myTblCart.reloadSections(NSIndexSet(index: 1) as IndexSet, with: UITableView.RowAnimation.none)
        self.myTblCart.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}
