//
//  ProductDetailViewController.swift
//  Foodco
//
//  Created by Exlcart Solutions on 30/08/21.
//  Copyright © 2021 Adyas Iinfotech. All rights reserved.
//

import UIKit
import Alamofire

class ProductDetailVc: UIViewController, loginIntimation{
    
    @IBOutlet weak var myTblProductDetail: UITableView!
    @IBOutlet weak var myBtnAddToCart: UIButton!
    @IBOutlet weak var myViewAddToCart: UIView!

    var vendorId = ""
    var vendorStatus = ""
    var vendorName = ""
    var productModel : Product?
    var addCartProductsdict = NSMutableDictionary()
    var allOptions:[Option] = []
    
    
    var selectedProductId = ""
    var productTitle = ""
    var restaurantTitle = ""
    var restaurantAddress = ""
    var restaurantLat : String = ""
    var restaurantLong : String = ""
    var restaurantDelTime : String = ""
    var restaurantPreTime : String = ""
    var productImageUrl = ""
    var minProductQuantity = ""
    var incrementQuantity = 1
    var cartOptionIndex = ""
    var cellHeight : CGFloat = 0
    //var cellDescriptionHeight : CGFloat = 0
    
    var productDes = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        if allOptions.count != 0 {
            self.myViewAddToCart.backgroundColor = ConfigTheme.customLightGray
            self.myBtnAddToCart.isUserInteractionEnabled = false
        }else {
            self.myViewAddToCart.backgroundColor = ConfigTheme.posBtnColor
            self.myBtnAddToCart.isUserInteractionEnabled = true
        }
        self.allOptions = productModel?.options ?? []
        self.myTblProductDetail.dataSource = self
        self.myTblProductDetail.delegate = self
        self.myTblProductDetail.reloadData()
        checkIsRequiredDone()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.isHidden = true
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: Functions
    func checkIsRequiredDone(){
        var isEmpty : Bool = false
        var isMini : Bool = false
        for i in 0..<allOptions.count
        {
            if allOptions[i].isRequired == "1"
            {
                if allOptions[i].selectedOptions.count == 0
                {
                    isEmpty = true
                }
                let minLimit = allOptions[i].minimumLimit
                if allOptions[i].selectedOptions.count < Int(minLimit!) ?? 1{
                    isMini = true
                }
            }
        }
        if isEmpty || isMini
        {
            self.myViewAddToCart.backgroundColor = ConfigTheme.customLightGray
            self.myBtnAddToCart.isUserInteractionEnabled = false
        }else{
            self.myViewAddToCart.backgroundColor = ConfigTheme.posBtnColor
            self.myBtnAddToCart.isUserInteractionEnabled = true
        }
    }
    
    func callPostProductsToCart() {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        var valuesForAPI1:[String:AnyObject] = [:]
        if allOptions.count != 0{
            let arrOfDict = (allOptions.map { $0.getSelectedValues() })
            (arrOfDict.flatMap { $0 }).forEach { (arg) in
                let (key, value) = arg
                valuesForAPI1[key] = value
            }
        }
        var productsDict = [String : Any]()
        productsDict["product_id"] = productModel?.productItemID
        productsDict["quantity"] = incrementQuantity
        productsDict["option"] = valuesForAPI1
        
        var productsArray = [[String : Any]]()
        productsArray.append(productsDict)
        let dayId = Date().dayNumberOfWeek()
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
               print(response)
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
                   self.navigationController?.popViewController(animated: true)
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
                   self.callPostProductsToCart()
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
        if vendorStatus == "0"{
            let alert = NSLocalizedString("\(vendorName) is not available for \(self.productModel?.itemName ?? "") at this time. You can continue adding items to your basket and order when delivery service is resumed", comment: "")
            HELPER.showAlertControllerIn(aViewController: self, aStrMessage: alert, okButtonTitle: NSLocalizedString("Ok", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { ok in
                self.callPostProductsToCart()
            } cancelActionBlock: { cancel in
                self.dismiss(animated: true)
            }
        }else{
            self.callPostProductsToCart()
        }
    }
    
    func loginFailure() {
        
    }
    
    //MARK: Button action
    @IBAction func clickBack(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickAddToCart(_ sender: Any){
        if vendorStatus == "0"{
            let alert = NSLocalizedString("\(vendorName) is not available for \(self.productModel?.itemName ?? "") at this time. You can continue adding items to your basket and order when delivery service is resumed", comment: "")
            HELPER.showAlertControllerIn(aViewController: self, aStrMessage: alert, okButtonTitle: NSLocalizedString("Ok", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { ok in
                self.callPostProductsToCart()
            } cancelActionBlock: { cancel in
                self.dismiss(animated: true)
            }
        }else{
            self.callPostProductsToCart()
        }
    }
}

extension ProductDetailVc: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return allOptions.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else{
            return allOptions[section - 1].productValue?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if section == 0 {
            return nil
        }else{
            let headerView:ProductDetailTableViewCell = self.myTblProductDetail.dequeueReusableCell(withIdentifier: "optionSection") as! ProductDetailTableViewCell
            headerView.tag = section
            if allOptions[section - 1].type == "2"
            {
                
                if "\(allOptions[section - 1].minimumLimit!)" == "0" || "\(allOptions[section - 1].minimumLimit!)" == "" && "\(allOptions[section - 1].maximumLimit!)" == "0" || "\(allOptions[section - 1].maximumLimit!)" == ""
                {
                    if allOptions[section - 1].isRequired == "1"
                    {
                        headerView.lblMin.text = NSLocalizedString("Choose 1", comment: "")
                    }
                    else
                    {
                        headerView.lblMin.text = NSLocalizedString("Choose items from the list", comment: "")
                    }
                }
                else
                {
                    if "\(allOptions[section - 1].minimumLimit!)" == "0" || "\(allOptions[section - 1].minimumLimit!)" == ""
                    {
                        headerView.lblMin.text = "(\(NSLocalizedString("Choose Min. Your Choice, Max.", comment: "")) \(allOptions[section - 1].maximumLimit!) \(NSLocalizedString("Options", comment: "")))"
                    }
                    else if "\(allOptions[section - 1].maximumLimit!)" == "0" || "\(allOptions[section - 1].maximumLimit!)" == ""
                    {
                        headerView.lblMin.text = "(\(NSLocalizedString("Choose Min.", comment: "")) \(allOptions[section - 1].minimumLimit!) \(NSLocalizedString("Options, Max. Your Choice", comment: "")))"
                    }else{
                        headerView.lblMin.text = "(\(NSLocalizedString("Choose Min.", comment: "")) \(allOptions[section - 1].minimumLimit!) \(NSLocalizedString("Options, Max.", comment: "")) \(allOptions[section - 1].maximumLimit!) \(NSLocalizedString("Options", comment: "")))"
                    }
                }
            }
            else
            {
                headerView.lblMin.text = NSLocalizedString("Choose 1", comment: "")
            }
            let myString1 = allOptions[section - 1].name ?? ""
            let multipleAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 15.0) ?? "",
                NSAttributedString.Key.foregroundColor: UIColor.black,
            ]
            let myAttrString1 = NSMutableAttributedString(string: myString1, attributes: multipleAttributes)
            if allOptions[section - 1].isRequired == "1"{
                let multipleAttributes2: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 14.0) ?? "",
                    NSAttributedString.Key.foregroundColor: UIColor.red,
                ]
                let myString2 = " (\(NSLocalizedString("Required", comment: "")))"
                let myAttrString2 = NSMutableAttributedString(string: myString2, attributes: multipleAttributes2)
                myAttrString1.append(myAttrString2)
                headerView.lblSectionTitle.attributedText = myAttrString1
            }else{
                let multipleAttributes2: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 15.0) ?? "",
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                ]
                let myString2 = " (\(NSLocalizedString("Optional", comment: "")))"
                let myAttrString2 = NSMutableAttributedString(string: myString2, attributes: multipleAttributes2)
                myAttrString1.append(myAttrString2)
                headerView.lblSectionTitle.attributedText = myAttrString1
            }
            return headerView
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }else{
            return 95
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0{
                let cell:ProductDetailTableViewCell = self.myTblProductDetail.dequeueReusableCell(withIdentifier: "productImageCell") as! ProductDetailTableViewCell
                let imageUrl =  productModel?.image
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
                let cell:ProductDetailTableViewCell = self.myTblProductDetail.dequeueReusableCell(withIdentifier: "productTitleCell") as! ProductDetailTableViewCell
                cell.lblProductName.text = productModel?.itemName
                cell.lblProductDes.text = productModel?.productDescription
                if let priceStatus = productModel?.priceStatus, priceStatus == "1"{
                    if var discount = productModel?.discount, discount != ""{
                        discount = discount + " "
                        let multipleAttributes: [NSAttributedString.Key : Any] = [
                            NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 14.0) ?? "",
                            NSAttributedString.Key.foregroundColor: UIColor.black,
                        ]
                        let myAttrStringDiscount = NSMutableAttributedString(string: discount , attributes: multipleAttributes)
                        let price = productModel?.price ?? ""
                        let multipleAttributes2: [NSAttributedString.Key : Any] = [
                            NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 14.0) ?? "",
                            NSAttributedString.Key.foregroundColor: UIColor.gray,
                        ]
                        let myAttrStringPrice = NSMutableAttributedString(string: price , attributes: multipleAttributes2)
                        myAttrStringPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, myAttrStringPrice.length))
                        myAttrStringDiscount.append(myAttrStringPrice)
                        cell.lblPrice.attributedText = myAttrStringDiscount
                    }else{
                        cell.lblPrice.text = productModel?.price
                        cell.lblPrice.textColor = .black
                    }
                }else{
                    cell.lblPrice.text = NSLocalizedString("Price on selection", comment: "")
                    cell.lblPrice.textColor = .black
                }
                cell.lblQuantity.text = "\(incrementQuantity)"
                cell.lblProductDes.sizeToFit()
                cell.lblProductDes.frame.size.width = cell.lblProductName.frame.size.width
                cell.lblProductDes.translatesAutoresizingMaskIntoConstraints = true
                //cell.lblPrice.frame.origin.y = cell.lblProductDes.
                cellHeight = cell.lblProductDes.frame.origin.y + cell.lblProductDes.frame.size.height + 75
                cell.btnIncrease.addTarget(self, action: #selector(self.increaseQuantity(_:)), for: .touchUpInside)
                cell.btnDecrease.addTarget(self, action: #selector(self.decreaseQuantity(_:)), for: .touchUpInside)
                cell.btnIncrease.tag = indexPath.row
                cell.btnDecrease.tag = indexPath.row
                return cell
            }
        }else{
            let cell = self.myTblProductDetail.dequeueReusableCell(withIdentifier: "optionCell") as! ProductDetailTableViewCell
            cell.lblOption.text = allOptions[indexPath.section - 1].productValue?[indexPath.row].name
            let price = allOptions[indexPath.section - 1].productValue?[indexPath.row].price
            if price == "" || price == "0"{
                cell.lblPrice.text = ""
            }else{
                cell.lblPrice.text = "(+\(allOptions[indexPath.section - 1].productValue?[indexPath.row].price ?? ""))"
            }
            if allOptions[indexPath.section - 1].type == "2"
            {
                //Checkbox
                if allOptions[indexPath.section - 1].selectedOptions.contains(indexPath.row)
                {
                    cell.imgCheckBox.image = UIImage (named: "ic_checkbox")
                    cell.imgCheckBox.image = cell.imgCheckBox.image!.withRenderingMode(.alwaysTemplate)
                    cell.imgCheckBox.tintColor = ConfigTheme.themeColor
                }
                else
                {
                    cell.imgCheckBox.image = UIImage (named: "ic_uncheck")
                    cell.imgCheckBox.image = cell.imgCheckBox.image!.withRenderingMode(.alwaysTemplate)
                    cell.imgCheckBox.tintColor = ConfigTheme.themeColor
                }
            }
            else
            {
                // Radio button
                if allOptions[indexPath.section - 1].selectedOptions.contains(indexPath.row)
                {
                    cell.imgCheckBox.image = UIImage (named: "ic_radio_check")
                    cell.imgCheckBox.image = cell.imgCheckBox.image!.withRenderingMode(.alwaysTemplate)
                    cell.imgCheckBox.tintColor = ConfigTheme.themeColor
                }
                else
                {
                    cell.imgCheckBox.image = UIImage (named: "ic_radio_uncheck")
                    cell.imgCheckBox.image = cell.imgCheckBox.image!.withRenderingMode(.alwaysTemplate)
                    cell.imgCheckBox.tintColor = ConfigTheme.themeColor
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if indexPath.row == 0{
                return self.myTblProductDetail.frame.size.width / 1.33
            }else{
                return cellHeight
            }
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0 {
        }else{
            //let selected = allOptions[indexPath.section - 1].productValue?[indexPath.row].name
            
            if allOptions[indexPath.section - 1].selectedOptions.contains(indexPath.row)
            {
                allOptions[indexPath.section - 1].selectedOptions.remove(at: allOptions[indexPath.section - 1].selectedOptions.firstIndex(of: indexPath.row)!)
                //allOptions[indexPath.section - 1].selectedName.remove(at: allOptions[indexPath.section - 1].selectedName.firstIndex(of: selected!)!)
                let id = allOptions[indexPath.section - 1].productValue?[indexPath.row].optionValueID
                for i in 0..<allOptions[indexPath.section - 1].selectedtoAdd.count{
                    let selected = allOptions[indexPath.section - 1].selectedtoAdd[i].optionValueID
                    if id == selected{
                        allOptions[indexPath.section - 1].selectedtoAdd.remove(at: i)
                        break
                    }
                }
            }
            else
            {
                if allOptions[indexPath.section - 1].type == "1"
                {
                    //allOptions[indexPath.section - 1].selectedName.removeAll()
                    allOptions[indexPath.section - 1].selectedtoAdd.removeAll()
                }
                allOptions[indexPath.section - 1].selectedOptions.append(indexPath.row)
                //allOptions[indexPath.section - 1].selectedName.append(selected!)
                let values = (allOptions[indexPath.section - 1].productValue?[indexPath.row])!
                allOptions[indexPath.section - 1].selectedtoAdd.append(values)
            }
            self.myTblProductDetail.reloadData()
            checkIsRequiredDone()
        }
    }
    
    @objc func increaseQuantity(_ sender:AnyObject!)
    {
        if incrementQuantity >= 1 {
            incrementQuantity = incrementQuantity + 1
            self.myTblProductDetail.reloadData()
        }
    }

    @objc func decreaseQuantity(_ sender:AnyObject!)
    {
        if incrementQuantity > 1 {
            incrementQuantity = incrementQuantity - 1
            self.myTblProductDetail.reloadData()
        }else {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Minimum Quantity should be Atleast ", comment: "") + minProductQuantity)
        }
    }
}
