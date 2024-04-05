
import UIKit
import WebKit

class CommonVc: UIViewController {
    
    @IBOutlet weak var myWebView: WKWebView!
    @IBOutlet weak var myLblNavTitle: UILabel!
    @IBOutlet weak var myViewContactForm: UIView!
    @IBOutlet weak var myViewChangePassword: UIView!
    @IBOutlet weak var myViewDeleteAccount: UIView!
    @IBOutlet weak var myTableDeleteAccount: UITableView!
    @IBOutlet weak var myTxtViewDeleteReason: UITextView!
    
    //contact us
    @IBOutlet weak var myTxtContactName: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtContactEmail: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtContactMobile: kTextFiledPlaceHolder!
    @IBOutlet weak var myLblComment: UILabel!
    @IBOutlet weak var myTxtComment: UITextView!
    
    //change password
    @IBOutlet weak var myTxtOldPassword: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtNewPassword: kTextFiledPlaceHolder!
    @IBOutlet weak var myTxtConfirmPassword: kTextFiledPlaceHolder!
    @IBOutlet weak var myImgVwOldPwd: UIImageView!
    @IBOutlet weak var myImgVwNewPwd: UIImageView!
    @IBOutlet weak var myImgVwConfirmPwd: UIImageView!
    
    var webViewDic : [String: Any] = [:]
    var webViewId = ""
    var viewType = ""
    var isOldSecure = true
    var isNewSecure = true
    var isConfirmSecure = true
    var selectedReasonIndex = 0
    var reasonStr = ""
    var DeletionReasonArr = [NSLocalizedString("Something was broken", comment: ""), NSLocalizedString("I'm not getting any invites", comment: ""), NSLocalizedString("I have a privacy concern", comment: ""), NSLocalizedString("Other", comment: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        self.myTxtContactName.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtContactEmail.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtContactMobile.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtComment.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtConfirmPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtNewPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtOldPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtConfirmPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.myTableDeleteAccount.register(UINib(nibName: "DeleteAccountTblCell", bundle: nil), forCellReuseIdentifier: "reasonCell")
        if webViewId != "" {
            getWebViewApi()
        }else {
            if viewType == "Contact" {
                self.myLblNavTitle.text = NSLocalizedString("Contact Form", comment: "")
                self.myViewContactForm.isHidden = false
            }else if viewType == "ChangePassword" {
                self.myLblNavTitle.text = NSLocalizedString("Change Password", comment: "")
                self.myViewChangePassword.isHidden = false
            }else {
                self.myLblNavTitle.text = NSLocalizedString("Delete Account", comment: "")
                self.myViewDeleteAccount.isHidden = false
                self.myTxtViewDeleteReason.layer.borderWidth = 1
                self.myTxtViewDeleteReason.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        HELPER.hideLoadingAnimation()
    }
    
    //MARK: Button action
    @IBAction func clickContactSubmit(_ sender: UIButton) {
        if myTxtContactName.text == "" {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Name", comment: ""))
        }else {
            if myTxtContactEmail.text == "" {
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Email-Id", comment: ""))
            }else{
                if !HELPER.isValidEmail(testStr: myTxtContactEmail.text!){
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter a Valid Email-Id", comment: ""))
                }else{
                    if myTxtContactMobile.text == ""{
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Mobile Number", comment: ""))
                    }else{
                        if myTxtComment.text == ""{
                            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your message", comment: ""))
                        }else {
                            contactUsApi()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func clickPasswordSubmit(_ sender: UIButton) {
        if myTxtOldPassword.text == "" {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Old Password", comment: ""))
        }else {
            if myTxtNewPassword.text == "" {
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your New Password", comment: ""))
            }else{
                if myTxtConfirmPassword.text == ""  {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Confirm Password", comment: ""))
                }else {
                    if myTxtConfirmPassword.text != myTxtNewPassword.text {
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Passwords Mismatching", comment: ""))
                    }else {
                        changePasswordApi()
                    }
                }
            }
        }
    }
    
    @IBAction func clickViewOldPassword(_ sender: UIButton) {
        if isOldSecure == true {
            isOldSecure = false
            self.myTxtOldPassword.isSecureTextEntry = false
            myImgVwOldPwd.image = UIImage (named: "ic_visibility_off.png")
        }else {
            isOldSecure = true
            self.myTxtOldPassword.isSecureTextEntry = true
            myImgVwOldPwd.image = UIImage (named: "ic_visibility.png")
        }
        self.myImgVwOldPwd.image = self.myImgVwOldPwd.image!.withRenderingMode(.alwaysTemplate)
        self.myImgVwOldPwd.tintColor = UIColor.darkGray
    }
    
    @IBAction func clickViewNewPassword(_ sender: UIButton) {
        if isNewSecure == true {
            isNewSecure = false
            self.myTxtNewPassword.isSecureTextEntry = false
            myImgVwNewPwd.image = UIImage (named: "ic_visibility_off.png")
        }else {
            isNewSecure = true
            self.myTxtNewPassword.isSecureTextEntry = true
            myImgVwNewPwd.image = UIImage (named: "ic_visibility.png")
        }
        self.myImgVwNewPwd.image = self.myImgVwNewPwd.image!.withRenderingMode(.alwaysTemplate)
        self.myImgVwNewPwd.tintColor = UIColor.darkGray
    }
    
    @IBAction func clickViewConfirmPassword(_ sender: UIButton) {
        if isConfirmSecure == true {
            isConfirmSecure = false
            self.myTxtConfirmPassword.isSecureTextEntry = false
            myImgVwConfirmPwd.image = UIImage (named: "ic_visibility_off.png")
        }else {
            isConfirmSecure = true
            self.myTxtConfirmPassword.isSecureTextEntry = true
            myImgVwConfirmPwd.image = UIImage (named: "ic_visibility.png")
        }
        self.myImgVwConfirmPwd.image = self.myImgVwConfirmPwd.image!.withRenderingMode(.alwaysTemplate)
        self.myImgVwConfirmPwd.tintColor = UIColor.darkGray
    }
    
    @IBAction func clickConfirmAccountDeletion(_ sender: Any) {
        if selectedReasonIndex == DeletionReasonArr.count - 1  {
            self.reasonStr =  self.myTxtViewDeleteReason.text!
            if self.reasonStr.count < 5 {
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Information", comment: ""), aStrMessage: NSLocalizedString("Please enter atleast 5 characters", comment: ""))
            }else {
                let alertController = UIAlertController(title: NSLocalizedString("We're sorry to see you go", comment: ""), message: NSLocalizedString("Are you sure, do you want to delete your account?", comment: ""), preferredStyle:.alert)
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default)
                                          { action -> Void in
                    self.deleteReasonApi()
                })
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: { (UIAlertAction) -> Void in
                    
                    alertController.dismiss(animated: true)
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        }else {
            let alertController = UIAlertController(title: NSLocalizedString("We're sorry to see you go", comment: ""), message: NSLocalizedString("Are you sure, do you want to delete your account?", comment: ""), preferredStyle:.alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default)
                                      { action -> Void in
                self.deleteReasonApi()
            })
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: { (UIAlertAction) -> Void in
                
                alertController.dismiss(animated: true)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: Button Back action
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Api Call
    func getWebViewApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_WEBVIEW_PAGE_ID] = webViewId
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_WEBVIEW, isAuthorize: false, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            HELPER.hideLoadingAnimation()
            do {
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    if aDictInfo["error"] != nil{
                        let error = aDictInfo["error"] as! [String: String]
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                    }else {
                        self.myWebView.isHidden = false
                        self.webViewDic = aDictInfo["info"] as! [String : Any]
                        self.myLblNavTitle.text = self.webViewDic["title"] as? String
                        let description = self.webViewDic["content"] as! String
                        var headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=2.0, maximum-scale=1.0, minimum-scale=1.0'></header>"
                        headerString.append(description)
                        self.myWebView.loadHTMLString("\(headerString)", baseURL: nil)
                        
                    }
                }else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_COUNTRY_CODE_MODULE_EMPTY)
                }
                
            }catch {
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func contactUsApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_NAME] = self.myTxtContactName.text
        aDictParameters[K_PARAMS_EMAIL] = self.myTxtContactEmail.text
        aDictParameters[K_PARAMS_MOBILE] = self.myTxtContactMobile.text
        aDictParameters[K_PARAMS_MESSAGE] = self.myTxtComment.text
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        print(aDictParameters)
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_CONTACTUS, isAuthorize: false, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                print(response)
                var success:[String:Any]!
                if let successval = response["success"] as? [String:Any] {
                    success = successval
                }else if let error = response["error"] as? [String:Any]{
                    success = error
                }else {
                    var defaultError = [String:Any]()
                    defaultError["message"] = NSLocalizedString("Something went wrong. Please try again", comment: "")
                    defaultError["status"] = "888"
                    success = defaultError
                }
                if success["status"] as! String == "200" {
                    HELPER.showAlertControllerWithOkActionBlock(aViewController: self, aStrMessage: success["message"] as! String, okActionBlock: { (okAction) in
                        self.view.endEditing(true)
                        self.navigationController?.popViewController(animated: true)
                    })
                }else{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
                }
            }catch {
                print(error.localizedDescription)
            }
            HELPER.hideLoadingAnimation()
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func changePasswordApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_OLD_PASSWORD] = self.myTxtOldPassword.text
        aDictParameters[K_PARAMS_PASSWORD] = self.myTxtNewPassword.text
        aDictParameters[K_PARAMS_CONFIRM_PASSWORD] = self.myTxtConfirmPassword.text
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_CHANGE_PASSWORD, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                print(response)
                var success:[String:Any]!
                if let successval = response["success"] as? [String:Any] {
                    success = successval
                }else if let error = response["error"] as? [String:Any]{
                    success = error
                }else {
                    var defaultError = [String:Any]()
                    defaultError["message"] = NSLocalizedString("Something went wrong. Please try again", comment: "")
                    defaultError["status"] = "888"
                    success = defaultError
                }
                if success["status"] as! String == "200" {
                    HELPER.showAlertControllerWithOkActionBlock(aViewController: self, aStrMessage: success["message"] as! String, okActionBlock: { (okAction) in
                        self.navigationController?.popViewController(animated: true)

                    })
                }else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
                }
            }catch {
                print(error.localizedDescription)
            }
            HELPER.hideLoadingAnimation()
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func deleteReasonApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_REASON] = self.reasonStr
        print(aDictParameters)
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_DELETE_AC, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
                print(response)
                var success:[String:Any]!
                if let successval = response["success"] as? [String:Any] {
                    success = successval
                }else if let error = response["error"] as? [String:Any]{
                    success = error
                }else {
                    var defaultError = [String:Any]()
                    defaultError["message"] = NSLocalizedString("Something went wrong. Please try again", comment: "")
                    defaultError["status"] = "888"
                    success = defaultError
                }
                if success["status"] as! String == "200" {
                    UserDefaults.standard.removeObject(forKey: UD_USER_DETAILS)
                    UserDefaults.standard.removeObject(forKey: UD_SECRET_KEY)
                    UserDefaults.standard.removeObject(forKey: UD_RECENT_SEARCHES)
                    guestStatus = "1"
                    let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
                    let navi = UINavigationController.init(rootViewController: aViewController)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                    appDelegate.window?.rootViewController = navi
                    appDelegate.window?.makeKeyAndVisible()
                }else{
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
                }
            }catch{
                print(error.localizedDescription)
            }
            HELPER.hideLoadingAnimation()
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
}

extension CommonVc : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DeletionReasonArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reasonCell", for: indexPath) as! DeleteAccountTblCell
        
        cell.myLblReason.text = "\(DeletionReasonArr[indexPath.row])"
        
        if indexPath.row == selectedReasonIndex {
            cell.myImgRadioReason.image = UIImage (named: "ic_radio_check.png")
            self.reasonStr = "\(DeletionReasonArr[indexPath.row])"
        }else {
            cell.myImgRadioReason.image = UIImage (named: "ic_radio_uncheck.png")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == DeletionReasonArr.count - 1 {
            self.myTxtViewDeleteReason.isHidden = false
            selectedReasonIndex = indexPath.row
            self.myTableDeleteAccount.reloadData()
            
        }else {
            self.myTxtViewDeleteReason.isHidden = true
            selectedReasonIndex = indexPath.row
            self.myTableDeleteAccount.reloadData()
        }
    }
}

extension CommonVc : WKNavigationDelegate {
    override func loadView() {
        super.loadView()
        myWebView.navigationDelegate = self
    }
}

extension CommonVc: UITextViewDelegate{
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
