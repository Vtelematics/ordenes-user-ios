//
//  ProfileVc.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 16/08/22.
//

import UIKit
import OpalImagePicker
import Photos

class ProfileVc: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var myViewCamera: UIView!
    @IBOutlet weak var myViewBlur: UIView!
    @IBOutlet weak var myTxtFirstName: UITextField!
    @IBOutlet weak var myTxtLastName: UITextField!
    @IBOutlet weak var myTxtEmail: UITextField!
    @IBOutlet weak var myTxtMobile: UITextField!
    @IBOutlet weak var myImgUserProfile: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var profileImgStr = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        self.myTxtFirstName.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtLastName.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtEmail.textAlignment = isRTLenabled == true ? .right : .left
        self.myTxtMobile.textAlignment = isRTLenabled == true ? .right : .left
        self.getProfile()
    }
    
    //MARK: Button action
    @IBAction func clickSave(_ sender: UIButton) {
        if myTxtFirstName.text == "" {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your First Name", comment: ""))
        }else {
            if myTxtLastName.text == "" {
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Last Name", comment: ""))
            }else{
                if myTxtEmail.text == "" {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter your Email-Id", comment: ""))
                }else{
                    if !HELPER.isValidEmail(testStr: myTxtEmail.text!){
                        HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: NSLocalizedString("Please Enter a Valid Email-Id", comment: ""))
                    }else{
                        editProfileApi()
                    }
                }
            }
        }
    }
    
    @IBAction func clickProfileImage(_ sender : Any){
        self.myViewBlur.isHidden = false
        self.myViewCamera.isHidden = false
        UIView.animate(withDuration: 0.50, animations: {
            self.myViewCamera.frame = CGRect(x: 0 , y: self.myViewBlur.frame.size.height - self.myViewCamera.frame.size.height, width: UIScreen.main.bounds.size.width, height: self.myViewCamera.frame.height)
        })
    }
    
    @IBAction func clickCamera(_ sender : Any){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.cameraCaptureMode = .photo
            self.present(self.imagePicker, animated: true, completion: nil)
        }else {
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Camera Not Found", comment: ""), aStrMessage: NSLocalizedString("This device has no Camera", comment: ""))
        }
    }
    
    @IBAction func clickLibrary(_ sender : Any){
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
            //Show error to user?
            return
        }
        let imagePicker = OpalImagePickerController()
        imagePicker.maximumSelectionsAllowed = 1
        imagePicker.allowedMediaTypes = Set([PHAssetMediaType.image])
        
        let configuration = OpalImagePickerConfiguration()
        configuration.maximumSelectionsAllowedMessage = NSLocalizedString("You can upload any one image only!", comment: "")
        imagePicker.configuration = configuration
        
        //Present Image Picker
        presentOpalImagePickerController(imagePicker, animated: true, select: { (assets) in
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            // this one is key
            requestOptions.isSynchronous = true
            
            let asset = (assets as AnyObject).object(at: 0) as PHAsset
            if (asset.mediaType == PHAssetMediaType.image)
            {
                PHImageManager.default().requestImage(for: asset , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (pickedImage, info) in
                    
                    self.myImgUserProfile.contentMode = .scaleAspectFit
                    self.myImgUserProfile.image = pickedImage
                    if let updatedImage = self.myImgUserProfile.image?.updateImageOrientionUpSide() {
                        self.uploadGalleryImage(image: updatedImage)
                    }else {
                        self.uploadGalleryImage(image: self.myImgUserProfile.image!)
                    }
                })
            }
            imagePicker.dismiss(animated: true, completion: nil)
        }, cancel: {
            
        })
    }
    
    @IBAction func clickCancelCamera(_ sender : Any){
        self.myViewBlur.isHidden = true
        self.myViewCamera.isHidden = true
        self.myViewCamera.frame.origin.y = self.view.frame.size.height
    }
    
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: {})
                
        guard let pickedImage = info[.originalImage] as? UIImage else {
            fatalError("Something went wrong")
        }
        
        self.myImgUserProfile.contentMode = .scaleAspectFit
        self.myImgUserProfile.image = pickedImage
        
        if let updatedImage = self.myImgUserProfile.image?.updateImageOrientionUpSide() {
            uploadGalleryImage(image: updatedImage)
        } else {
            uploadGalleryImage(image: self.myImgUserProfile.image!)
        }
    }
    
    func uploadGalleryImage( image:UIImage) {
        
        let imageData:NSData = image.jpegData(compressionQuality: 0.01)! as NSData
        let baseStr = imageData.base64EncodedString(options: [])
        profileImgStr = "\(baseStr.replacingOccurrences(of: "+", with: "%2B"))"
        self.myViewBlur.isHidden = true
        self.myViewCamera.isHidden = true
        self.myViewCamera.frame.origin.y = self.view.frame.size.height
        
        var aDictParameters = [String : Any]()
        
        aDictParameters[K_PARAMS_IMAGE] = "\(profileImgStr)"
        
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_PROFILE_PICTURE, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
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
                    
                    let urlStr = response["image"] as! String
                    print(urlStr)
                    let trimmedUrl = urlStr.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20")
                    print(trimmedUrl)
                    var activityLoader = UIActivityIndicatorView()
                    activityLoader = UIActivityIndicatorView(style: .gray)
                    activityLoader.center = self.myImgUserProfile.center
                    activityLoader.startAnimating()
                    self.myImgUserProfile.addSubview(activityLoader)
                    self.myImgUserProfile.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                        
                        if image != nil
                        {
                            activityLoader.stopAnimating()
                        }
                        else
                        {
                            activityLoader.stopAnimating()
                            self.myImgUserProfile.image = UIImage(named: "App_Logo")
                        }
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
    
    func editProfileApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_FNAME] = self.myTxtFirstName.text
        aDictParameters[K_PARAMS_LNAME] = self.myTxtLastName.text
        aDictParameters[K_PARAMS_EMAIL] = self.myTxtEmail.text
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_EDIT_PROFILE, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
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
    
    func getProfile() {
        let aDictParameters = [String : Any]()
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_GET_PROFILE, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            do {
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
                    let userDic = response["customer_info"] as? [String:Any]
                    self.myTxtFirstName.text = "\(userDic?["firstname"] as! String)"
                    self.myTxtLastName.text = "\(userDic?["lastname"] as! String)"
                    self.myTxtEmail.text = "\(userDic?["email"] as! String)"
                    self.myTxtMobile.text = "\(userDic?["telephone"] as! String)"
                    if let _ =  userDic?["image"] as? NSNull {
                        self.myImgUserProfile.image = UIImage (named: "profile")
                    }else {
                        let imageUrl =  userDic?["image"] as! String
                        let trimmedUrl = imageUrl.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20")
                        if imageUrl.contains("placeholder") || imageUrl == "" {
                            self.myImgUserProfile.image = UIImage(named: "ic_user_profile")
                        }else {
                            var activityLoader = UIActivityIndicatorView()
                            activityLoader = UIActivityIndicatorView(style: .medium)
                            activityLoader.center = (self.myImgUserProfile.center)
                            activityLoader.startAnimating()
                            self.myImgUserProfile.addSubview(activityLoader)
                            self.myImgUserProfile.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
                                if image != nil {
                                    activityLoader.stopAnimating()
                                }else {
                                    activityLoader.stopAnimating()
                                    self.myImgUserProfile.image = UIImage(named: "ic_user_profile")
                                }
                            })
                        }
                    }
                }else {
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
