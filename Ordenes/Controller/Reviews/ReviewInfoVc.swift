//
//  ReviewInfoVc.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 29/08/22.
//

import UIKit
//import FloatRatingView

class ReviewInfoVc: UIViewController, FloatRatingViewDelegate {
    
    @IBOutlet weak var myTableReviewList: UITableView!
    @IBOutlet weak var myViewNav: UIView!
    @IBOutlet weak var myViewRatingContainer: UIView!
    @IBOutlet weak var myViewWriteRating: UIView!
    @IBOutlet weak var myLblComment: UILabel!
    @IBOutlet weak var myLblTitle: UILabel!
    @IBOutlet weak var myLblRestaurantName: UILabel!
    @IBOutlet weak var myTxtComment: UITextView!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var myRatingRestaurant: FloatRatingView!
    @IBOutlet weak var myRatingDeliveryTime: FloatRatingView!
    @IBOutlet weak var myRatingProductQuality: FloatRatingView!
    @IBOutlet weak var myRatingValue: FloatRatingView!
    @IBOutlet weak var myRatingPackaging: FloatRatingView!
    
    @IBOutlet weak var myImgRating1: UIImageView!
    @IBOutlet weak var myImgRating2: UIImageView!
    @IBOutlet weak var myImgRating3: UIImageView!
    @IBOutlet weak var myImgRating4: UIImageView!
    @IBOutlet weak var myImgRating5: UIImageView!
    
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "10"
    var orderId = ""
    var vendorId = ""
    var imgStrVendor = ""
    var vendorName = ""
    var cellHeight = 0.0
    var ratingRestaurant = Float()
    var ratingDeliveryTime = Float()
    var ratingProductQuality = Float()
    var ratingValue = Float()
    var ratingPackaging = Float()
    var pageType = "reviews"
    var ratingArr = [NSLocalizedString("Delivery time", comment: ""), NSLocalizedString("Quality of food", comment: ""), NSLocalizedString("Value for money", comment: ""), NSLocalizedString("Order packaging", comment: "")]
    var reviewsModule : ReviewsModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: Api call
    func callGetReviewListApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
        aDictParameters[K_PARAMS_PAGE] = page
        aDictParameters[K_PARAMS_LIMIT] = limit
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_REVIEWS_LIST, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
               print(response)
               let aDictInfo = response as! [String : Any]
               if aDictInfo.count != 0 {
                   let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                   self.reviewsModule = try! JSONDecoder().decode(ReviewsModel.self, from: jsonData)
                   self.myTableReviewList.dataSource = self
                   self.myTableReviewList.delegate = self
                   self.myTableReviewList.reloadData()
                   if aDictInfo["error"] != nil{
                       let error = aDictInfo["error"] as! [String: String]
                       HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                   }
                   HELPER.hideLoadingAnimation()
               } else {
                   HELPER.hideLoadingAnimation()
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_REVIEWS_MODULE_EMPTY)
               }
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callPostReview(){

        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_ID] = orderId
        aDictParameters[K_PARAMS_VENDOR_RATING] = ratingRestaurant
        aDictParameters[K_PARAMS_DELIVERY_TIME] = ratingDeliveryTime
        aDictParameters[K_PARAMS_QUALITY] = ratingProductQuality
        aDictParameters[K_PARAMS_VALUE_FOR_MONEY] = ratingValue
        aDictParameters[K_PARAMS_ORDER_PACKING] = ratingPackaging
        aDictParameters[K_PARAMS_COMMENT] = self.myTxtComment.text
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_REVIEWS, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
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
                    self.dismiss(animated: true)
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
            var aDictParameters = [String : Any]()
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
            aDictParameters[K_PARAMS_PAGE] = page
            aDictParameters[K_PARAMS_LIMIT] = limit
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_REVIEWS_LIST, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
               do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(ReviewsModel.self, from: jsonData)
                        let reviewsList = modelData.reviewList
                        self.reviewsModule?.reviewList?.append(contentsOf: reviewsList ?? [])
                        self.myTableReviewList.reloadData()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView == myTableReviewList{
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
    
    func setupUI() {
        if pageType == "reviews"{
            self.myTableReviewList.register(UINib(nibName: "multiSelectionCell", bundle: nil), forCellReuseIdentifier: "selectionCell")
            callGetReviewListApi()
            self.myViewWriteRating.isHidden = true
        }else{
            self.myLblRestaurantName.text = isRTLenabled == true ? NSLocalizedString("Rate", comment: "") + " " + vendorName : vendorName + " " + NSLocalizedString("Rate", comment: "")
            self.myTxtComment.textAlignment = isRTLenabled == true ? .right : .left
            self.myViewWriteRating.isHidden = false
            myRatingRestaurant.emptyImage = UIImage(named: "ic_smile_5")
            myRatingRestaurant.fullImage = UIImage(named: "ic_smile_5_color")
            myRatingRestaurant.minRating = 0
            myRatingRestaurant.maxRating = 5
            myRatingRestaurant.rating = 0
            myRatingRestaurant.halfRatings = false
            myRatingRestaurant.editable = true
            myRatingDeliveryTime.emptyImage = UIImage(named: "ic_starEmpty")
            myRatingDeliveryTime.fullImage = UIImage(named: "ic_starFull")
            myRatingDeliveryTime.minRating = 0
            myRatingDeliveryTime.maxRating = 5
            myRatingDeliveryTime.rating = 0
            myRatingDeliveryTime.halfRatings = false
            myRatingDeliveryTime.editable = true
            myRatingProductQuality.emptyImage = UIImage(named: "ic_starEmpty")
            myRatingProductQuality.fullImage = UIImage(named: "ic_starFull")
            myRatingProductQuality.minRating = 0
            myRatingProductQuality.maxRating = 5
            myRatingProductQuality.rating = 0
            myRatingProductQuality.halfRatings = false
            myRatingProductQuality.editable = true
            myRatingValue.emptyImage = UIImage(named: "ic_starEmpty")
            myRatingValue.fullImage = UIImage(named: "ic_starFull")
            myRatingValue.minRating = 0
            myRatingValue.maxRating = 5
            myRatingValue.rating = 0
            myRatingValue.halfRatings = false
            myRatingValue.editable = true
            myRatingPackaging.emptyImage = UIImage(named: "ic_starEmpty")
            myRatingPackaging.fullImage = UIImage(named: "ic_starFull")
            myRatingPackaging.minRating = 0
            myRatingPackaging.maxRating = 5
            myRatingPackaging.rating = 0
            myRatingPackaging.halfRatings = false
            myRatingPackaging.editable = true
            myRatingRestaurant.delegate = self
            myRatingDeliveryTime.delegate = self
            myRatingValue.delegate = self
            myRatingPackaging.delegate = self
            myRatingProductQuality.delegate = self
            if isRTLenabled{
                self.myRatingRestaurant.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.myRatingDeliveryTime.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.myRatingProductQuality.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.myRatingValue.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.myRatingPackaging.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
            self.myScrollView.addSubview(self.myViewRatingContainer)
            self.myScrollView.contentSize.height = self.myViewRatingContainer.frame.size.height + 10
            self.myViewRatingContainer.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    //MARK: Button Back action
    @IBAction func clickBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func clickSubmit(_ sender: UIButton) {
        print(ratingRestaurant)
        if ratingRestaurant > 0{
            if ratingDeliveryTime > 0{
                if ratingProductQuality > 0{
                    if ratingValue > 0{
                        if ratingPackaging > 0{
                            callPostReview()
                        }else{
                            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please rate order packaging", comment: ""))
                        }
                    }else{
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please rate value for money", comment: ""))
                    }
                }else{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please rate product quality", comment: ""))
                }
            }else{
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please rate delivery time", comment: ""))
            }
        }else{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please rate the", comment: "") + " " + vendorName)
        }
    }
    
    @IBAction func clickRating1(_ sender: UIButton) {
        self.myImgRating1.image = UIImage(named: "ic_smile_1_color")
        self.myImgRating2.image = UIImage(named: "ic_smile_2")
        self.myImgRating3.image = UIImage(named: "ic_smile_3")
        self.myImgRating4.image = UIImage(named: "ic_smile_4")
        self.myImgRating5.image = UIImage(named: "ic_smile_5")
        self.ratingRestaurant = 1
    }
    
    @IBAction func clickRating2(_ sender: UIButton) {
        self.myImgRating1.image = UIImage(named: "ic_smile_1")
        self.myImgRating2.image = UIImage(named: "ic_smile_2_color")
        self.myImgRating3.image = UIImage(named: "ic_smile_3")
        self.myImgRating4.image = UIImage(named: "ic_smile_4")
        self.myImgRating5.image = UIImage(named: "ic_smile_5")
        self.ratingRestaurant = 2
    }
    
    @IBAction func clickRating3(_ sender: UIButton) {
        self.myImgRating1.image = UIImage(named: "ic_smile_1")
        self.myImgRating2.image = UIImage(named: "ic_smile_2")
        self.myImgRating3.image = UIImage(named: "ic_smile_3_color")
        self.myImgRating4.image = UIImage(named: "ic_smile_4")
        self.myImgRating5.image = UIImage(named: "ic_smile_5")
        self.ratingRestaurant = 3
    }
    
    @IBAction func clickRating4(_ sender: UIButton) {
        self.myImgRating1.image = UIImage(named: "ic_smile_1")
        self.myImgRating2.image = UIImage(named: "ic_smile_2")
        self.myImgRating3.image = UIImage(named: "ic_smile_3")
        self.myImgRating4.image = UIImage(named: "ic_smile_4_color")
        self.myImgRating5.image = UIImage(named: "ic_smile_5")
        self.ratingRestaurant = 4
    }
    
    @IBAction func clickRating5(_ sender: UIButton) {
        self.myImgRating1.image = UIImage(named: "ic_smile_1")
        self.myImgRating2.image = UIImage(named: "ic_smile_2")
        self.myImgRating3.image = UIImage(named: "ic_smile_3")
        self.myImgRating4.image = UIImage(named: "ic_smile_4")
        self.myImgRating5.image = UIImage(named: "ic_smile_5_color")
        self.ratingRestaurant = 5
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float)
    {
        if ratingView == myRatingRestaurant
        {
            self.ratingRestaurant = rating
        }else if ratingView == myRatingDeliveryTime{
            self.ratingDeliveryTime = rating
        }else if ratingView == myRatingValue{
            self.ratingValue = rating
        }else if ratingView == myRatingProductQuality{
            self.ratingProductQuality = rating
        }else if ratingView == myRatingPackaging{
            self.ratingPackaging = rating
        }
    }

    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float)
    {
        if ratingView == myRatingRestaurant
        {
            self.ratingRestaurant = rating
        }else if ratingView == myRatingDeliveryTime{
            self.ratingDeliveryTime = rating
        }else if ratingView == myRatingValue{
            self.ratingValue = rating
        }else if ratingView == myRatingProductQuality{
            self.ratingProductQuality = rating
        }else if ratingView == myRatingPackaging{
            self.ratingPackaging = rating
        }
    }
}

extension ReviewInfoVc : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return ratingArr.count
        }else {
            return reviewsModule?.reviewList?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }else if section == 1 {
            return nil
        }else {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "selectionCell") as! multiSelectionCell
            headerCell.lblSelectionTitle.text = NSLocalizedString("Reviews", comment: "")
            headerCell.lblSelectionTitle.font = UIFont(name: "Poppins-Medium", size: 18)
            return headerCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else if section == 1 {
            return 0
        }else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewTitleCell", for: indexPath) as! ReviewTblCell
            cell.myLblBasedOn.text = NSLocalizedString("Based on", comment: "") + " " + (self.reviewsModule?.total ?? "") + " " + NSLocalizedString("ratings", comment: "")
            cell.myLblReviewCount.text = self.reviewsModule?.avgVendorRating
            let trimmedUrl = imgStrVendor.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
            var activityLoader = UIActivityIndicatorView()
            activityLoader = UIActivityIndicatorView(style: .medium)
            activityLoader.center = cell.myImgVendor.center
            activityLoader.startAnimating()
            cell.myImgVendor.addSubview(activityLoader)
            cell.myImgVendor.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                if image != nil
                {
                    activityLoader.stopAnimating()
                }
                else
                {
                    print("image not found")
                    cell.myImgVendor.image = UIImage(named: "no_image")
                    activityLoader.stopAnimating()
                }
            })
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCategoryCell", for: indexPath) as! ReviewTblCell
            cell.myLblReviewCategory.text = "\(ratingArr[indexPath.row])"
            if indexPath.row == 0{
                let time = self.reviewsModule?.avgDeliveryTime ?? "0"
                cell.myViewRating?.rating = Float(time) ?? 0
                cell.myLblReviewCategoryCount.text = time
            }else if indexPath.row == 1{
                let quality = self.reviewsModule?.avgQuality ?? "0"
                cell.myViewRating?.rating = Float(quality) ?? 0
                cell.myLblReviewCategoryCount.text = quality
            }else if indexPath.row == 2{
                let avgValueForMoney = self.reviewsModule?.avgValueForMoney ?? "0"
                cell.myViewRating?.rating = Float(avgValueForMoney) ?? 0
                cell.myLblReviewCategoryCount.text = avgValueForMoney
            }else if indexPath.row == 3{
                let avgOrderPacking = self.reviewsModule?.avgOrderPacking ?? "0"
                cell.myViewRating?.rating = Float(avgOrderPacking) ?? 0
                cell.myLblReviewCategoryCount.text = avgOrderPacking
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTblCell
            cell.myLblReviewRating.text = self.reviewsModule?.reviewList?[indexPath.row].vendorRating
            let customerName = self.reviewsModule?.reviewList?[indexPath.row].customerName
            if isRTLenabled{
                cell.myLblReviewDate.text = (self.reviewsModule?.reviewList?[indexPath.row].date ?? "") + " " + (customerName ?? "")
            }else{
                cell.myLblReviewDate.text = (customerName ?? "") + " " + (self.reviewsModule?.reviewList?[indexPath.row].date ?? "")
            }
            cell.myLblReview.text = self.reviewsModule?.reviewList?[indexPath.row].comment
            cell.myLblReview.sizeToFit()
            cell.myLblReview.frame.size.width = cell.myLblReviewDate.frame.size.width
            cell.myLblReview.translatesAutoresizingMaskIntoConstraints = true
            cell.myLblReviewDate.frame.origin.y = cell.myLblReview.frame.origin.y + cell.myLblReview.frame.size.height + 8
            cell.myLblReviewDate.translatesAutoresizingMaskIntoConstraints = true
            cellHeight = cell.myLblReviewDate.frame.origin.y + 30
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        }else if indexPath.section == 1 {
            let totalRows = tableView.numberOfRows(inSection: indexPath.section)
            if indexPath.row == totalRows - 1 {
                return 57
            }else {
                return 50
            }
            
        }else {
            return cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let visibleRows = tableView.indexPathsForVisibleRows {
            let visibleSections = visibleRows.map({$0.section})
            if visibleSections.contains(0) {
                self.myViewNav.isHidden = true
            }else {
                self.myViewNav.isHidden = false
            }
        }
    }
}

//extension ReviewInfoVc: FloatRatingViewDelegate{
//    private func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float)
//    {
//        if ratingView == myRatingRestaurant
//        {
//            self.ratingRestaurant = rating
//        }else if ratingView == myRatingDeliveryTime{
//            self.ratingDeliveryTime = rating
//        }else if ratingView == myRatingValue{
//            self.ratingValue = rating
//        }else if ratingView == myRatingProductQuality{
//            self.ratingProductQuality = rating
//        }else if ratingView == myRatingPackaging{
//            self.ratingPackaging = rating
//        }
//    }
//
//    private func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float)
//    {
//        if ratingView == myRatingRestaurant
//        {
//            self.ratingRestaurant = rating
//        }else if ratingView == myRatingDeliveryTime{
//            self.ratingDeliveryTime = rating
//        }else if ratingView == myRatingValue{
//            self.ratingValue = rating
//        }else if ratingView == myRatingProductQuality{
//            self.ratingProductQuality = rating
//        }else if ratingView == myRatingPackaging{
//            self.ratingPackaging = rating
//        }
//    }
//}

extension ReviewInfoVc: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        self.myLblComment.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text.isEmpty
        {
            self.myLblComment.isHidden = false
        }
        else
        {
            self.myLblComment.isHidden = true
        }
    }
}
