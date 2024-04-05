
import Foundation
import UIKit

let HELPER = Helper.sharedInstance
let SESSION = Session.sharedInstance
let HTTPMANAGER = HttpManager.sharedInstance
let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate
//let SCENEDELEGATE = UIApplication.shared.delegate as! SceneDelegate
let apiKey = "AIzaSyDKCB26rzkk4P2rMxMGLOUVRjsCDZTy5ok"

let oneSignalKey = "a85219a8-2886-4a90-95f3-9625d85414a4"

var globalLatitude:String = ""
var globalLongitude:String = ""
var languageID:String = "1"
var guestStatus:String = ""
var isRTLenabled : Bool = false
var deviceTokenStr = ""
var orderType = ""
var isUpdateTheApp = true

struct ConfigTheme
{
    static var themeColor = UIColor(red: 195/255.0, green: 31/255.0, blue: 38.0/255.0, alpha: 1.0)
    static var posBtnColor = UIColor(red: 255/255, green: 90/255, blue: 1/255, alpha: 1.0)
    static var negativeBtnColor = UIColor.gray
    static var customLightGray = UIColor(red: 133/255, green: 133/255, blue: 147/255, alpha: 1)
    static var customLightGray2 = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1)
    static var customLightGreen = UIColor(red: 171/255, green: 171/255, blue: 17/255, alpha: 1)
}
