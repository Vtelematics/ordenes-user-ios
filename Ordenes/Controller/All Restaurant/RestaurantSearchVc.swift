//
//  RestaurantSearchVc.swift
//  Talabat clone
//
//  Created by Adyas infotech on 06/07/22.
//

import UIKit

class RestaurantSearchVc: UIViewController {

    @IBOutlet var myTblSearch: UITableView!
    @IBOutlet weak var myViewSearch: UIView!
    @IBOutlet weak var myViewSearchClear: UIView!
    @IBOutlet weak var myTxtSearch: UITextField!
    
    var restaurantSearchModel = [AllRestroVendor]()
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "10"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupUI(){
        self.myTblSearch.tableFooterView = UIView()
        self.myTblSearch.becomeFirstResponder()
        self.myTxtSearch.textAlignment = isRTLenabled == true ? .right : .left
        self.navigationController?.isNavigationBarHidden = true
        self.myViewSearch.layer.cornerRadius = 8
        self.myViewSearch.layer.borderWidth = 0.5
        self.myTblSearch.register(UINib(nibName: "AllRestaurantTblCell", bundle: nil), forCellReuseIdentifier: "allRestaurantCell")
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
                    self.pullToRefresh()
                }
            }
        }
    }
    
    //MARK: API Calls
    func callGetSearchRestaurantApi(searchKey: String) {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        page = 1
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_PAGE] = page
        aDictParameters[K_PARAMS_LIMIT] = limit
        aDictParameters[K_PARAMS_SEARCH] = searchKey
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_VENDOR_SEARCH_LISTING, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    let modelData = try! JSONDecoder().decode(AllRestraurantModel.self, from: jsonData)
                    self.restaurantSearchModel = modelData.vendor ?? []
                    let total = modelData.total
                    self.pageCount = Double(Int(total ?? "0")!/Int(self.limit)!)
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }
                } else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_RESTAURANT)
                }
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
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            aDictParameters[K_PARAMS_SEARCH] = self.myTxtSearch.text!
            aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_VENDOR_SEARCH_LISTING, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
               do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(AllRestraurantModel.self, from: jsonData)
                        self.restaurantSearchModel.append(contentsOf: modelData.vendor ?? [])
                        self.myTblSearch.reloadData()
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
    
    @objc func getRestaurantList(searchTextField: UITextField) {
        callGetSearchRestaurantApi(searchKey: searchTextField.text ?? "")
    }
    
    //MARK: Button Action
    @IBAction func clickClearSearch(_ sender : Any){
        view.endEditing(true)
        self.myTxtSearch.text = ""
        self.myViewSearchClear.isHidden = true
        self.restaurantSearchModel.removeAll()
        self.myTblSearch.reloadData()
    }
    
    @IBAction func clickBack(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
}

extension RestaurantSearchVc : UITextFieldDelegate{
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            self.myViewSearchClear.isHidden = txtAfterUpdate == "" ? true : false
            if txtAfterUpdate.count > 2{
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getRestaurantList), object: textField)
                self.perform(#selector(self.getRestaurantList), with: textField, afterDelay: 0.5)
            }else if txtAfterUpdate == ""{
                self.restaurantSearchModel.removeAll()
                self.myTblSearch.reloadData()
            }
        }
        return true
    }
}

extension RestaurantSearchVc: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurantSearchModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allRestaurantCell", for: indexPath) as! AllRestaurantTblCell
        cell.lblRestaurantName.text = self.restaurantSearchModel[indexPath.row].name
        cell.lblRestaurantDesc.text = self.restaurantSearchModel[indexPath.row].cuisines
        if let offer = self.restaurantSearchModel[indexPath.row].offer, offer != ""{
            cell.lblRestaurantOffer.text = offer
            cell.imgOffer.isHidden = false
            cell.lblLine.isHidden = false
        }else{
            cell.lblRestaurantOffer.text = ""
            cell.imgOffer.isHidden = true
            cell.lblLine.isHidden = true
        }
        let imageUrl = self.restaurantSearchModel[indexPath.row].logo
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
        if let rating = restaurantSearchModel[indexPath.row].rating?.rating, rating != "" && rating != "0"{
            cell.viewRating.isHidden = false
            cell.lblRestaurantRating.text = restaurantSearchModel[indexPath.row].rating?.vendorRatingName
            let imageUrl = restaurantSearchModel[indexPath.row].rating?.vendorRatingImage
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
        cell.lblMinOrder.text = NSLocalizedString("Minimum order - ", comment: "") + (self.restaurantSearchModel[indexPath.row].minimumAmount ?? "0")
        if orderType == "2"{
            cell.lblRestaurantPreparingTime.text = (restaurantSearchModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
            cell.viewPreparing.isHidden = false
        }else{
            if restaurantSearchModel[indexPath.row].freeDelivery == "1"{
                cell.lblRestaurantDeliveryCharge.text = NSLocalizedString("Free delivery", comment: "")
            }else{
                cell.lblRestaurantDeliveryCharge.text = NSLocalizedString("Delivery", comment: "") + " - " + (self.restaurantSearchModel[indexPath.row].deliveryCharge ?? "0")
            }
            cell.lblRestaurantDeliveryTime.text = (restaurantSearchModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
            cell.viewPreparing.isHidden = true
        }
        let vendorStatus = self.restaurantSearchModel[indexPath.row].vendorStatus
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let offer = self.restaurantSearchModel[indexPath.row].offer, offer != ""{
            return 186
        }else{
            return 147
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.restaurantSearchModel[indexPath.row].vendorTypeID == "2"{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
            aViewController.vendorId = self.restaurantSearchModel[indexPath.row].vendorID ?? "0"
            self.navigationController?.pushViewController(aViewController, animated: true)
        }else{
            let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
            aViewController.vendorId = self.restaurantSearchModel[indexPath.row].vendorID ?? "0"
            self.navigationController?.pushViewController(aViewController, animated: true)
        }
    }
}
