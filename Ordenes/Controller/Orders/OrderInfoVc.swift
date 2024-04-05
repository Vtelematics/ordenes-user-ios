//
//  OrderInfoVc.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 18/08/22.
//

import UIKit

class OrderInfoVc: UIViewController {
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var myViewMainContainer: UIView!
    @IBOutlet weak var myViewOrderInfo: UIView!
    @IBOutlet weak var myViewOrderInfo2: UIView!
    @IBOutlet weak var myViewShippingAddress: UIView!
    @IBOutlet weak var myTableOrderInfo: UITableView!
    @IBOutlet weak var myLblRestaurantNameTitle: UILabel!
    @IBOutlet weak var myLblOrderStatusTitle: UILabel!
    @IBOutlet weak var myLblOrderDateTitle: UILabel!
    @IBOutlet weak var myLblOrderOrderIDTitle: UILabel!
    @IBOutlet weak var myLblOrderTypeTitle: UILabel!
    @IBOutlet weak var myLblRestaurantName: UILabel!
    @IBOutlet weak var myLblOrderStatus: UILabel!
    @IBOutlet weak var myLblOrderDate: UILabel!
    @IBOutlet weak var myLblScheduleDate: UILabel!
    @IBOutlet weak var myLblScheduleTitle: UILabel!
    @IBOutlet weak var myLblScheduleColon: UILabel!
    @IBOutlet weak var myLblOrderTypeColon: UILabel!
    @IBOutlet weak var myLblOrderOrderID: UILabel!
    @IBOutlet weak var myLblShippingAddressType: UILabel!
    @IBOutlet weak var myLblOrderType: UILabel!
    @IBOutlet weak var myLblShippingAddress: UILabel!
    @IBOutlet weak var myBtnReview: UIButton!
    @IBOutlet weak var myBtnTrack: UIButton!
    @IBOutlet weak var myLblYourComment: UILabel!
    @IBOutlet weak var myTxtReason: UITextView!
    @IBOutlet weak var myViewReason: UIView!
    
    var orderInfoModel : OrderInfo?
    var orderId = ""
    var isFromNotification = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callGetOrderInfoApi()
    }
    
    //MARK: Api Call
    func callGetOrderInfoApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_ORDER_ID] = orderId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_ORDER_INFO, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
               print(response)
               let aDictInfo = response as! [String : Any]
               if aDictInfo.count != 0 {
                   let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                   let modelData = try! JSONDecoder().decode(OrderInfoModel.self, from: jsonData)
                   self.orderInfoModel = modelData.order
                   self.myLblRestaurantName.text = self.orderInfoModel?.vendorName
                   self.myLblOrderOrderID.text = self.orderInfoModel?.orderID
                   self.myLblOrderStatus.text = self.orderInfoModel?.orderStatus
                   self.myLblOrderDate.text = self.orderInfoModel?.orderedDate
                   self.myLblShippingAddress.text = self.orderInfoModel?.deliveryAddress
                   if let status = self.orderInfoModel?.orderStatusID, status == "9"{
                       self.myBtnReview.isHidden = self.orderInfoModel?.reviewStatus == "1" ? false : true
                   }else{
                       self.myBtnReview.isHidden = true
                   }
                   if self.orderInfoModel?.orderedType == "1"{
                       if self.orderInfoModel?.scheduleStatus == "1"{
                           self.myLblScheduleDate.text = self.orderInfoModel?.scheduleDate
                           self.myLblScheduleDate.isHidden = false
                           self.myLblScheduleTitle.isHidden = false
                           self.myLblScheduleColon.isHidden = false
                       }else{
                           self.myViewOrderInfo2.frame.origin.y = self.myLblScheduleDate.frame.origin.y
                           self.myViewOrderInfo2.frame.origin.x = 0
                           self.myViewOrderInfo2.frame.size.width = self.myViewOrderInfo.frame.size.width
                       }
                       self.myLblOrderType.text = NSLocalizedString("Delivery", comment: "")
                       self.myBtnTrack.frame.origin.y = self.myViewOrderInfo2.frame.origin.y + self.myViewOrderInfo2.frame.height + 15
                       self.myLblShippingAddressType.text = NSLocalizedString("Shipping address", comment: "")
                       if let status = self.orderInfoModel?.orderStatusID, status == "4" || status == "7" || status == "13"{
                           self.myBtnTrack.isHidden = true
                           self.myViewOrderInfo.frame.size.height = self.myBtnTrack.frame.origin.y + 5
                           self.myViewOrderInfo.translatesAutoresizingMaskIntoConstraints = true
                       }else{
                           self.myBtnTrack.isHidden = false
                           self.myViewOrderInfo.frame.size.height = self.myBtnTrack.frame.origin.y + 45
                           self.myViewOrderInfo.translatesAutoresizingMaskIntoConstraints = true
                           if self.orderInfoModel?.orderStatusID == "1" && self.orderInfoModel?.cancelStatus == "1"{
                               self.myBtnTrack.setTitle(NSLocalizedString("Cancel Order", comment: ""), for: .normal)
                           }else{
                               self.myBtnTrack.setTitle(NSLocalizedString("Track order", comment: ""), for: .normal)
                           }
                       }
                   }else{
                       self.myLblShippingAddressType.text = NSLocalizedString("Pickup address", comment: "")
                       if self.orderInfoModel?.scheduleStatus == "1"{
                           self.myLblScheduleDate.text = self.orderInfoModel?.scheduleDate
                           self.myLblScheduleDate.isHidden = false
                           self.myLblScheduleTitle.isHidden = false
                           self.myLblScheduleColon.isHidden = false
                       }else{
                           self.myViewOrderInfo2.frame.origin.y = self.myLblScheduleDate.frame.origin.y
                           self.myViewOrderInfo2.frame.origin.x = 0
                           self.myViewOrderInfo2.frame.size.width = self.myViewOrderInfo.frame.size.width
                       }
                       self.myLblOrderType.text = NSLocalizedString("Pickup", comment: "")
                       self.myBtnTrack.frame.origin.y = self.myViewOrderInfo2.frame.origin.y + self.myViewOrderInfo2.frame.height + 15
                       if let status = self.orderInfoModel?.orderStatusID, status == "4" || status == "7" || status == "13"{
                           self.myBtnTrack.isHidden = true
                           self.myViewOrderInfo.frame.size.height = self.myBtnTrack.frame.origin.y + 5
                       }else{
                           self.myBtnTrack.isHidden = false
                           self.myViewOrderInfo.frame.size.height = self.myBtnTrack.frame.origin.y + 45
                           self.myViewOrderInfo.translatesAutoresizingMaskIntoConstraints = true
                           if self.orderInfoModel?.orderStatusID == "1" && self.orderInfoModel?.cancelStatus == "1"{
                               self.myBtnTrack.setTitle(NSLocalizedString("Cancel Order", comment: ""), for: .normal)
                           }else{
                               self.myBtnTrack.setTitle(NSLocalizedString("Locate vendor", comment: ""), for: .normal)
                           }
                       }
                       self.myViewOrderInfo.translatesAutoresizingMaskIntoConstraints = true
                   }
                   if aDictInfo["error"] != nil{
                       let error = aDictInfo["error"] as! [String: String]
                       HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                   }
               } else {
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_ORDER_MODULE_EMPTY)
               }
               self.myTableOrderInfo.dataSource = self
               self.myTableOrderInfo.delegate = self
               self.myTableOrderInfo.reloadData()
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                   self.setFrame()
               }
            } catch {
                HELPER.hideLoadingAnimation()
                print(error.localizedDescription)
            }
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callPostCancelApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_ORDER_ID] = orderId
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_COMMENT] = self.myTxtReason.text
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_ORDER_CANCEL, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
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
                   self.myViewReason.isHidden = true
                   self.callGetOrderInfoApi()
               }else{
                   self.myViewReason.isHidden = true
                   HELPER.showAlertControllerWithOkActionBlock(aViewController: self, aStrMessage: success["message"] as! String) { action in
                       self.callGetOrderInfoApi()
                   }
               }
            } catch {
                HELPER.hideLoadingAnimation()
                print(error.localizedDescription)
            }
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
        self.myViewOrderInfo.layer.shadowColor = UIColor.darkGray.cgColor
        self.myViewOrderInfo.layer.shadowOpacity = 0.3
        self.myViewOrderInfo.layer.shadowOffset = CGSize.zero
        self.myViewOrderInfo.layer.shadowRadius = 3
        self.myViewOrderInfo.layer.masksToBounds = false
        self.myViewShippingAddress.layer.shadowColor = UIColor.gray.cgColor
        self.myViewShippingAddress.layer.shadowOpacity = 0.3
        self.myViewShippingAddress.layer.shadowOffset = CGSize.zero
        self.myViewOrderInfo.layer.shadowRadius = 3
        self.myViewShippingAddress.layer.masksToBounds = false
        self.myTableOrderInfo.layer.shadowColor = UIColor.gray.cgColor
        self.myTableOrderInfo.layer.shadowOpacity = 0.3
        self.myTableOrderInfo.layer.shadowOffset = CGSize.zero
        self.myViewOrderInfo.layer.shadowRadius = 3
        self.myTableOrderInfo.layer.masksToBounds = false
        self.myLblRestaurantName.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblRestaurantNameTitle.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblOrderOrderID.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblOrderOrderIDTitle.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblOrderStatus.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblOrderStatusTitle.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblOrderDate.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblOrderDateTitle.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblOrderTypeTitle.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblOrderType.textAlignment = isRTLenabled == true ? .right : .left
        
        self.myTableOrderInfo.register(UINib(nibName: "OrderInfoProductTblCell", bundle: nil), forCellReuseIdentifier: "orderInfoProductCell")
        self.myTableOrderInfo.register(UINib(nibName: "CartTotalTblCell", bundle: nil), forCellReuseIdentifier: "cartTotalCell")
    }
    
    func setFrame(){
        self.myViewShippingAddress.frame.origin.y = self.myViewOrderInfo.frame.origin.y + self.myViewOrderInfo.frame.size.height + 12
        self.myViewShippingAddress.translatesAutoresizingMaskIntoConstraints = true
        self.myTableOrderInfo.frame.origin.y = self.myViewShippingAddress.frame.origin.y + self.myViewShippingAddress.frame.size.height + 12
        self.myTableOrderInfo.frame.size.height = self.myTableOrderInfo.contentSize.height
        self.myTableOrderInfo.translatesAutoresizingMaskIntoConstraints = true
        self.myViewMainContainer.frame.size.height =  self.myTableOrderInfo.frame.size.height + self.myTableOrderInfo.frame.origin.y + 10
        self.myViewMainContainer.translatesAutoresizingMaskIntoConstraints = true
        self.myScrollView.contentSize.height =  self.myViewMainContainer.frame.size.height + self.myViewMainContainer.frame.origin.y + 10
        HELPER.hideLoadingAnimation()
    }
    
    //MARK: Button Back action
    @IBAction func clickBack(_ sender: UIButton) {
        if isFromNotification{
            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
            let navi = UINavigationController.init(rootViewController: aViewController)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
            appDelegate.window?.rootViewController = navi
            appDelegate.window?.makeKeyAndVisible()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func clickTrack(_ sender: UIButton) {
        if self.orderInfoModel?.orderStatusID == "1" && self.orderInfoModel?.cancelStatus == "1"{
            self.myTxtReason.text = ""
            self.myViewReason.isHidden = false
        }else{
            if orderInfoModel?.orderedType == "1"{
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: OrderConfirmVc.storyboardID) as! OrderConfirmVc
                aViewController.orderId = orderId
                aViewController.isFromSuccess = false
                self.navigationController?.pushViewController(aViewController, animated: true)
            }else{
                let vendorLat = orderInfoModel?.vendorLatitude ?? ""
                let vendorLong = orderInfoModel?.vendorLongitude ?? ""
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                    if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(vendorLat),\(vendorLong)&directionsmode=driving&x-success=sourceapp://?resume=true&x-source=SourceApp") {
                        UIApplication.shared.open(url, options: [:])
                    }
                }else{
                    if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(vendorLat),\(vendorLong)&directionsmode=driving") {
                        UIApplication.shared.open(urlDestination)
                    }
                }
            }
        }
    }
    
    @IBAction func clickWriteReview(_ sender: UIButton) {
        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: ReviewInfoVc.storyboardID) as! ReviewInfoVc
        aViewController.modalPresentationStyle = .fullScreen
        aViewController.orderId = orderId
        aViewController.pageType = "rating"
        aViewController.vendorName = orderInfoModel?.vendorName ?? ""
        present(aViewController, animated: true)
    }
    
    @IBAction func clickSubmitCancelReason(_ sender: UIButton) {
        if self.myTxtReason.text.isEmpty{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle:NSLocalizedString("Sorry", comment: "") , aStrMessage: NSLocalizedString("Please enter cancel reason", comment: ""))
        }else{
            callPostCancelApi()
        }
    }
    
    @IBAction func clickCancelCancelOrder(_ sender: UIButton) {
        self.myViewReason.isHidden = true
    }
}


extension OrderInfoVc : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.orderInfoModel?.product?.count ?? 0
        }else if section == 1{
            return self.orderInfoModel?.total?.count ?? 0
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderInfoProductCell", for: indexPath) as! OrderInfoProductTblCell
            cell.lblProductName.text = self.orderInfoModel?.product?[indexPath.row].name
            cell.lblProductPrice.text = self.orderInfoModel?.product?[indexPath.row].price
            let quantity = self.orderInfoModel?.product?[indexPath.row].quantity
            let price = self.orderInfoModel?.product?[indexPath.row].price
            cell.lblProductPrice.text = (quantity ?? "") + " x " + (price ?? "")
            var optionsStr = ""
            for obj in self.orderInfoModel?.product?[indexPath.row].option ?? []{
                let option = (obj.optionName ?? "") + ":" + (obj.optionValue ?? "")
                optionsStr = optionsStr + option + "\n"
            }
            cell.lblProductOption.text = optionsStr
            cell.lblProductOption.sizeToFit()
            cell.lblProductOption.translatesAutoresizingMaskIntoConstraints = true
            cell.lblLine.frame.origin.y = cell.lblProductOption.frame.origin.y + cell.lblProductOption.frame.size.height
            cell.lblLine.translatesAutoresizingMaskIntoConstraints = true
            return cell
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cartTotalCell", for: indexPath) as! CartTotalTblCell
            cell.myLblPriceType.text = self.orderInfoModel?.total?[indexPath.row].title
            cell.myLblTotalPrice.text = self.orderInfoModel?.total?[indexPath.row].text
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! OrderInfoProductTblCell
            cell.myLblPaymentType.text = self.orderInfoModel?.paymentMethod
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return UITableView.automaticDimension
        }else if indexPath.section == 1{
            return 30
        }else{
            return 100
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return UITableView.automaticDimension
        }else if indexPath.section == 1{
            return 30
        }else{
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

extension OrderInfoVc: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        self.myLblYourComment.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text.isEmpty
        {
            self.myLblYourComment.isHidden = false
        }
        else
        {
            self.myLblYourComment.isHidden = true
        }
    }
}
