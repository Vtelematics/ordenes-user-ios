import UIKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import FirebaseCore
import OneSignal

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window:UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        if #available(iOS 13.0, *) {
            UINavigationBar.appearance().barTintColor = .systemBackground
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:ConfigTheme.themeColor]
            UINavigationBar.appearance().tintColor = ConfigTheme.themeColor
        } else{
            UINavigationBar.appearance().barTintColor = ConfigTheme.themeColor
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:ConfigTheme.themeColor]
            UINavigationBar.appearance().tintColor = ConfigTheme.themeColor
            if let statusbar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusbar.backgroundColor = ConfigTheme.themeColor
            }
        }
        
        if #available(iOS 15.0, *) {
            //UITableView.appearance().sectionHeaderTopPadding = 0.0
        }
        if let uuid = UIDevice.current.identifierForVendor?.uuidString{
            deviceTokenStr = uuid
        }
        if let userKey = UserDefaults.standard.value(forKey: UD_SECRET_KEY), userKey as! String != ""{
            guestStatus = "0"
        }else{
            guestStatus = "1"
        }
        orderType = "1"
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardAppearance = .light
        IQKeyboardManager.shared.toolbarTintColor = .gray
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)
        // Onesignal
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: true]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: oneSignalKey,
                                        handleNotificationReceived: { notification in
                                            if notification?.payload.additionalData != nil {
                                                let additionalData = notification?.payload.additionalData

//                                                if application.applicationState == UIApplication.State.active {
//                                                    print("open- 1")
//                                                }else if application.applicationState == UIApplication.State.background {
//                                                    print("open- 1.1")
//                                                }else if application.applicationState == UIApplication.State.inactive {
//                                                    if let orderId = additionalData?["order_id"] as? NSNumber{
//                                                        print("open- 2")
//                                                        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: OrderInfoVc.storyboardID) as! OrderInfoVc
//                                                        aViewController.orderId = "\(orderId)"
//                                                        aViewController.isFromNotification = true
//                                                        let navi = UINavigationController.init(rootViewController: aViewController)
//                                                        self.changeRootViewController(aViewController: navi)
//                                                    }else if let orderId = additionalData?["order_id"] as? String{
//                                                        print("open- 3")
//                                                        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: OrderInfoVc.storyboardID) as! OrderInfoVc
//                                                        aViewController.orderId = orderId
//                                                        aViewController.isFromNotification = true
//                                                        let navi = UINavigationController.init(rootViewController: aViewController)
//                                                        self.changeRootViewController(aViewController: navi)
//                                                    }
//                                                }else{
//                                                    print("open - 4")
//                                                }
                                            }
        },
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        if let id = status.subscriptionStatus.userId {
            print("\nOneSignal UserId:", id)
        }
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        if (UserDefaults.standard.object(forKey: UD_LANGUAGE_ID) != nil)
        {
            languageID = UserDefaults.standard.object(forKey: UD_LANGUAGE_ID) as! String
            if languageID == "1"{
                isRTLenabled = false
            }else{
                isRTLenabled = true
            }
        }
        else
        {
            languageID = "1"
        }
        UserDefaults.standard.set(languageID, forKey: UD_LANGUAGE_ID)
        let selectedLanguage:Languages = Int(languageID) == 1 ? .en : .ar
        LanguageManger.shared.setLanguage(language: selectedLanguage)
        if let location = UserDefaults.standard.value(forKey: UD_SELECTED_ADDRESS), "\(location)" != ""
        {
            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
            let navi = UINavigationController.init(rootViewController: aViewController)
            self.changeRootViewController(aViewController: navi)
        }
        else
        {
            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: MapVc.storyboardID) as! MapVc
            let navi = UINavigationController.init(rootViewController: aViewController)
            self.changeRootViewController(aViewController: navi)
        }
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
           if application.applicationState == .background {
               // Perform actions specific to when the app enters the background state
               print("App entered background state")
           }
       }

       func applicationWillEnterForeground(_ application: UIApplication) {
           if application.applicationState == .inactive {
               // Perform actions specific to when the app is about to enter the foreground
               print("App is about to enter foreground state")
           }
       }

       func applicationDidBecomeActive(_ application: UIApplication) {
           if application.applicationState == .active {
               // Perform actions specific to when the app becomes active (in the foreground)
               print("App became active")
           }
       }
    
    func changeRootViewController(aViewController: UIViewController) {
        if !(window!.rootViewController != nil) {
            window?.rootViewController = aViewController
            return
        }
        let snapShot: UIView? = window?.snapshotView(afterScreenUpdates: true)
        aViewController.view.addSubview(snapShot!)
        window?.rootViewController = aViewController
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            snapShot?.layer.opacity = 0
            snapShot?.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        }, completion: {(_ finished: Bool) -> Void in
            snapShot?.removeFromSuperview()
        })
    }
    
    // Push notification received
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //use userInfo to fetch push data
        
        completionHandler(.newData)
        print(userInfo)
        
        if application.applicationState == UIApplication.State.active {
            print("App already open")
        }else{
            print("App opened from Notification")
            if let value = userInfo["custom"] {
                let detailDic = value as! NSDictionary
                let orderIdDic = detailDic["a"] as! NSDictionary
                if let orderId = orderIdDic["order_id"] as? NSNumber{
                    print("open- 2")
                    let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: OrderInfoVc.storyboardID) as! OrderInfoVc
                    aViewController.orderId = "\(orderId)"
                    aViewController.isFromNotification = true
                    let navigationController = UINavigationController.init(rootViewController: aViewController)
                    self.window?.rootViewController = navigationController
                    self.window?.makeKeyAndVisible()
                    
                }else if let orderId = orderIdDic["order_id"] as? String{
                    print("open- 3")
                    let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: OrderInfoVc.storyboardID) as! OrderInfoVc
                    aViewController.orderId = "\(orderId)"
                    aViewController.isFromNotification = true
                    let navigationController = UINavigationController.init(rootViewController: aViewController)
                    self.window?.rootViewController = navigationController
                    self.window?.makeKeyAndVisible()
                }
            }else {
                print("other notification / message")
            }
        }
    }
}


