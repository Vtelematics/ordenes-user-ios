

import Foundation
import UIKit
import IHProgressHUD

class Helper: NSObject {

    
    
    static let sharedInstance: Helper = {
        
        let instance = Helper()
        
        // setup code
        return instance
    }()
    
    // Rounded View
    func setRoundedView(aView : UIView)  {
        
        aView.layer.masksToBounds = true
        aView.clipsToBounds = true
        aView.layer.cornerRadius = aView.frame.size.width / 2
    }
    
    // Round Corner View
    func setRoundCornerView(aView : UIView, borderRadius:CGFloat)  {
        
        aView.layer.masksToBounds = true
        aView.clipsToBounds = true
        aView.layer.cornerRadius = borderRadius
    }
    
    func changeTintColor(imgVw : UIImageView, img : String, color : UIColor){
        imgVw.image = UIImage(named: img)
        imgVw.image = imgVw.image!.withRenderingMode(.alwaysTemplate)
        imgVw.tintColor = color
    }
    
    // Set border view
    func setBorderView(aView : UIView, borderWidth:CGFloat, borderColor:UIColor, cornerRadius:CGFloat)  {
        
        aView.layer.borderWidth = borderWidth
        aView.layer.borderColor = borderColor.cgColor
        aView.layer.masksToBounds = true
        aView.layer.cornerRadius = cornerRadius
    }
    
    func getAppThemeColor() -> UIColor {
        
        let aAppthemeColor = UIColor(red: 195/255.0, green: 31/255.0, blue: 38.0/255.0, alpha: 1.0)
        return aAppthemeColor
    }
    
    // Loading Animation
    func showLoadingAnimationWithTitle(aViewController:UIViewController, aStrText : String) {
            
        IHProgressHUD.set(foregroundColor: getAppThemeColor())
        IHProgressHUD.set(defaultStyle: .light)
        IHProgressHUD.set(defaultAnimationType: .flat)
        IHProgressHUD.set(defaultMaskType: .black)
        IHProgressHUD.show(withStatus: aStrText)
    }
    
    func showLoadingAnimation(aViewController:UIViewController) {
        
        IHProgressHUD.set(foregroundColor: getAppThemeColor())
        IHProgressHUD.set(defaultStyle: .light)
        IHProgressHUD.set(defaultAnimationType: .flat)
        IHProgressHUD.set(defaultMaskType: .black)
        IHProgressHUD.show()
    }
    
    func hideLoadingAnimation() {
        IHProgressHUD.dismiss()
    }
    
    // MARK : Alert Controller Methods
    
    func showDefaultAlertViewController(aViewController : UIViewController, alertTitle: String, aStrMessage : String)  {
        
        let aAlertController = UIAlertController(title: alertTitle, message: aStrMessage, preferredStyle: UIAlertController.Style.alert)
        
        let btnTitle = "OK"
        
        aAlertController.addAction(UIAlertAction(title: btnTitle, style: UIAlertAction.Style.default, handler: nil))
        
        aViewController.present(aAlertController, animated: true, completion: nil)
    }
    
    func showAlertControllerWithYesActionBlockWithTitleButton(aViewController : UIViewController, aStrMessage : String, okActionBlock : @escaping (UIAlertAction) ->())  {
           
           let aAlertController = UIAlertController(title: APP_NAME, message: aStrMessage, preferredStyle: UIAlertController.Style.alert)
           
           let btnTitle = "Yes"
           
           aAlertController.addAction(UIAlertAction(title: btnTitle, style: UIAlertAction.Style.default, handler: { (action) in
               
               okActionBlock(action)
           }))
           
           aViewController.present(aAlertController, animated: true, completion: nil)
       }
    
    func showAlertControllerWithOkActionBlock(aViewController : UIViewController, aStrMessage : String, okActionBlock : @escaping (UIAlertAction) ->())  {
        
        let aAlertController = UIAlertController(title: APP_NAME, message: aStrMessage, preferredStyle: UIAlertController.Style.alert)
        
        let btnTitle = "OK"
        
        aAlertController.addAction(UIAlertAction(title: btnTitle, style: UIAlertAction.Style.default, handler: { (action) in
            
            okActionBlock(action)
        }))
        
        aViewController.present(aAlertController, animated: true, completion: nil)
    }
    
    func showAlertControllerWithTitleOkActionBlock(aViewController : UIViewController, aStrTitle: String, aStrMessage : String, okActionBlock : @escaping (UIAlertAction) ->())  {
        
        let aAlertController = UIAlertController(title: APP_NAME, message: aStrMessage, preferredStyle: UIAlertController.Style.alert)
        
        let btnTitle = "OK"
        
        aAlertController.addAction(UIAlertAction(title: btnTitle, style: UIAlertAction.Style.default, handler: { (action) in
            
            okActionBlock(action)
        }))
        
        aViewController.present(aAlertController, animated: true, completion: nil)
    }
    
    func showAlertControllerWithCancelActionBlock(aViewController : UIViewController, aStrMessage : String, cancelActionBlock : @escaping (UIAlertAction) ->())  {
        
        let aAlertController = UIAlertController(title: APP_NAME, message: aStrMessage, preferredStyle: UIAlertController.Style.alert)
        
        let btnTitle = "Cancel"
        
        aAlertController.addAction(UIAlertAction(title: btnTitle, style: UIAlertAction.Style.cancel, handler: { (UIAlertAction) in
            
            cancelActionBlock(UIAlertAction)
            
        }))
        
        aViewController.present(aAlertController, animated: true, completion: nil)
    }
    
    func showAlertControllerInWithTitleOk(aViewController : UIViewController,title : String, aStrMessage : String, okButtonTitle : String, okActionBlock : @escaping (UIAlertAction) ->()) {
        
        let aAlertController = UIAlertController(title: title, message: aStrMessage, preferredStyle: UIAlertController.Style.alert)
        
        aAlertController.addAction(UIAlertAction(title: okButtonTitle, style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            
            okActionBlock(UIAlertAction)
            
        }))
        
        aViewController.present(aAlertController, animated: true, completion: nil)
    }
    
    func showAlertControllerIn(aViewController : UIViewController, aStrMessage : String, okButtonTitle : String, cancelBtnTitle : String, okActionBlock : @escaping (UIAlertAction) ->() , cancelActionBlock : @escaping (UIAlertAction) ->())  {
        
        let aAlertController = UIAlertController(title: APP_NAME, message: aStrMessage, preferredStyle: UIAlertController.Style.alert)
        
        aAlertController.addAction(UIAlertAction(title: okButtonTitle, style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            
            okActionBlock(UIAlertAction)
            
        }))
        
        aAlertController.addAction(UIAlertAction(title: cancelBtnTitle, style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            
            cancelActionBlock(UIAlertAction)
            
        }))
        
        aViewController.present(aAlertController, animated: true, completion: nil)
    }
    
    func showAlertControllerWithTitleIn(aViewController : UIViewController, aStrTitle: String, aStrMessage : String, okButtonTitle : String, cancelBtnTitle : String, okActionBlock : @escaping (UIAlertAction) ->() , cancelActionBlock : @escaping (UIAlertAction) ->())  {
        
        let title = aStrTitle == "" ? APP_NAME : aStrTitle
        
        let aAlertController = UIAlertController(title: title, message: aStrMessage, preferredStyle: UIAlertController.Style.alert)
        
        aAlertController.addAction(UIAlertAction(title: okButtonTitle, style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            
            okActionBlock(UIAlertAction)
            
        }))
        
        aAlertController.addAction(UIAlertAction(title: cancelBtnTitle, style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            
            cancelActionBlock(UIAlertAction)
            
        }))
        
        aViewController.present(aAlertController, animated: true, completion: nil)
    }
    
    // Date and time
    func getDeviceStamp() -> String {
        
        let timeStamp = Date().getTimeStamp()
        let aStrTimeStamp = "\(timeStamp!)"
        return aStrTimeStamp
    }
    
    // API Encode
    func encodeValue(_ string: String) -> String? {
        guard let unescapedString = string.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted) else { return nil }
        return unescapedString
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
