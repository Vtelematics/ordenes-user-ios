//
//  FavouriteVc.swift
//  Ordenes
//
//  Created by Adyas infotech on 19/11/22.
//

import UIKit
import Alamofire

class FavouriteVc: UIViewController {
    @IBOutlet weak var myTblFavourite: UITableView!
    var favouriteModel = [AllRestroVendor]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callGetFavouriteApi()
    }
    
    //MARK: Function
    func callGetFavouriteApi() {
        if UserDefaults.standard.object(forKey: UD_WISHLIST) != nil{
            let data = UserDefaults.standard.object(forKey: UD_WISHLIST) as! Data
            var favAry = [String]()
            do {
                if let arry = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] {
                    favAry = arry
                }
            } catch {
                print("Couldn't read file.")
            }
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            let dayId = Date().dayNumberOfWeek()
            var aDictParameters = [String : Any]()
            aDictParameters[K_PARAMS_DAY_ID] = dayId
            aDictParameters[K_PARAMS_VENDOR_LIST] = favAry
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_WISH_LIST, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
               do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(WishlistModel.self, from: jsonData)
                        self.favouriteModel = modelData.vendorList ?? []
                        if self.favouriteModel.isEmpty{
                            HELPER.showAlertControllerWithOkActionBlock(aViewController: self, aStrMessage: NSLocalizedString("Favourite list is empty", comment: "")) { UIAlertAction in
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        if aDictInfo["error"] != nil{
                            let error = aDictInfo["error"] as! [String: String]
                            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                        }
                    } else {
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_NO_RESTAURANT)
                    }
                    self.myTblFavourite.dataSource = self
                    self.myTblFavourite.delegate = self
                    self.myTblFavourite.reloadData()
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
    
    func setupUI(){
        self.myTblFavourite.tableFooterView = UIView()
        self.myTblFavourite.register(UINib(nibName: "AllRestaurantTblCell", bundle: nil), forCellReuseIdentifier: "allRestaurantCell")
        self.myTblFavourite.dataSource = self
        self.myTblFavourite.delegate = self
    }
    
    //MARK: Button Action
    @IBAction func clickBack(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clickFav(_ sender: UIButton){
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
            
            self.favouriteModel.remove(at: sender.tag)
            favAry.remove(at: sender.tag)
            print(favAry)
            do{
                let data = try NSKeyedArchiver.archivedData(withRootObject: favAry, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: UD_WISHLIST)
            } catch {
                print("Couldn't write file")
            }
        }
        self.myTblFavourite.reloadData()
        if self.favouriteModel.isEmpty{
            HELPER.showAlertControllerWithOkActionBlock(aViewController: self, aStrMessage: NSLocalizedString("Favourite list is empty", comment: "")) { UIAlertAction in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension FavouriteVc: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favouriteModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allRestaurantCell", for: indexPath) as! AllRestaurantTblCell
        cell.lblRestaurantName.text = self.favouriteModel[indexPath.row].name
        cell.lblRestaurantDesc.text = self.favouriteModel[indexPath.row].cuisines
        if let offer = self.favouriteModel[indexPath.row].offer, offer != ""{
            cell.lblRestaurantOffer.text = offer
            cell.imgOffer.isHidden = false
            cell.lblLine.isHidden = false
        }else{
            cell.lblRestaurantOffer.text = ""
            cell.imgOffer.isHidden = true
            cell.lblLine.isHidden = true
        }
        let imageUrl = self.favouriteModel[indexPath.row].logo
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
        if let rating = favouriteModel[indexPath.row].rating?.rating, rating != "" && rating != "0"{
            cell.viewRating.isHidden = false
            cell.lblRestaurantRating.text = favouriteModel[indexPath.row].rating?.vendorRatingName
            let imageUrl = favouriteModel[indexPath.row].rating?.vendorRatingImage
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
        cell.lblMinOrder.text = NSLocalizedString("Minimum order - ", comment: "") + (self.favouriteModel[indexPath.row].minimumAmount ?? "0")
        if orderType == "2"{
            cell.lblRestaurantPreparingTime.text = (favouriteModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
            cell.viewPreparing.isHidden = false
        }else{
            if favouriteModel[indexPath.row].freeDelivery == "1"{
                cell.lblRestaurantDeliveryCharge.text = NSLocalizedString("Free delivery", comment: "")
            }else{
                cell.lblRestaurantDeliveryCharge.text = NSLocalizedString("Delivery", comment: "") + " - " + (self.favouriteModel[indexPath.row].deliveryCharge ?? "0")
            }
            cell.lblRestaurantDeliveryTime.text = (favouriteModel[indexPath.row].deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
            cell.viewPreparing.isHidden = true
        }
        let vendorStatus = self.favouriteModel[indexPath.row].vendorStatus
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
        cell.imgFav.image = UIImage(named: "ic_fav_fill")
        cell.imgFav.image = cell.imgFav.image!.withRenderingMode(.alwaysTemplate)
        cell.imgFav.tintColor = ConfigTheme.themeColor
        cell.btnFav.isHidden = false
        cell.btnSelect.isHidden = false
        cell.imgFav.isHidden = false
        cell.btnFav.addTarget(self, action: #selector(clickFav(_:)), for: .touchUpInside)
        cell.btnFav.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let offer = self.favouriteModel[indexPath.row].offer, offer != ""{
            if let offer = self.favouriteModel[indexPath.row].offer, offer != ""{
                return 186
            }else{
                return 147
            }
        }else{
            return 147
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.favouriteModel[indexPath.row].vendorTypeID == "2"{
            let aViewController = UIStoryboard(.grocery).instantiateViewController(withIdentifier: GroceryInfoVc.storyboardID) as! GroceryInfoVc
            aViewController.vendorId = self.favouriteModel[indexPath.row].vendorID ?? "0"
            self.navigationController?.pushViewController(aViewController, animated: true)
        }else{
            let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: RestaurantVc.storyboardID) as! RestaurantVc
            aViewController.vendorId = self.favouriteModel[indexPath.row].vendorID ?? "0"
            self.navigationController?.pushViewController(aViewController, animated: true)
        }
    }
}
