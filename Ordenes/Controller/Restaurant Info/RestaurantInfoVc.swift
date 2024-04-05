//
//  RestaurantInfoVc.swift
//  Talabat clone
//
//  Created by Adyas infotech on 16/07/22.
//

import UIKit

class RestaurantInfoVc: UIViewController {

    @IBOutlet var myTblRestaurantInfo : UITableView!
    @IBOutlet var myViewRestRoImg : UIView!
    @IBOutlet var myRestRoImg : UIImageView!
    @IBOutlet var myLblRestaurantName : UILabel!
    @IBOutlet var myLblRestaurantCuisine : UILabel!
    
    var vendorInfoModel : Vendor?
    //NSLocalizedString("Pre-order", comment: ""),
    var infoListArray = [NSLocalizedString("Rating", comment: ""), NSLocalizedString("Restaurant area", comment: ""), NSLocalizedString("Opening hours", comment: ""),NSLocalizedString("Delivery time", comment: ""), NSLocalizedString("Minimum order", comment: ""), NSLocalizedString("Delivery fee", comment: ""), NSLocalizedString("Payment options", comment: "")]
    var imgInfoListArray = ["ic_smily", "ic_food_location", "ic_clock", "ic_bike_delivery", "ic_wallet", "ic_list", "ic_payment"]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        self.myLblRestaurantName.text = vendorInfoModel?.name
        self.myViewRestRoImg.layer.borderWidth = 0.7
        self.myViewRestRoImg.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.myViewRestRoImg.layer.cornerRadius = 7
        var cuisneList = [String]()
        for obj in self.vendorInfoModel?.cuisine ?? []{
            let name = obj.name
            cuisneList.append(name!)
        }
        self.myLblRestaurantCuisine.text = cuisneList.joined(separator: ", ")
        let imageUrl =  vendorInfoModel?.logo
        let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20")
        var activityLoader = UIActivityIndicatorView()
        activityLoader = UIActivityIndicatorView(style: .medium)
        activityLoader.center = self.myRestRoImg.center
        activityLoader.startAnimating()
        self.myRestRoImg.addSubview(activityLoader)
        
        self.myRestRoImg.sd_setImage(with: URL(string: trimmedUrl ?? ""), completed: { (image, error, imageCacheType, imageUrl) in
            
            if image != nil
            {
                activityLoader.stopAnimating()
            }
            else
            {
                print("image not found")
                self.myRestRoImg.image = UIImage(named: "no_image")
                activityLoader.stopAnimating()
            }
        })
        self.myTblRestaurantInfo.delegate = self
        self.myTblRestaurantInfo.dataSource = self
        self.myTblRestaurantInfo.reloadData()
    }
    
    //MARK: Button action
    @IBAction func clickBack(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
}

extension RestaurantInfoVc: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return infoListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellType = infoListArray[indexPath.row] as String
        
        if cellType == NSLocalizedString("Rating", comment: ""){
            let cell:RestaurantInfoTblCell = self.myTblRestaurantInfo.dequeueReusableCell(withIdentifier: "restaurantInfoCell1") as! RestaurantInfoTblCell
            cell.imgIcon.image = UIImage(named: self.imgInfoListArray[indexPath.row] as String)
            cell.lblTitle.text = self.infoListArray[indexPath.row] as String
            if let rating = self.vendorInfoModel?.rating?.rating, rating != "0" &&  rating != ""{
                cell.lblValue.text = rating
            }else{
                cell.lblValue.text = NSLocalizedString("No rating", comment: "")
            }
            return cell
        }else if cellType == NSLocalizedString("Restaurant area", comment: ""){
            let cell:RestaurantInfoTblCell = self.myTblRestaurantInfo.dequeueReusableCell(withIdentifier: "restaurantInfoCell1") as! RestaurantInfoTblCell
            cell.lblTitle.text = self.infoListArray[indexPath.row] as String
            cell.lblValue.text = self.vendorInfoModel?.address
            cell.imgIcon.image = UIImage(named: self.imgInfoListArray[indexPath.row] as String)
            return cell
        }else if cellType == NSLocalizedString("Opening hours", comment: ""){
            let cell:RestaurantInfoTblCell = self.myTblRestaurantInfo.dequeueReusableCell(withIdentifier: "restaurantInfoCell1") as! RestaurantInfoTblCell
            cell.lblTitle.text = self.infoListArray[indexPath.row] as String
            cell.lblValue.text = self.vendorInfoModel?.workingHours
            cell.imgIcon.image = UIImage(named: self.imgInfoListArray[indexPath.row] as String)
            return cell
        }else if cellType == NSLocalizedString("Delivery time", comment: ""){
            let cell:RestaurantInfoTblCell = self.myTblRestaurantInfo.dequeueReusableCell(withIdentifier: "restaurantInfoCell1") as! RestaurantInfoTblCell
            cell.lblTitle.text = self.infoListArray[indexPath.row] as String
            cell.lblValue.text = (self.vendorInfoModel?.deliveryTime ?? "0") + " " + NSLocalizedString("mins", comment: "")
            cell.imgIcon.image = UIImage(named: self.imgInfoListArray[indexPath.row] as String)
            return cell
        }else if cellType == NSLocalizedString("Minimum order", comment: ""){
            let cell:RestaurantInfoTblCell = self.myTblRestaurantInfo.dequeueReusableCell(withIdentifier: "restaurantInfoCell1") as! RestaurantInfoTblCell
            cell.lblTitle.text = self.infoListArray[indexPath.row] as String
            cell.lblValue.text = self.vendorInfoModel?.minimumAmount
            cell.imgIcon.image = UIImage(named: self.imgInfoListArray[indexPath.row] as String)
            return cell
        }else if cellType == NSLocalizedString("Delivery fee", comment: ""){
            let cell:RestaurantInfoTblCell = self.myTblRestaurantInfo.dequeueReusableCell(withIdentifier: "restaurantInfoCell1") as! RestaurantInfoTblCell
            cell.lblTitle.text = self.infoListArray[indexPath.row] as String
            cell.lblValue.text = self.vendorInfoModel?.deliveryCharge
            cell.imgIcon.image = UIImage(named: self.imgInfoListArray[indexPath.row] as String)
            return cell
        }else{
            let cell:RestaurantInfoTblCell = self.myTblRestaurantInfo.dequeueReusableCell(withIdentifier: "restaurantInfoCell2") as! RestaurantInfoTblCell
            cell.lblTitle.text = self.infoListArray[indexPath.row] as String
            var payments = self.vendorInfoModel?.paymentMethod
            payments = payments?.reversed()
            for i in 0..<(payments?.count ?? 0){
                if i == 0{
                    let imageUrl = payments?[i].image
                    let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""

                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .medium)
                    activityLoader.center = cell.imgPayment1.center
                    activityLoader.startAnimating()
                    cell.imgPayment1.addSubview(activityLoader)
                    cell.imgPayment1.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }
                        else
                        {
                            print("image not found")
                            cell.imgPayment1.image = UIImage(named: "no_image")
                            activityLoader.stopAnimating()
                        }
                    })
                }else if i == 1{
                    let imageUrl = payments?[i].image
                    let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""

                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .medium)
                    activityLoader.center = cell.imgPayment2.center
                    activityLoader.startAnimating()
                    cell.imgPayment2.addSubview(activityLoader)
                    cell.imgPayment2.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }
                        else
                        {
                            print("image not found")
                            cell.imgPayment2.image = UIImage(named: "no_image")
                            activityLoader.stopAnimating()
                        }
                    })
                }else if i == 2{
                    let imageUrl = payments?[i].image
                    let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""

                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .medium)
                    activityLoader.center = cell.imgPayment3.center
                    activityLoader.startAnimating()
                    cell.imgPayment3.addSubview(activityLoader)
                    cell.imgPayment3.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }
                        else
                        {
                            print("image not found")
                            cell.imgPayment3.image = UIImage(named: "no_image")
                            activityLoader.stopAnimating()
                        }
                    })
                }else if i == 3{
                    let imageUrl = payments?[i].image
                    let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""

                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .medium)
                    activityLoader.center = cell.imgPayment4.center
                    activityLoader.startAnimating()
                    cell.imgPayment4.addSubview(activityLoader)
                    cell.imgPayment4.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }
                        else
                        {
                            print("image not found")
                            cell.imgPayment4.image = UIImage(named: "no_image")
                            activityLoader.stopAnimating()
                        }
                    })
                }
                
            }
            cell.imgIcon.image = UIImage(named: self.imgInfoListArray[indexPath.row] as String)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
}
