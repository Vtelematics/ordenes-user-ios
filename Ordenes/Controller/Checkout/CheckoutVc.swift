//
//  CheckoutVc.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 22/07/22.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseAuth
import OneSignal

class CheckoutVc: UIViewController {
    
    @IBOutlet var myViewSchedule : UIView!
    @IBOutlet var myTblSchedule : UITableView!
    @IBOutlet var myTblTotal : UITableView!
    @IBOutlet var myViewScroll : UIScrollView!
    @IBOutlet var myViewContainer : UIView!
    @IBOutlet var myViewAddress : UIView!
    @IBOutlet var myViewAddressDetails : UIView!
    @IBOutlet var myViewContactless : UIView!
    @IBOutlet var myBtnContactless : UIButton!
    @IBOutlet var myViewPaymentMethod : UIView!
    @IBOutlet var myViewCouponContainer : UIView!
    @IBOutlet var myViewEmptyAddress : UIView!
    @IBOutlet weak var myLblEdit: UILabel!
    @IBOutlet weak var myLblNavTitle: UILabel!
    @IBOutlet weak var myBtnCheckout: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    //Address
    @IBOutlet var myLblUserName : UILabel!
    @IBOutlet var myLblAddress1 : UILabel!
    @IBOutlet var myLblAddress2 : UILabel!
    @IBOutlet var myLblMobile : UILabel!
    
    //coupon
    @IBOutlet weak var myLblCouponTitle: UILabel!
    @IBOutlet weak var myLblCoupon: UILabel!
    @IBOutlet weak var myBtnCoupon: UIButton!
    @IBOutlet var myViewCoupon : UIView!
    @IBOutlet var myViewCouponChild1 : UIView!
    @IBOutlet var myViewCouponChild2 : UIView!
    @IBOutlet weak var myTxtCoupon: kTextFiledPlaceHolder!
    @IBOutlet weak var myCollCoupon: UICollectionView!
    
    //payment
    @IBOutlet var myLblCOD : UILabel!
    @IBOutlet var myBtnCod : UIButton!
    @IBOutlet var myLblOnline : UILabel!
    @IBOutlet var myLblPaymentError : UILabel!
    @IBOutlet var myViewCOD : UIView!
    @IBOutlet var myViewOnline : UIView!
    @IBOutlet var myImgRadioCod : UIImageView!
    @IBOutlet var myImgRadioOnline : UIImageView!
    @IBOutlet var myViewContactlessWarning : UIView!
    @IBOutlet var myViewAirtelMobileNumber : UIView!
    @IBOutlet weak var myTxtAirtelMobileNumber: UITextField!
    
    @IBOutlet weak var myViewOTP: UIView!
    @IBOutlet weak var myLblMobileOtp: UILabel!
    @IBOutlet weak var myTxtOtp: UITextField!
    @IBOutlet weak var myLblTimer: UILabel!
    @IBOutlet weak var myBtnResend: UIButton!
    @IBOutlet weak var myLblMobileVerify: UILabel!
    @IBOutlet weak var myViewVerifyMobile: UIView!
    @IBOutlet weak var myViewPickupAddress: UIView!
    @IBOutlet weak var myLblPickupAddress: UILabel!
    @IBOutlet weak var myLblPickupMobile: UILabel!
    
    //Guest Pickup
    @IBOutlet weak var myViewGuestPickup: UIView!
    @IBOutlet weak var myTxtGuestFname: UITextField!
    @IBOutlet weak var myTxtGuestLname: UITextField!
    @IBOutlet weak var myTxtGuestEmail: UITextField!
    @IBOutlet weak var myTxtGuestMobile: UITextField!
    @IBOutlet weak var myLblGuestCountryCode: UILabel!
    @IBOutlet weak var myPickerView: UIPickerView!
    @IBOutlet weak var myViewPickervw: UIView!
    @IBOutlet weak var myViewScheduleTime: UIView!
    @IBOutlet weak var myViewScheduleTime2: UIView!
    @IBOutlet weak var myLblDeliveryTime1: UILabel!
    @IBOutlet weak var myLblDeliveryTime2: UILabel!
    @IBOutlet weak var myLblDeliveryTime3: UILabel!
    @IBOutlet weak var myLblDeliveryTime4: UILabel!
    @IBOutlet weak var myViewDeliveryTime: UIView!
    @IBOutlet weak var myBtnSchedule: UIButton!
    @IBOutlet weak var myLblSchedule: UILabel!
    
    var vendorId = ""
    var selectedCountryCodeIndex = 0
    var countryArray : [[String: Any]] = []
    var timer:Timer?
    var timeLeft = 30
    var currentVerificationId = ""
    var noteStr = ""
    var couponId = ""
    var couponList = [[String : Any]]()
    var contactlessEnabled = false
    var selectedPaymentListId = ""
    var cartModel : CartModel?
    var paymentModel : PaymentModel?
    var isOTPVerified = false
    var selectedScheduleTime = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.callGetPaymentMethodApi()
    }
    
    //MARK: API Call
    func callGetPaymentMethodApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        aDictParameters[K_PARAMS_VENDOR_ID] = vendorId
        aDictParameters[K_PARAMS_COUPON_ID] = self.couponId
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        print(aDictParameters)
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_PAYMENT_METHODS, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                print(response)
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    self.paymentModel = try! JSONDecoder().decode(PaymentModel.self, from: jsonData)
                    self.autoScrollSize()
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }
                    HELPER.hideLoadingAnimation()
                    self.callGetCartItemsApi()
                } else {
                    HELPER.hideLoadingAnimation()
                    self.callGetCartItemsApi()
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_PAYMENT_MODULE_EMPTY)
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            self.callGetCartItemsApi()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callGetCartItemsApi() {
        let dayId = Date().dayNumberOfWeek()
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_COUPON_ID] = self.couponId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_CART_PRODUCTS, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                print(response)
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    self.cartModel = try! JSONDecoder().decode(CartModel.self, from: jsonData)
                    self.myLblNavTitle.text = self.cartModel?.vendorName
                    if self.paymentModel?.errorWarning == ""{
                        self.myLblCoupon.text = self.couponId != "" ? NSLocalizedString("Remove coupon", comment: "") : NSLocalizedString("Apply coupon", comment: "")
                    }else{
                        self.couponId = ""
                        self.myLblCoupon.text =  NSLocalizedString("Apply coupon", comment: "")
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: self.paymentModel?.errorWarning ?? "")
                    }
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }
                } else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_CART_MODULE_EMPTY)
                }
                self.myTblTotal.dataSource = self
                self.myTblTotal.delegate = self
                self.myTblTotal.reloadData()
                self.autoScrollSize()
            } catch {
                print(error.localizedDescription)
            }
            HELPER.hideLoadingAnimation()
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callGetCouponApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_VENDOR_ID] = cartModel?.vendorID
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        let lat = self.paymentModel?.address?.latitude
        let long = self.paymentModel?.address?.longitude
        if lat != "" && long != ""{
            aDictParameters[K_PARAMS_LAT] = lat
            aDictParameters[K_PARAMS_LONG] = long
        }else{
            aDictParameters[K_PARAMS_LAT] = globalLatitude
            aDictParameters[K_PARAMS_LONG] = globalLongitude
        }
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_COUPONS, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
            do {
                print(response)
                var success:[String:Any]
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
                    self.couponList = response["coupon"] as! [[String: Any]]
                    if self.couponList.count != 0{
                        self.myCollCoupon.frame.size.height = 142
                        self.myViewCouponChild2.frame.origin.y = self.myCollCoupon.frame.size.height + 20
                        self.myViewCouponChild1.frame.size.height = self.myViewCouponChild2.frame.origin.y + self.myViewCouponChild2.frame.size.height
                    }else{
                        self.myCollCoupon.frame.size.height = 0
                        self.myViewCouponChild2.frame.origin.y = 8
                        self.myViewCouponChild1.frame.size.height = self.myViewCouponChild2.frame.origin.y + self.myViewCouponChild2.frame.size.height
                    }
                    self.myCollCoupon.translatesAutoresizingMaskIntoConstraints = true
                    self.myViewCouponChild2.translatesAutoresizingMaskIntoConstraints = true
                    self.myViewCouponChild1.translatesAutoresizingMaskIntoConstraints = true
                    self.myCollCoupon.dataSource = self
                    self.myCollCoupon.delegate = self
                    self.myCollCoupon.reloadData()
                    self.couponId = ""
                    self.myTxtCoupon.text = ""
                    self.myViewCouponChild1.isHidden = false
                    self.myViewCoupon.isHidden = false
                }else{
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
    
    func callCheckDeliveryAvailability() {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        let lat = self.paymentModel?.address?.latitude
        let long = self.paymentModel?.address?.longitude
        let address_id = self.paymentModel?.address?.addressID
        let zone = self.paymentModel?.address?.zoneId
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LAT] = lat
        aDictParameters[K_PARAMS_LONG] = long
        aDictParameters[K_PARAMS_VENDOR_ID] = self.cartModel?.vendorID
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ADDRESS_ID] = address_id
        aDictParameters[K_PARAMS_ZONE_ID] = zone
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_IS_DELIVERY, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            print(response)
            var success:[String:Any]
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
                self.callConfirmOrderApi()
            }else{
                HELPER.hideLoadingAnimation()
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
            }
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callConfirmOrderApi() {
        let dayId = Date().dayNumberOfWeek()
        let c_date = Date()
        let format = DateFormatter()
        format.dateFormat = "MM-dd-yyyy"
        let currentDate = format.string(from: c_date)
        format.dateFormat = "HH:mm"
        let currentTime = format.string(from: c_date)
        var pushId = ""
        if let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId{
            pushId = userId
        }
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_COUPON_ID] = self.couponId
        aDictParameters[K_PARAMS_DELIVERY_TYPE] = "now"
        aDictParameters[K_PARAMS_ORDER_DATE] = currentDate
        aDictParameters[K_PARAMS_ORDER_TIME] = currentTime
        aDictParameters[K_PARAMS_NOTE] = self.noteStr
        aDictParameters[K_PARAMS_PAYMENT_LIST_ID] = self.selectedPaymentListId
        aDictParameters[K_PARAMS_CONTACTLESS_DELIVERY] = contactlessEnabled == true ? "1" : "0"
        aDictParameters[K_PARAMS_DAY_ID] = dayId
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_PUSH_ID] = pushId
        aDictParameters[K_PARAMS_ORDER_TYPE] = self.cartModel?.orderType
        if selectedScheduleTime != 1000{
            aDictParameters[K_PARAMS_SCHEDULE_STATUS] = "1"
            aDictParameters[K_PARAMS_SCHEDULE_DATE] = self.paymentModel?.schedule?.date?[selectedScheduleTime]
        }else{
            aDictParameters[K_PARAMS_SCHEDULE_STATUS] = "0"
        }
        if cartModel?.orderType == "2" {
            let editedCode = myLblGuestCountryCode.text?.replacingOccurrences(of: "+", with: "")
            if guestStatus == "1"{
                let guestPickup = [
                    K_PARAMS_F_NAME : self.myTxtGuestFname.text!,
                    K_PARAMS_L_NAME : self.myTxtGuestLname.text!,
                    K_PARAMS_EMAIL : self.myTxtGuestEmail.text!,
                    K_PARAMS_COUNTRY_CODE : editedCode,
                    K_PARAMS_MOBILE : self.myTxtGuestMobile.text!,
                ] as? [String : Any]
                aDictParameters[K_PARAMS_GUEST_PICKUP] = guestPickup
            }else{
                aDictParameters[K_PARAMS_GUEST_PICKUP] = "0"
            }
            aDictParameters[K_PARAMS_ADDRESS_ID] = "0"
        }else{
            aDictParameters[K_PARAMS_ADDRESS_ID] = self.paymentModel?.address?.addressID
            aDictParameters[K_PARAMS_GUEST_PICKUP] = "0"
        }
        aDictParameters[K_PARAMS_AIRTEL_MOBILE] = self.myTxtAirtelMobileNumber.text
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_CONFIRM_ORDER, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            print(response)
            var success:[String:Any]
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
                let orderId = response["order_id"] as? String
                if self.selectedPaymentListId == "1" {
                    self.callPlaceOrderApi(orderID: orderId ?? "")
                }else{
                    let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: WebViewVc.storyboardID) as! WebViewVc
                    aViewController.paymentBaseUrl = AIRTEL_PAYMENT_BASE_URL
                    aViewController.orderId = orderId ?? ""
                    self.navigationController?.isNavigationBarHidden = true
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }
                
            }else{
                HELPER.hideLoadingAnimation()
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
            }
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callPlaceOrderApi(orderID : String) {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_ORDER_ID] = orderID
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_PLACE_ORDER, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            print(response)
            var success:[String:Any]
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
                if self.cartModel?.orderType == "2"{
                    let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: SuccessVc.storyboardID) as! SuccessVc
                    self.navigationController?.isNavigationBarHidden = true
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }else{
                    let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: OrderConfirmVc.storyboardID) as! OrderConfirmVc
                    aViewController.isFromSuccess = true
                    aViewController.orderId = orderID
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }
                self.myViewOTP.isHidden = true
                self.isOTPVerified = true
                self.myViewOTP.isHidden = true
                self.timer?.invalidate()
                self.timer = nil
                self.myLblTimer.isHidden = true
                self.myBtnResend.isHidden = false
                HELPER.hideLoadingAnimation()
            }else{
                HELPER.hideLoadingAnimation()
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
            }
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func callPostCouponCode(couponCode : String) {
        var subTotal = ""
        for obj in cartModel?.totals ?? []{
            if let key = obj.titleKey, key == "sub_total"{
                subTotal = obj.textAmount ?? ""
                break
            }
        }
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_VENDOR_ID] = cartModel?.vendorID
        aDictParameters[K_PARAMS_COUPON_CODE] = couponCode
        aDictParameters[K_PARAMS_SUB_TOTAL] = subTotal
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_LAT] = globalLatitude
        aDictParameters[K_PARAMS_LONG] = globalLongitude
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_COUPON_CODE, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
            do {
                print(response)
                var success:[String:Any]
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
                    self.couponId = response["coupon_id"] as! String
                    HELPER.showAlertControllerWithOkActionBlock(aViewController: self, aStrMessage: NSLocalizedString("Coupon applied successfully", comment: "")) { UIAlertAction in
                        self.myViewCoupon.isHidden = true
                        self.callGetCartItemsApi()
                    }
                }else{
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
    
    func callGetCountryApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_COUNTRY, isAuthorize: false, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
            do {
                let aDictInfo = response as! [String : Any]
                self.countryArray = []
                if aDictInfo.count != 0 {
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }else{
                        self.countryArray = aDictInfo["countries"] as! [[String : Any]]
                    }
                    self.myTxtGuestFname.text = ""
                    self.myTxtGuestLname.text = ""
                    self.myTxtGuestEmail.text = ""
                    self.myTxtGuestMobile.text = ""
                    self.myViewGuestPickup.isHidden = false
                    self.myPickerView.dataSource = self
                    self.myPickerView.delegate = self
                    self.myPickerView.reloadAllComponents()
                } else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_COUNTRY_CODE_MODULE_EMPTY)
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
        self.myLblCoupon.textAlignment = isRTLenabled == true ? .left : .right
        self.myLblEdit.textAlignment = isRTLenabled == true ? .left : .right
        self.myViewCoupon.isHidden = true
        self.myViewAddress.layer.borderWidth = 1
        self.myViewAddress.layer.borderColor = UIColor.lightGray.cgColor
        //self.myViewContainer
        self.myViewScroll.addSubview(self.myViewContainer)
        let img = UIImage(named: "ic_uncheck")
        self.myBtnContactless.setBackgroundImage(img, for: .normal)
        self.myTxtCoupon.placeHolderColor = UIColor(red: 0/255, green: 145/255, blue: 147/255, alpha: 1)
        self.myImgRadioCod.image = self.myImgRadioCod.image!.withRenderingMode(.alwaysTemplate)
        self.myImgRadioCod.tintColor = ConfigTheme.themeColor
        self.myImgRadioOnline.image = self.myImgRadioOnline.image!.withRenderingMode(.alwaysTemplate)
        self.myImgRadioOnline.tintColor = ConfigTheme.themeColor
        self.myViewContainer.isHidden = true
        self.myViewGuestPickup.isHidden = true
        self.myViewOTP.isHidden = true
        self.myViewSchedule.isHidden = true
        self.myBtnCheckout.isUserInteractionEnabled = false
        self.myBtnCheckout.alpha = 0.5
    }
    
    func autoScrollSize() {
        if self.cartModel?.orderType == "2"{
            self.myViewEmptyAddress.isHidden = true
            self.myViewAddressDetails.isHidden = true
            self.myViewContactless.isHidden = true
            self.myLblPickupAddress.text = self.cartModel?.vendorAddress
            if isRTLenabled{
                self.myLblPickupMobile.text = (self.cartModel?.vendorMobile ?? "") + " :" + NSLocalizedString("Mobile", comment: "")
            }else{
                self.myLblPickupMobile.text = NSLocalizedString("Mobile", comment: "") + ": " + (self.cartModel?.vendorMobile ?? "")
            }
            let selectedLat = self.cartModel?.restaurantLatitude ?? ""
            let selectedLong = self.cartModel?.restaurantLongitude ?? ""
            if selectedLat != "" && selectedLong != ""{
                let camera = GMSCameraPosition.camera(withLatitude: Double(selectedLat) ?? 0, longitude: Double(selectedLong) ?? 0, zoom: 17.0)
                self.mapView?.camera = camera
                self.mapView?.animate(to: camera)
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: Double(selectedLat) ?? 0, longitude: Double(selectedLong) ?? 0)
                marker.map = mapView
            }
            self.myViewAddress.frame.size.height = self.myViewPickupAddress.frame.origin.y + self.myViewPickupAddress.frame.size.height
            self.myViewAddress.translatesAutoresizingMaskIntoConstraints = true
            if isRTLenabled{
                self.myLblDeliveryTime1.text = NSLocalizedString("Approximately preparing time is", comment: "")
                if self.selectedScheduleTime != 1000 && self.selectedScheduleTime < self.paymentModel?.schedule?.day?.count ?? 0{
                    self.myLblDeliveryTime2.text = self.paymentModel?.schedule?.day?[self.selectedScheduleTime] as? String
                    self.myLblSchedule.text = NSLocalizedString("Change", comment: "")
                }else{
                    self.myLblDeliveryTime2.text = NSLocalizedString("mins", comment: "") + " " + (self.paymentModel?.deliveryTime ?? "30") + " " + NSLocalizedString("Within", comment: "")
                    self.myLblSchedule.text = NSLocalizedString("Schedule your order", comment: "")
                }
            }else{
                self.myLblDeliveryTime1.text = NSLocalizedString("Approximately preparing time is", comment: "")
                if self.selectedScheduleTime != 1000 && self.selectedScheduleTime < self.paymentModel?.schedule?.day?.count ?? 0{
                    self.myLblDeliveryTime2.text = self.paymentModel?.schedule?.day?[self.selectedScheduleTime] as? String
                    self.myLblSchedule.text = NSLocalizedString("Change", comment: "")
                }else{
                    self.myLblDeliveryTime2.text = NSLocalizedString("Within", comment: "") + " " + (self.paymentModel?.deliveryTime ?? "30") + " " + NSLocalizedString("mins", comment: "")
                    self.myLblSchedule.text = NSLocalizedString("Schedule your order", comment: "")
                }
            }
            if self.paymentModel?.scheduleStatus == "1"{
                self.myLblSchedule.isHidden = false
                self.myBtnSchedule.isHidden = false
            }else{
                self.myLblSchedule.isHidden = true
                self.myBtnSchedule.isHidden = true
            }
            self.myViewScheduleTime.frame.origin.y = self.myViewAddress.frame.origin.y + self.myViewAddress.frame.size.height + 8
            self.myViewScheduleTime.translatesAutoresizingMaskIntoConstraints = true
            self.myViewCouponContainer.frame.origin.y = self.myViewScheduleTime.frame.origin.y + self.myViewScheduleTime.frame.size.height + 8
            self.myViewCouponContainer.translatesAutoresizingMaskIntoConstraints = true
            self.myViewContactless.isHidden = true
            self.myViewPaymentMethod.frame.origin.y = self.myViewCouponContainer.frame.origin.y + self.myViewCouponContainer.frame.size.height + 8
            self.myViewPaymentMethod.translatesAutoresizingMaskIntoConstraints = true
            self.myViewPickupAddress.isHidden = false
            self.mapView.isHidden = false
        }else if self.cartModel?.orderType == "1"{
            let address = self.paymentModel?.address
            if address != nil {
                if address?.addressID == ""{
                    self.myViewEmptyAddress.isHidden = false
                    self.myViewAddressDetails.isHidden = true
                    self.mapView.isHidden = true
                    self.myViewAddress.frame.size.height = self.myViewEmptyAddress.frame.size.height
                }else{
                    self.myViewEmptyAddress.isHidden = true
                    self.myViewAddressDetails.isHidden = false
                    self.mapView.isHidden = false
                    self.myViewAddress.frame.size.height = self.myViewAddressDetails.frame.origin.y + self.myViewAddressDetails.frame.size.height
                    self.myLblUserName.text = "\(address?.firstName ?? "") \(address?.lastName ?? "")"
                    if address?.addressType == "1"{
//                        self.myLblAddress1.text = NSLocalizedString("House", comment: "") + " " + "(\(address?.area ?? ""))"
                        self.myLblAddress1.text = address?.address ?? ""
                        var addressStr = ""
                        if address?.block != ""{
                            addressStr = (address?.block ?? "") + ","
                        }
                        if address?.street != ""{
                            addressStr += (address?.street ?? "") + ","
                        }
                        if address?.buildingName != ""{
                            addressStr += (address?.buildingName ?? "") + ","
                        }
                        self.myLblAddress2.text = addressStr != "" ? String(addressStr.dropLast()) : addressStr
                    }else{
                        var addressStr = ""
                        if address?.block != ""{
                            addressStr = (address?.block ?? "") + ","
                        }
                        if address?.street != ""{
                            addressStr += (address?.street ?? "") + ","
                        }
                        if address?.buildingName != ""{
                            addressStr += (address?.buildingName ?? "") + ","
                        }
                        if address?.floor != ""{
                            addressStr += (address?.floor ?? "") + ","
                        }
                        if address?.doorNo != ""{
                            addressStr += (address?.doorNo ?? "") + ","
                        }
                        self.myLblAddress2.text = addressStr != "" ? String(addressStr.dropLast()) : addressStr
//                        if address?.addressType == "2"{
//                            self.myLblAddress1.text = NSLocalizedString("Apartment", comment: "") + " " + "(\(address?.area ?? ""))"
//                        }else{
//                            self.myLblAddress1.text = NSLocalizedString("Office", comment: "") + " " + "(\(address?.area ?? ""))"
//                        }
                        self.myLblAddress1.text = address?.address ?? ""
                    }
                    let selectedLat = address?.latitude ?? ""
                    let selectedLong = address?.longitude ?? ""
                    if selectedLat != "" && selectedLong != ""{
                        let camera = GMSCameraPosition.camera(withLatitude: Double(selectedLat) ?? 0, longitude: Double(selectedLong) ?? 0, zoom: 17.0)
                        self.mapView?.camera = camera
                        self.mapView?.animate(to: camera)
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: Double(selectedLat) ?? 0, longitude: Double(selectedLong) ?? 0)
                        marker.map = mapView
                    }
                    if isRTLenabled{
                        self.myLblMobile.text = (address?.mobile ?? "") + " :" + NSLocalizedString("Mobile", comment: "")
                    }else{
                        self.myLblMobile.text = NSLocalizedString("Mobile", comment: "") + ": " + (address?.mobile ?? "")
                    }
                }
            }else{
                self.myViewEmptyAddress.isHidden = false
                self.myViewAddressDetails.isHidden = true
                self.mapView.isHidden = true
                self.myViewAddress.frame.size.height = self.myViewEmptyAddress.frame.size.height
            }
            self.myViewContactless.isHidden = false
            self.myViewAddress.translatesAutoresizingMaskIntoConstraints = true
            if isRTLenabled{
                self.myLblDeliveryTime1.text = NSLocalizedString("Approximately delivery time is", comment: "")
                if self.selectedScheduleTime != 1000 && self.selectedScheduleTime < self.paymentModel?.schedule?.day?.count ?? 0{
                    self.myLblDeliveryTime2.text = self.paymentModel?.schedule?.day?[self.selectedScheduleTime] as? String
                    self.myLblSchedule.text = NSLocalizedString("Change", comment: "")
                }else{
                    self.myLblDeliveryTime2.text = NSLocalizedString("minutes", comment: "") + " " + (self.paymentModel?.deliveryTime ?? "") + " "
                    self.myLblSchedule.text = NSLocalizedString("Schedule your order", comment: "")
                }
            }else{
                self.myLblDeliveryTime1.text = NSLocalizedString("Approximately delivery time is", comment: "")
                if self.selectedScheduleTime != 1000 && self.selectedScheduleTime < self.paymentModel?.schedule?.day?.count ?? 0{
                    self.myLblDeliveryTime2.text = self.paymentModel?.schedule?.day?[self.selectedScheduleTime] as? String
                    self.myLblSchedule.text = NSLocalizedString("Change", comment: "")
                }else{
                    self.myLblDeliveryTime2.text = (self.paymentModel?.deliveryTime ?? "") + " " + NSLocalizedString("minutes", comment: "")
                    self.myLblSchedule.text = NSLocalizedString("Schedule your order", comment: "")
                }
            }
            
            if self.paymentModel?.scheduleStatus == "1"{
                self.myLblSchedule.isHidden = false
                self.myBtnSchedule.isHidden = false
            }else{
                self.myLblSchedule.isHidden = true
                self.myBtnSchedule.isHidden = true
            }
            self.myViewScheduleTime.frame.origin.y = self.myViewAddress.frame.origin.y + self.myViewAddress.frame.size.height + 8
            self.myViewScheduleTime.translatesAutoresizingMaskIntoConstraints = true
            self.myViewCouponContainer.frame.origin.y = self.myViewScheduleTime.frame.origin.y + self.myViewScheduleTime.frame.size.height + 8
            self.myViewCouponContainer.translatesAutoresizingMaskIntoConstraints = true
            self.myViewContactless.frame.origin.y = self.myViewCouponContainer.frame.origin.y + self.myViewCouponContainer.frame.size.height + 8
            self.myViewContactless.translatesAutoresizingMaskIntoConstraints = true
            self.myViewPaymentMethod.frame.origin.y = self.myViewContactless.frame.origin.y + self.myViewContactless.frame.size.height + 8
            self.myViewPaymentMethod.translatesAutoresizingMaskIntoConstraints = true
        }
        
        var yOFPayment : CGFloat = 35.0
        var isPaymentAvailable : Bool = false
        self.myViewCOD.isHidden = true
        self.myViewOnline.isHidden = true
        for obj in self.paymentModel?.payment ?? []{
            let code = obj.paymentCode
            if code == "cod"{
                self.myLblCOD.text = obj.paymentName
                self.myViewCOD.isHidden = false
                self.myViewCOD.frame.origin.y = yOFPayment
                yOFPayment = yOFPayment + self.myViewCOD.frame.size.height + 8
                isPaymentAvailable = true
            }else if code == "airtel"{
                self.myLblOnline.text = obj.paymentName
                self.myViewOnline.isHidden = false
                self.myViewOnline.frame.origin.y = yOFPayment
                yOFPayment = yOFPayment + self.myViewOnline.frame.size.height + 8
                isPaymentAvailable = true
            }
        }
        if selectedPaymentListId == "1"{
            self.view.endEditing(true)
            self.myTxtAirtelMobileNumber.text = ""
            self.myViewAirtelMobileNumber.isHidden = true
            if contactlessEnabled == false{
                self.myViewContactlessWarning.isHidden = true
                self.myBtnCheckout.isUserInteractionEnabled = true
                self.myBtnCheckout.alpha = 1
            }else{
                self.myViewContactlessWarning.isHidden = false
                self.myViewContactlessWarning.frame.origin.y = yOFPayment
                yOFPayment = yOFPayment + self.myViewContactlessWarning.frame.size.height + 8
                self.myBtnCheckout.isUserInteractionEnabled = false
                self.myBtnCheckout.alpha = 0.5
            }
        }else if selectedPaymentListId == "2"{
            self.myViewContactlessWarning.isHidden = true
            self.myBtnCheckout.isUserInteractionEnabled = true
            
            self.myTxtAirtelMobileNumber.becomeFirstResponder()
            self.myViewAirtelMobileNumber.isHidden = false
            self.myViewAirtelMobileNumber.frame.origin.y = yOFPayment
            yOFPayment = yOFPayment + self.myViewAirtelMobileNumber.frame.size.height + 8
            
            self.myBtnCheckout.alpha = 1
        }else{
            self.myBtnCheckout.alpha = 0.5
        }
        if isPaymentAvailable == true{
            self.myViewPaymentMethod.frame.size.height = yOFPayment
            self.myLblPaymentError.isHidden = true
        }else{
            self.myViewPaymentMethod.frame.size.height = 60
            self.myLblPaymentError.isHidden = false
        }
        self.myViewPaymentMethod.translatesAutoresizingMaskIntoConstraints = true
        self.myTblTotal.frame.origin.y = self.myViewPaymentMethod.frame.origin.y + self.myViewPaymentMethod.frame.size.height + 3
        self.myTblTotal.frame.size.height = self.myTblTotal.contentSize.height
        self.myTblTotal.translatesAutoresizingMaskIntoConstraints = true
        self.myViewContainer.frame.size.height = self.myTblTotal.frame.origin.y + self.myTblTotal.contentSize.height
        self.myViewContainer.frame.size.width = self.view.frame.size.width
        self.myViewScroll.contentSize = CGSize(width: self.view.frame.size.width, height: self.self.myViewContainer.frame.size.height)
        self.myViewContainer.translatesAutoresizingMaskIntoConstraints = true
        self.myViewContainer.isHidden = false
    }
    
    //MARK: Button action
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickContactless(_ sender: UIButton) {
        let img = UIImage(named: "ic_uncheck")
        if self.myBtnContactless.currentBackgroundImage == img{
            let img = UIImage(named: "ic_checkbox")
            self.myBtnContactless.setBackgroundImage(img, for: .normal)
            contactlessEnabled = true
            self.myBtnCod.isUserInteractionEnabled = false
            myViewCOD.alpha = 0.5
        }else{
            self.myBtnContactless.setBackgroundImage(img, for: .normal)
            contactlessEnabled = false
            self.myBtnCod.isUserInteractionEnabled = true
            myViewCOD.alpha = 1
        }
        self.autoScrollSize()
    }
    
    @IBAction func clickCod(_ sender: UIButton) {
        self.myImgRadioCod.image = UIImage(named: "ic_radio_check")
        self.myImgRadioOnline.image = UIImage(named: "ic_radio_uncheck")
        self.myImgRadioCod.image = self.myImgRadioCod.image!.withRenderingMode(.alwaysTemplate)
        self.myImgRadioCod.tintColor = ConfigTheme.themeColor
        self.myImgRadioOnline.image = self.myImgRadioOnline.image!.withRenderingMode(.alwaysTemplate)
        self.myImgRadioOnline.tintColor = ConfigTheme.themeColor
        self.selectedPaymentListId = "1"
        self.autoScrollSize()
    }
    
    @IBAction func clickOnline(_ sender: Any) {
        self.myImgRadioOnline.image = UIImage(named: "ic_radio_check")
        self.myImgRadioCod.image = UIImage(named: "ic_radio_uncheck")
        self.myImgRadioCod.image = self.myImgRadioCod.image!.withRenderingMode(.alwaysTemplate)
        self.myImgRadioCod.tintColor = ConfigTheme.themeColor
        self.myImgRadioOnline.image = self.myImgRadioOnline.image!.withRenderingMode(.alwaysTemplate)
        self.myImgRadioOnline.tintColor = ConfigTheme.themeColor
        self.selectedPaymentListId = "2"
        self.autoScrollSize()
    }
    
    @IBAction func clickAddCoupon(_ sender: UIButton) {
        if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
            if myLblCoupon.text == NSLocalizedString("Remove coupon", comment: ""){
                HELPER.showAlertControllerIn(aViewController: self, aStrMessage: NSLocalizedString("Do you want to remove the applied coupon", comment: ""), okButtonTitle: NSLocalizedString("Remove", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { okAction in
                    self.couponId = ""
                    self.myLblCoupon.text =  NSLocalizedString("Apply coupon", comment: "")
                    self.callGetCouponApi()
                    self.callGetCartItemsApi()
                } cancelActionBlock: { cancelAction in
                    self.dismiss(animated: true)
                }
            }else{
                callGetCouponApi()
            }
        }else{
            HELPER.showAlertControllerIn(aViewController: self, aStrMessage: NSLocalizedString("Coupons are valid for registered customers only. Please login or create an account to save on your order", comment: ""), okButtonTitle: NSLocalizedString("Login", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { okAction in
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: LoginVc.storyboardID) as! LoginVc
                self.navigationController?.pushViewController(aViewController, animated: true)
            } cancelActionBlock: { cancelAction in
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func clickApplyCoupon(_ sender: Any) {
        if self.myTxtCoupon.text?.isEmpty == true{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please enter coupon code", comment: ""))
        }else{
            callPostCouponCode(couponCode: self.myTxtCoupon.text!)
        }
    }
    
    @IBAction func clickCancelCoupon(_ sender: Any) {
        self.myViewCoupon.isHidden = true
    }
    
    @IBAction func clickAddAddress(_ sender: Any) {
        self.isOTPVerified = false
        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: AddressVc.storyboardID) as! AddressVc
        if let id = paymentModel?.address?.addressID, id != "" && guestStatus == "1"{
            aViewController.addressDict = paymentModel?.address
        }
        aViewController.vendorId = cartModel?.vendorID ?? ""
        aViewController.modalPresentationStyle = .fullScreen
        self.present(aViewController, animated: true, completion: nil)
    }
    
    @IBAction func clickPlaceOrder(_ sender: UIButton) {
        if cartModel?.orderType == "1"{
            let addressId = self.paymentModel?.address?.addressID
            if addressId != "" {
                if self.selectedPaymentListId != ""{
                    if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
                        self.callCheckDeliveryAvailability()
                    }else{
                        if isOTPVerified{
                            self.callCheckDeliveryAvailability()
                        }else{
                            let countryCode = self.paymentModel?.address?.countryCode ?? ""
                            let mobile = self.paymentModel?.address?.mobile ?? ""
                            self.myLblMobileVerify.text = "+" + countryCode + mobile
                            self.myViewCouponChild1.isHidden = true
                            self.myViewVerifyMobile.isHidden = false
                            self.myViewCoupon.isHidden = false
                        }
                    }
                }else{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please select payment method", comment: ""))
                }
            }else{
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please select delivery address", comment: ""))
            }
        }else{
            if self.selectedPaymentListId != ""{
                if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
                    HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
                    self.callConfirmOrderApi()
                }else{
                    if countryArray.count != 0{
                        self.myTxtGuestFname.text = ""
                        self.myTxtGuestLname.text = ""
                        self.myTxtGuestEmail.text = ""
                        self.myTxtGuestMobile.text = ""
                        self.myViewGuestPickup.isHidden = false
                    }else{
                        self.callGetCountryApi()
                    }
                }
            }else{
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please select payment method", comment: ""))
            }
        }
    }
    
    @IBAction func clickBackFromGuestPickup(_ sender: UIButton) {
        self.myViewGuestPickup.isHidden = true
    }
    
    @IBAction func clickCountryCode(_ sender: UIButton) {
        view.endEditing(true)
        if countryArray.count != 0 {
            self.myViewPickervw.isHidden = false
        }else {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Country code not available", comment: ""))
        }
    }
    
    @IBAction func clickPickerDone(_ sender: Any) {
        view.endEditing(true)
        let countryCode = self.countryArray[selectedCountryCodeIndex]["code"] as? String
        self.myLblGuestCountryCode.text! = countryCode!
        self.myViewPickervw.isHidden = true
    }
    
    @IBAction func clickPickerCancel(_ sender: Any) {
        view.endEditing(true)
        self.myViewPickervw.isHidden = true
    }
    
    @IBAction func clickGetOtpGuest(_ sender: UIButton) {
        if self.myTxtGuestFname.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your First Name", comment: ""))
        }else if self.myTxtGuestLname.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Last Name", comment: ""))
        }else if self.myTxtGuestEmail.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Email-Id", comment: ""))
        }else if !HELPER.isValidEmail(testStr: myTxtGuestEmail.text!) {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter a Valid Email-Id", comment: ""))
        }else if self.myTxtGuestMobile.text == ""{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Mobile Number", comment: ""))
        }else{
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            var str = self.myLblGuestCountryCode.text! + self.myTxtGuestMobile.text!
            str = str.replacingOccurrences(of: " ", with: "")
            str = "+" + str
            self.myLblMobileOtp.text = str
            PhoneAuthProvider.provider().verifyPhoneNumber(self.myLblMobileOtp.text ?? "", uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    HELPER.hideLoadingAnimation()
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error.localizedDescription)
                    return
                }
                self.myTxtOtp.text = ""
                self.myTxtOtp.becomeFirstResponder()
                self.currentVerificationId = verificationID!
                HELPER.hideLoadingAnimation()
                self.myBtnResend.isHidden = true
                self.timeLeft = 30
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: true)
                self.myViewOTP.isHidden = false
            }
        }
    }
    
    @IBAction func clickGetOtp(_ sender: UIButton) {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        var str = self.myLblMobileVerify.text
        str = str?.replacingOccurrences(of: " ", with: "")
        self.myLblMobileOtp.text = str
        PhoneAuthProvider.provider().verifyPhoneNumber(self.myLblMobileOtp.text ?? "", uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                HELPER.hideLoadingAnimation()
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error.localizedDescription)
                return
            }
            self.myTxtOtp.text = ""
            self.myTxtOtp.becomeFirstResponder()
            self.currentVerificationId = verificationID!
            HELPER.hideLoadingAnimation()
            self.myBtnResend.isHidden = true
            self.timeLeft = 30
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: true)
            self.myViewOTP.isHidden = false
        }
    }
    
    @IBAction func clickChangeMobile(_ sender: UIButton) {
        self.isOTPVerified = false
        self.myViewCoupon.isHidden = true
        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: AddressVc.storyboardID) as! AddressVc
        aViewController.vendorId = cartModel?.vendorID ?? ""
        if paymentModel?.address?.addressID != nil && guestStatus == "1"{
            aViewController.addressDict = paymentModel?.address
        }
        aViewController.modalPresentationStyle = .fullScreen
        self.present(aViewController, animated: true, completion: nil)
    }
    
    @IBAction func clickCancelChangeMobile(_ sender: UIButton) {
        self.myViewCoupon.isHidden = true
        self.myViewVerifyMobile.isHidden = true
    }
    
    @IBAction func clickOTPSubmit(_ sender: UIButton) {
        self.view.endEditing(true)
        if myTxtOtp.text?.count == 6{
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: currentVerificationId, verificationCode: self.myTxtOtp.text ?? "")
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    let authError = error as NSError
                    print(authError.description)
                    HELPER.showAlertControllerWithOkActionBlock(aViewController: self, aStrMessage: NSLocalizedString("Invalid OTP", comment: "")) { UIAlertAction in
                        self.myTxtOtp.becomeFirstResponder()
                    }
                    HELPER.hideLoadingAnimation()
                    return
                }else{
                    HELPER.hideLoadingAnimation()
                    if self.cartModel?.orderType == "1"{
                        self.callCheckDeliveryAvailability()
                    }else{
                        self.callConfirmOrderApi()
                    }
                }
            }
        }else{
            HELPER.showAlertControllerWithOkActionBlock(aViewController: self, aStrMessage: NSLocalizedString("Invalid OTP", comment: "")) { UIAlertAction in
                self.myTxtOtp.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func clickResend(_ sender: UIButton) {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        let countryCode = self.paymentModel?.address?.countryCode ?? ""
        let mobile = self.paymentModel?.address?.mobile ?? ""
        var str = countryCode + mobile
        str = str.replacingOccurrences(of: " ", with: "")
        str = "+" + str
        self.myLblMobileOtp.text = str
        PhoneAuthProvider.provider().verifyPhoneNumber(str, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                HELPER.hideLoadingAnimation()
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error.localizedDescription)
                return
            }
            HELPER.hideLoadingAnimation()
            self.currentVerificationId = verificationID!
            self.myBtnResend.isHidden = true
            self.timeLeft = 30
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func clickBackOTP(_ sender: UIButton) {
        view.endEditing(true)
        self.myViewOTP.isHidden = true
    }
    
    @IBAction func clickSchedule(_ sender: UIButton) {
        self.myTblSchedule.dataSource = self
        self.myTblSchedule.delegate = self
        self.myTblSchedule.reloadData()
        self.myViewSchedule.isHidden = false
    }
    
    @IBAction func clickBackSchedule(_ sender: UIButton) {
        self.myViewSchedule.isHidden = true
    }
    
    @objc func startTimer()
    {
        timeLeft -= 1
        self.myLblTimer.text = "\(NSLocalizedString("I didn't receive a code", comment: ""))(0.\(timeLeft))"
        self.myLblTimer.isHidden = false
        if timeLeft <= 0 {
            timer?.invalidate()
            timer = nil
            self.myLblTimer.isHidden = true
            self.myBtnResend.isHidden = false
        }
    }
}

extension CheckoutVc : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let name = self.countryArray[row]["name"] as? String
        return name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCountryCodeIndex = row
    }
}

//MARK: TableView Methods
extension CheckoutVc: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == myTblSchedule{
            return nil
        }else{
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "sectionHeaderCell") as! CheckoutTblCell
            headerCell.myLblHeader.text = NSLocalizedString("Payment summary", comment: "")
            return headerCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == myTblSchedule{
            return 0
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == myTblSchedule{
            return self.paymentModel?.schedule?.day?.count ?? 0
        }else{
            return self.cartModel?.totals?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == myTblSchedule{
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            if(cell == nil)
            {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
            }
            cell!.textLabel?.text = self.paymentModel?.schedule?.day?[indexPath.row] as? String
            return cell!
        }else{
            let cell:CheckoutTblCell = self.myTblTotal.dequeueReusableCell(withIdentifier: "totalCell") as! CheckoutTblCell
            if self.cartModel?.totals?[indexPath.row].titleKey == "total"{
                cell.myLblTotalAmtTitle.font = UIFont(name: "Poppins-Medium", size: 15)
                cell.myLblTotalAmtValue.font = UIFont(name: "Poppins-Medium", size: 15)
            }else{
                cell.myLblTotalAmtTitle.font = UIFont(name: "Poppins-Regular", size: 13)
                cell.myLblTotalAmtValue.font = UIFont(name: "Poppins-Regular", size: 13)
            }
            if self.cartModel?.totals?[indexPath.row].titleKey == "coupon" || self.cartModel?.totals?[indexPath.row].titleKey == "offer"{
                cell.myLblTotalAmtTitle.textColor = ConfigTheme.themeColor
                cell.myLblTotalAmtValue.textColor = ConfigTheme.themeColor
            }else{
                cell.myLblTotalAmtTitle.textColor = .black
                cell.myLblTotalAmtValue.textColor = .black
            }
            cell.myLblTotalAmtValue.textAlignment = isRTLenabled == true ? .left : .right
            cell.myLblTotalAmtTitle.text = self.cartModel?.totals?[indexPath.row].title
            cell.myLblTotalAmtValue.text = self.cartModel?.totals?[indexPath.row].text
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == myTblSchedule{
            return 45
        }else{
            if #available(iOS 15.0, *) {
                tableView.sectionHeaderTopPadding = 0
            }
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == myTblSchedule{
            selectedScheduleTime = indexPath.row
            self.myViewSchedule.isHidden = true
            self.autoScrollSize()
        }
    }
}

extension CheckoutVc : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.couponList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "couponCell", for: indexPath) as! CouponCollCell
        cell.lblCouponTitle.text = self.couponList[indexPath.row]["name"] as? String
        cell.lblOfferCoupon.text = self.couponList[indexPath.row]["code"] as? String
        cell.contentView.layer.borderColor = ConfigTheme.themeColor.cgColor
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.cornerRadius = 10
        cell.viewCouponBg.addDashBorder()
        cell.btnApply.addTarget(self, action: #selector(clickApplyCouponFromList(_:)), for: .touchUpInside)
        cell.btnApply.tag = indexPath.row
        return cell
    }
    
    @objc func clickApplyCouponFromList(_ sender: UIButton){
        guard let couponCode = self.couponList[sender.tag]["code"] as? String else { return }
        callPostCouponCode(couponCode: couponCode)
    }
}

extension CheckoutVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 270, height: 117)
    }
}
