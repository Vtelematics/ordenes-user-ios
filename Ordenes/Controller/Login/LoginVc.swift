import UIKit
import WebKit
import FirebaseAuth
import OneSignal

protocol loginIntimation {
    func loginSuccess()
    func loginFailure()
}

class LoginVc: UIViewController {
    
    @IBOutlet weak var myViewLogin: UIView!
    @IBOutlet weak var myViewRegister: UIView!
    @IBOutlet weak var myViewMobileNumber: UIView!
    @IBOutlet weak var myViewOTP: UIView!
    @IBOutlet weak var myViewDetails: UIView!
    @IBOutlet weak var myViewResetPassword: UIView!
    @IBOutlet weak var myViewPickerContainer: UIView!
    @IBOutlet weak var myPickerView: UIPickerView!
    @IBOutlet weak var myViewTerms: UIView!
    @IBOutlet weak var myWebViewTerms: WKWebView!
    
    //Login
    @IBOutlet weak var myTxtMobile: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtPassword: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtMobileCode: UITextField!
    @IBOutlet weak var myImgVwPwd: UIImageView!
    @IBOutlet weak var myLblMobileTitle: UILabel!
    @IBOutlet weak var myLblOTPTitle: UILabel!
    @IBOutlet weak var myLblSeconds: UILabel!
    @IBOutlet weak var myBtnResend: UIButton!
    
    //Register
    @IBOutlet weak var myTxtOTP: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtRegMobile: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtRegMobileCode: UITextField!
    @IBOutlet weak var myTxtRegFirstName: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtRegLastName: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtRegEmail: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtRegPassword: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtRegConPassword: kTextFiledPlaceHolder!
    @IBOutlet weak var myImgRegVwPwd: UIImageView!
    @IBOutlet weak var myImgRegConVwPwd: UIImageView!
    @IBOutlet weak var myImgTerms: UIImageView!
    @IBOutlet weak var myLblTerms: UILabel!
    @IBOutlet weak var myLblMobileNo: UILabel!
    
    //Reset password
    @IBOutlet weak var myTxtResetPassword: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtResetConPassword: kTextFiledPlaceHolder!
    @IBOutlet weak var myImgResetVwPwd: UIImageView!
    @IBOutlet weak var myImgResetConVwPwd: UIImageView!
    
    var isSecure = true
    var isRegSecure = true
    var isRegConSecure = true
    var isResetSecure = true
    var isResetConSecure = true
    var purpose = "login"
    var selectedIndex : Int = 0
    var isAccepted = Bool()
    var delegate:loginIntimation?
    var countryArray : [[String: Any]] = []
    var timer:Timer?
    var timeLeft = 30
    var currentVerificationId = ""
    var encriptDic:[String:Any]?
    var OTPType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.removeObject(forKey: UD_USER_DETAILS)
        UserDefaults.standard.removeObject(forKey: UD_SECRET_KEY)
        self.myTxtMobile.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtOTP.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtRegMobile.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtRegFirstName.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtRegLastName.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtRegEmail.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtRegPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtRegConPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtResetPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtResetConPassword.textAlignment = isRTLenabled == true ? .right : .left
    }
    
    override func viewWillAppear(_ animated: Bool){
        self.myTxtOTP.addTarget(self, action: #selector(self.maxLength(sender:)), for: .editingChanged)
        getCountryApi()
    }
    
    override func viewWillDisappear(_ animated: Bool){
        if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
            guestStatus = "0"
        }else{
            guestStatus = "1"
        }
    }
    
    //MARK: Api Call
    func getCountryApi() {
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
    
    func loginUserApi() {
        var pushId:String = ""
        if let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId{
            pushId = userId
        }
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_TELEPHONE_CODE] = self.myTxtMobileCode.text
        aDictParameters[K_PARAMS_TELEPHONE] = self.myTxtMobile.text
        aDictParameters[K_PARAMS_PASSWORD] = self.myTxtPassword.text
        aDictParameters[K_PARAMS_DEVICE_TYPE] = "2"
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_PUSH_ID] = pushId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_LOGIN, isAuthorize: false, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
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
                    if let userdetail = response["customer_info"] as? [String:Any] {
                        let secretKey = userdetail["secret_key"] as! String
                        do {
                            let data = try NSKeyedArchiver.archivedData(withRootObject: userdetail, requiringSecureCoding: false)
                            UserDefaults.standard.set(data, forKey: UD_USER_DETAILS)
                        } catch {
                            print("Couldn't write file")
                        }
                        UserDefaults.standard.set(secretKey, forKey: UD_SECRET_KEY)
                        self.navigationController?.popViewController(animated: true, completion: {
                            self.delegate?.loginSuccess()
                        })
                        //self.navigationController?.popViewController(animated: true)
//                        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
//                        self.navigationController?.isNavigationBarHidden = true
//                        self.navigationController?.pushViewController(aViewController, animated: true)
                    }
                }else{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
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
    
    func checkUserExistApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_TELEPHONE_CODE] = self.myTxtRegMobileCode.text
        aDictParameters[K_PARAMS_TELEPHONE] = self.myTxtRegMobile.text
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_CHECK_USER, isAuthorize: false, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
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
                
                if let encript = response["encript"] as? [String:Any] {
                    self.encriptDic = encript
                    print(self.encriptDic)
                    self.OTPType = response["otp_type"] as! String
                    print(self.OTPType)
                }
                
                if success["status"] as! String == "200" {
                    if self.purpose == "signup" {
                        if self.OTPType == "firebase" {
                            var str = self.myTxtRegMobileCode.text! + self.myTxtRegMobile.text!
                            str = str.replacingOccurrences(of: " ", with: "")
                            str = "+" + str
                            print(str)
                            self.myLblMobileNo.text = str
                            PhoneAuthProvider.provider().verifyPhoneNumber(str, uiDelegate: nil) { (verificationID, error) in
                                if let error = error {
                                    print(error)
                                    HELPER.hideLoadingAnimation()
                                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error.localizedDescription)
                                    return
                                }
                                self.currentVerificationId = verificationID!
                                self.myLblOTPTitle.text = NSLocalizedString("Signup", comment: "")
                                self.myTxtOTP.becomeFirstResponder()
                                HELPER.hideLoadingAnimation()
                                self.myViewRegister.isHidden = false
                                self.timeLeft = 30
                                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: true)
                            }
                        }else {
                            let mobileCode = self.myTxtRegMobileCode.text ?? ""
                            let mobileNumber = self.myTxtRegMobile.text ?? ""
                            self.sendGatewayOtp(mobileCode: mobileCode, mobileNumber: mobileNumber)
                        }
                    }else {
                        HELPER.hideLoadingAnimation()
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
                    }
                }else{
                    if self.purpose == "forgot" {
                        if self.OTPType == "firebase" {
                            var str = self.myTxtRegMobileCode.text! + self.myTxtRegMobile.text!
                            str = str.replacingOccurrences(of: " ", with: "")
                            str = "+" + str
                            self.myLblMobileNo.text = str
                            
                            PhoneAuthProvider.provider().verifyPhoneNumber(str, uiDelegate: nil) { (verificationID, error) in
                                if let error = error {
                                    HELPER.hideLoadingAnimation()
                                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error.localizedDescription)
                                    return
                                }
                                self.currentVerificationId = verificationID!
                                self.myLblOTPTitle.text = NSLocalizedString("Forgot password", comment: "")
                                self.myTxtOTP.becomeFirstResponder()
                                HELPER.hideLoadingAnimation()
                                self.myViewRegister.isHidden = false
                                self.timeLeft = 30
                                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: true)
                            }
                        }else {
                            let mobileCode = self.myTxtRegMobileCode.text ?? ""
                            let mobileNumber = self.myTxtRegMobile.text ?? ""
                            self.sendGatewayOtp(mobileCode: mobileCode, mobileNumber: mobileNumber)
                        }
                    }else {
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
    
    func registerUserApi() {
        var pushId = ""
        if let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId{
            pushId = userId
        }
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_FNAME] = self.myTxtRegFirstName.text
        aDictParameters[K_PARAMS_LNAME] = self.myTxtRegLastName.text
        aDictParameters[K_PARAMS_EMAIL] = self.myTxtRegEmail.text
        aDictParameters[K_PARAMS_TELEPHONE_CODE] = self.myTxtRegMobileCode.text
        aDictParameters[K_PARAMS_TELEPHONE] = self.myTxtRegMobile.text
        aDictParameters[K_PARAMS_PASSWORD] = self.myTxtRegConPassword.text
        aDictParameters[K_PARAMS_DEVICE_TYPE] = "2"
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_PUSH_ID] = pushId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_REGISTER, isAuthorize: false, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
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
                    if let userdetail = response["customer_info"] as? [String:Any] {
                        let secretKey = userdetail["secret_key"] as! String
                        do {
                            let data = try NSKeyedArchiver.archivedData(withRootObject: userdetail, requiringSecureCoding: false)
                            UserDefaults.standard.set(data, forKey: UD_USER_DETAILS)
                        } catch {
                            print("Couldn't write file")
                        }
                        UserDefaults.standard.set(secretKey, forKey: UD_SECRET_KEY)
                        self.navigationController?.popViewController(animated: true)
//                        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
//                        self.navigationController?.isNavigationBarHidden = true
//                        self.navigationController?.pushViewController(aViewController, animated: true)
                    }
                }else{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
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
    
    func forgotPasswordApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_TELEPHONE_CODE] = self.myTxtRegMobileCode.text
        aDictParameters[K_PARAMS_TELEPHONE] = self.myTxtRegMobile.text
        aDictParameters[K_PARAMS_PASSWORD] = self.myTxtResetConPassword.text
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_FORGOT_PASSWORD, isAuthorize: false, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
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
                    HELPER.showAlertControllerWithOkActionBlock(aViewController: self, aStrMessage: success["message"] as! String, okActionBlock: { (okAction) in
                        self.myTxtRegMobile.text = ""
                        self.myTxtOTP.text = ""
                        self.myTxtResetPassword.text = ""
                        self.myTxtResetConPassword.text = ""
                        self.myTxtMobile.text = ""
                        self.myTxtPassword.text = ""
                        self.myViewMobileNumber.isHidden = true
                        self.myViewRegister.isHidden = true
                        self.myViewResetPassword.isHidden = true
                    })
                }else{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
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
    
    func commonFunctionApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_COMMON_FUNCTION, isAuthorize: false, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                print(response)
                var success:[String:Any]!
                if let successval = response["success"] as? [String:Any] {
                    success = successval
                }else if let error = response["error"] as? [String:Any] {
                    success = error
                }else {
                    var defaultError = [String:Any]()
                    defaultError["message"] = NSLocalizedString("Something went wrong. Please try again", comment: "")
                    defaultError["status"] = "888"
                    success = defaultError
                }
                if success["status"] as! String == "200" {
                    self.OTPType = response["otp_type"] as! String
                    print(self.OTPType)
                    
                    if let encript = response["encript"] as? [String:Any] {
                        self.encriptDic = encript
                        let mobileCode = self.myTxtRegMobileCode.text ?? ""
                        let mobileNumber = self.myTxtRegMobile.text ?? ""
                        self.sendGatewayOtp(mobileCode: mobileCode, mobileNumber: mobileNumber)
                    }
                }else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
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
    
    func sendGatewayOtp(mobileCode: String, mobileNumber: String) {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_ENCRIPT_CODE] = self.encriptDic?["encript_code"] as? String
        aDictParameters[K_PARAMS_NOW] = self.encriptDic?["now"] as? String
        aDictParameters[K_PARAMS_TELEPHONE_CODE] = mobileCode
        aDictParameters[K_PARAMS_TELEPHONE] = mobileNumber
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        print(aDictParameters)
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_SEND_GATEWAY_OTP, isAuthorize: false, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                print(response)
                var success:[String:Any]!
                if let successval = response["success"] as? [String:Any] {
                    success = successval
                }else if let error = response["error"] as? [String:Any] {
                    success = error
                }else {
                    var defaultError = [String:Any]()
                    defaultError["message"] = NSLocalizedString("Something went wrong. Please try again", comment: "")
                    defaultError["status"] = "888"
                    success = defaultError
                }
                if success["status"] as! String == "200" {
                    if self.purpose == "signup" {
                        self.myLblOTPTitle.text = NSLocalizedString("Signup", comment: "")
                    }else if self.purpose == "forgot" {
                        self.myLblOTPTitle.text = NSLocalizedString("Forgot password", comment: "")
                    }
                    
                    var str = mobileCode + mobileNumber
                    str = str.replacingOccurrences(of: " ", with: "")
                    str = "+" + str
                    self.myLblMobileNo.text = str
                    
                    self.myTxtOTP.becomeFirstResponder()
                    self.myViewRegister.isHidden = false
                    self.myBtnResend.isHidden = true
                    self.timeLeft = 30
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: true)
                    
                }else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
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
    
    func verifyGatewayOtp(mobileCode: String, mobileNumber: String, OTP: String) {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_TELEPHONE_CODE] = mobileCode
        aDictParameters[K_PARAMS_TELEPHONE] = mobileNumber
        aDictParameters[K_PARAMS_OTP] = OTP
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        print(aDictParameters)
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_VERIFY_GATEWAY_OTP, isAuthorize: false, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                print(response)
                var success:[String:Any]!
                if let successval = response["success"] as? [String:Any] {
                    success = successval
                }else if let error = response["error"] as? [String:Any] {
                    success = error
                }else {
                    var defaultError = [String:Any]()
                    defaultError["message"] = NSLocalizedString("Something went wrong. Please try again", comment: "")
                    defaultError["status"] = "888"
                    success = defaultError
                }
                if success["status"] as! String == "200" {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.myLblSeconds.isHidden = true
                    self.myBtnResend.isHidden = false
                    if  self.purpose == "signup" {
                        let normalText = NSLocalizedString("I have read and agree to the ", comment: "")
                        let attributedStringColor = [NSAttributedString.Key.foregroundColor : ConfigTheme.themeColor];
                        let attributedString = NSAttributedString(string: NSLocalizedString("Terms and conditions", comment: ""), attributes: attributedStringColor as [NSAttributedString.Key : Any])
                        let normalString = NSMutableAttributedString(string:normalText)
                        normalString.append(attributedString)
                        self.myLblTerms.attributedText = normalString
                        self.myViewDetails.isHidden = false
                        self.myTxtRegFirstName.becomeFirstResponder()
                    }else {
                        self.myViewResetPassword.isHidden = false
                        self.myTxtResetPassword.becomeFirstResponder()
                    }
                }else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
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
    
    //MARK: Functions
    @objc func startTimer() {
        timeLeft -= 1
        myLblSeconds.text = "\(NSLocalizedString("I didn't receive a code", comment: ""))(0.\(timeLeft))"
        self.myLblSeconds.isHidden = false
        if timeLeft <= 0 {
            timer?.invalidate()
            timer = nil
            self.myLblSeconds.isHidden = true
            self.myBtnResend.isHidden = false
        }
    }
    
    @objc func maxLength(sender: UITextField) {
        let MAX_LENGHT = 6
        if let text = sender.text, text.count >= MAX_LENGHT {
            sender.text = String(text.dropLast(text.count - MAX_LENGHT))
            return
        }
    }
    
    func setCode() {
        if  purpose == "login" {
            let countryCode = self.countryArray[selectedIndex]["code"] as? String
            self.myTxtMobileCode.text! = countryCode!
        }else {
            let countryCode = self.countryArray[selectedIndex]["code"] as? String
            self.myTxtRegMobileCode.text! = countryCode!
        }
        
        self.myViewPickerContainer.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        HELPER.hideLoadingAnimation()
    }
    
    //MARK: Button action
    @IBAction func clickLogin(_ sender: UIButton) {
        
        if self.myTxtMobile.text == "" {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Mobile Number", comment: ""))
        }else {
            if self.myTxtPassword.text == "" {
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Password", comment: ""))
            }else {
                loginUserApi()
            }
        }
    }
    
    @IBAction func clickCreateAccount(_ sender: UIButton) {
        purpose = "signup"
        self.myLblMobileTitle.text = NSLocalizedString("Signup", comment: "")
        self.myViewMobileNumber.isHidden = false
        self.myTxtRegMobile.becomeFirstResponder()
    }
    
    @IBAction func clickFgtPassword(_ sender: UIButton) {
        purpose = "forgot"
        self.myLblMobileTitle.text = NSLocalizedString("Forgot password", comment: "")
        self.myViewMobileNumber.isHidden = false
        self.myTxtRegMobile.becomeFirstResponder()
    }
    
    @IBAction func clickRegister(_ sender: UIButton) {
        if myTxtRegFirstName.text == "" {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your First Name", comment: ""))
        }else {
            if myTxtRegLastName.text == "" {
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Last Name", comment: ""))
            }else {
                if myTxtRegEmail.text == "" {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Email-Id", comment: ""))
                }else {
                    if !HELPER.isValidEmail(testStr: myTxtRegEmail.text!) {
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter a Valid Email-Id", comment: ""))
                    }else {
                        if myTxtRegPassword.text == "" {
                            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Password", comment: ""))
                        }else {
                            if myTxtRegConPassword.text == ""  {
                                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Confirm Password", comment: ""))
                            }else {
                                if myTxtRegConPassword.text != myTxtRegPassword.text {
                                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Passwords Mismatching", comment: ""))
                                }else {
                                    if isAccepted != true {
                                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please accept to our terms and conditions", comment: ""))
                                    }else {
                                        registerUserApi()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func clickMobileSubmit(_ sender: UIButton) {
        if self.myTxtRegMobile.text == "" {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Mobile Number", comment: ""))
        }else {
            checkUserExistApi()
        }
    }
    
    @IBAction func clickOTPSubmit(_ sender: UIButton) {
        if self.myTxtOTP.hasText{
            if self.OTPType == "firebase" {
                HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: currentVerificationId, verificationCode: self.myTxtOTP.text ?? "")
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        let authError = error as NSError
                        print(authError.description.localiz())
                        
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Invalid OTP", comment: ""))
                        HELPER.hideLoadingAnimation()
                        return
                    }else {
                        HELPER.hideLoadingAnimation()
                        self.timer?.invalidate()
                        self.timer = nil
                        self.myLblSeconds.isHidden = true
                        self.myBtnResend.isHidden = false
                        if  self.purpose == "signup" {
                            let normalText = NSLocalizedString("I have read and agree to the ", comment: "")
                            let attributedStringColor = [NSAttributedString.Key.foregroundColor : ConfigTheme.themeColor];
                            let attributedString = NSAttributedString(string: NSLocalizedString("Terms and conditions", comment: ""), attributes: attributedStringColor as [NSAttributedString.Key : Any])
                            let normalString = NSMutableAttributedString(string:normalText)
                            normalString.append(attributedString)
                            self.myLblTerms.attributedText = normalString
                            self.myViewDetails.isHidden = false
                            self.myTxtRegFirstName.becomeFirstResponder()
                        }else {
                            self.myViewResetPassword.isHidden = false
                            self.myTxtResetPassword.becomeFirstResponder()
                        }
                    }
                }
            }else {
                let mobileCode = self.myTxtRegMobileCode.text ?? ""
                let mobileNumber = self.myTxtRegMobile.text ?? ""
                let OTPCode = self.myTxtOTP.text ?? ""
                self.verifyGatewayOtp(mobileCode: mobileCode, mobileNumber: mobileNumber, OTP: OTPCode)
            }
        }else{
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your OTP", comment: ""))
        }
    }
    
    @IBAction func clickResetPassword(_ sender: UIButton) {
        if self.myTxtResetPassword.text == "" {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your New Password", comment: ""))
        }else {
            if self.myTxtResetConPassword.text == "" {
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Confirm Password", comment: ""))
            }else {
                if myTxtResetConPassword.text != myTxtResetPassword.text {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Passwords Mismatching", comment: ""))
                }else {
                    forgotPasswordApi()
                }
            }
        }
    }
    
    @IBAction func clickViewPassword(_ sender: UIButton) {
        if isSecure == true {
            isSecure = false
            self.myTxtPassword.isSecureTextEntry = false
            myImgVwPwd.image = UIImage (named: "ic_visibility_off.png")
        }else {
            isSecure = true
            self.myTxtPassword.isSecureTextEntry = true
            myImgVwPwd.image = UIImage (named: "ic_visibility.png")
        }
        self.myImgVwPwd.image = self.myImgVwPwd.image!.withRenderingMode(.alwaysTemplate)
        self.myImgVwPwd.tintColor = UIColor.darkGray
    }
    
    @IBAction func clickRegViewPassword(_ sender: UIButton) {
        if isRegSecure == true {
            isRegSecure = false
            self.myTxtRegPassword.isSecureTextEntry = false
            myImgRegVwPwd.image = UIImage (named: "ic_visibility_off.png")
        }else {
            isRegSecure = true
            self.myTxtRegPassword.isSecureTextEntry = true
            myImgRegVwPwd.image = UIImage (named: "ic_visibility.png")
        }
        self.myImgRegVwPwd.image = self.myImgRegVwPwd.image!.withRenderingMode(.alwaysTemplate)
        self.myImgRegVwPwd.tintColor = UIColor.darkGray
    }
    
    @IBAction func clickRegConViewPassword(_ sender: UIButton) {
        if isRegConSecure == true {
            isRegConSecure = false
            self.myTxtRegConPassword.isSecureTextEntry = false
            myImgRegConVwPwd.image = UIImage (named: "ic_visibility_off.png")
        }else {
            isRegConSecure = true
            self.myTxtRegConPassword.isSecureTextEntry = true
            myImgRegConVwPwd.image = UIImage (named: "ic_visibility.png")
        }
        self.myImgRegConVwPwd.image = self.myImgRegConVwPwd.image!.withRenderingMode(.alwaysTemplate)
        self.myImgRegConVwPwd.tintColor = UIColor.darkGray
    }
    
    @IBAction func clickResetViewPassword(_ sender: UIButton) {
        if isResetSecure == true {
            isResetSecure = false
            self.myTxtResetPassword.isSecureTextEntry = false
            myImgResetVwPwd.image = UIImage (named: "ic_visibility_off.png")
        }else {
            isResetSecure = true
            self.myTxtResetPassword.isSecureTextEntry = true
            myImgResetVwPwd.image = UIImage (named: "ic_visibility.png")
        }
        self.myImgResetVwPwd.image = self.myImgResetVwPwd.image!.withRenderingMode(.alwaysTemplate)
        self.myImgResetVwPwd.tintColor = UIColor.darkGray
    }
    
    @IBAction func clickResetConViewPassword(_ sender: UIButton) {
        if isResetConSecure == true {
            isResetConSecure = false
            self.myTxtResetConPassword.isSecureTextEntry = false
            myImgResetConVwPwd.image = UIImage (named: "ic_visibility_off.png")
        }else {
            isResetConSecure = true
            self.myTxtResetConPassword.isSecureTextEntry = true
            myImgResetConVwPwd.image = UIImage (named: "ic_visibility.png")
        }
        self.myImgResetConVwPwd.image = self.myImgResetConVwPwd.image!.withRenderingMode(.alwaysTemplate)
        self.myImgResetConVwPwd.tintColor = UIColor.darkGray
    }
    
    @IBAction func clickCountryCode(_ sender: Any) {
        self.view.endEditing(true)
        if countryArray.count != 0 {
            self.myViewPickerContainer.isHidden = false
        }else {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Country code not available", comment: ""))
        }
    }
    
    @IBAction func clickPickerDone(_ sender: Any) {
        self.setCode()
    }
    
    @IBAction func clickPickerCancel(_ sender: Any) {
        self.myViewPickerContainer.isHidden = true
    }
    
    @IBAction func clickResend(_ sender: UIButton) {
        if self.OTPType == "firebase" {
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        var str = self.myTxtRegMobileCode.text! + self.myTxtRegMobile.text!
        str = str.replacingOccurrences(of: " ", with: "")
        str = "+" + str
        self.myLblMobileNo.text = str

            PhoneAuthProvider.provider().verifyPhoneNumber(str, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    HELPER.hideLoadingAnimation()
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error.localizedDescription)
                    return
                }
                self.currentVerificationId = verificationID!
                HELPER.hideLoadingAnimation()
                self.myBtnResend.isHidden = true
                self.timeLeft = 30
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: true)
            }
        }else {
            /*let mobileCode = self.myTxtRegMobileCode.text ?? ""
            let mobileNumber = self.myTxtRegMobile.text ?? ""
            self.sendGatewayOtp(mobileCode: mobileCode, mobileNumber: mobileNumber)*/
            self.commonFunctionApi()
        }
    }
    
    @IBAction func clickCheckTerms(_ sender: Any) {
        if isAccepted == true {
            isAccepted = false
            self.myImgTerms.image = UIImage (named: "ic_uncheck.png")
        }else {
            isAccepted = true
            self.myImgTerms.image = UIImage (named: "ic_checkbox.png")
        }
    }
    
    @IBAction func clickTerms(_ sender: Any) {
        view.endEditing(true)
        self.myViewTerms.isHidden = false
        let urlToLoad = "https://www.ordenesdelivery.com/customer/terms-conditions"
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        let url = URL(string: urlToLoad)!
        self.myWebViewTerms.load(URLRequest(url: url))
        self.myWebViewTerms.allowsBackForwardNavigationGestures = true
    }
    
    //MARK: Button Back action
    @IBAction func clickLoginBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickOTPBack(_ sender: UIButton){
        view.endEditing(true)
        self.myTxtOTP.text = ""
        self.myViewRegister.isHidden = true
    }
    
    @IBAction func clickDetailsBack(_ sender: UIButton) {
        view.endEditing(true)
        self.myTxtRegFirstName.text = ""
        self.myTxtRegLastName.text = ""
        self.myTxtRegEmail.text = ""
        self.myTxtRegPassword.text = ""
        self.myTxtRegConPassword.text = ""
        self.myViewDetails.isHidden = true
    }
    
    @IBAction func clickMobileBack(_ sender: UIButton) {
        view.endEditing(true)
        purpose = "login"
        self.myTxtRegMobile.text = ""
        self.myViewMobileNumber.isHidden = true
    }
    
    @IBAction func clickResetBack(_ sender: UIButton) {
        view.endEditing(true)
        self.myTxtResetPassword.text = ""
        self.myTxtResetConPassword.text = ""
        self.myViewResetPassword.isHidden = true
    }
    
    @IBAction func clickTermsBack(_ sender: UIButton) {
        self.myViewTerms.isHidden = true
    }
}

extension LoginVc : UIPickerViewDelegate, UIPickerViewDataSource {
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
        selectedIndex = row
    }
}

extension LoginVc : WKNavigationDelegate {
    override func loadView() {
        super.loadView()
        myWebViewTerms.navigationDelegate = self
    }
}
