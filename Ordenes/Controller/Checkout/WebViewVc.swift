//
//  WebViewVc.swift
//  Ordenes
//
//  Created by Adyas infotech on 11/11/22.
//

import UIKit
import WebKit

class WebViewVc: UIViewController, WKNavigationDelegate, WKUIDelegate  {
    @IBOutlet weak var myWebView:WKWebView!
    var paymentBaseUrl:String = ""
    var orderId:String = ""
    var callBackUrl:String = ""
    
    override func loadView() {
        super.loadView()
        self.tabBarController?.tabBar.isHidden = true
        myWebView.uiDelegate = self
        myWebView.navigationDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        let payURl:String = "\(paymentBaseUrl)airtel/\(orderId)"
        let url = URL(string: payURl)!
        print(url)
        myWebView.load(URLRequest(url: url))
        myWebView.allowsBackForwardNavigationGestures = true
    }
    
    @IBAction func clickBack(_ sender: Any) {
        HELPER.showAlertControllerIn(aViewController: self, aStrMessage: NSLocalizedString("Do you want to cancel the order", comment: ""), okButtonTitle: NSLocalizedString("Agree", comment: ""), cancelBtnTitle: NSLocalizedString("Cancel", comment: "")) { (okAction) in
            let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
            let navi = UINavigationController.init(rootViewController: aViewController)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
            appDelegate.window?.rootViewController = navi
            appDelegate.window?.makeKeyAndVisible()
        } cancelActionBlock: { (cancelAction) in
            self.dismiss(animated: true)
        }
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        print("callback\(navigationAction.request.url?.absoluteString ?? "")")
        switch navigationAction.request.url?.absoluteString {
        case "\(paymentBaseUrl)payment_status/1":
            decisionHandler(.allow)
            self.callPlaceOrderApi(orderID: orderId)
        case "\(paymentBaseUrl)payment_status/0":
            decisionHandler(.allow)
            let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Transaction Cancelled", comment : ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
                let navi = UINavigationController.init(rootViewController: aViewController)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                appDelegate.window?.rootViewController = navi
                appDelegate.window?.makeKeyAndVisible()
            }))
            self.present(alert, animated: true, completion: nil)
        default:
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //HELPER.hideLoadingAnimation()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        HELPER.hideLoadingAnimation()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        HELPER.hideLoadingAnimation()
    }
    
    func callPlaceOrderApi(orderID : String) {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_ORDER_ID] = orderID
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        print(aDictParameters)
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_PLACE_ORDER, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
            print(response)
            var success:[String:Any]
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
                if orderType == "2"{
                    let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: SuccessVc.storyboardID) as! SuccessVc
                    self.navigationController?.isNavigationBarHidden = true
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }else {
                    let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: OrderConfirmVc.storyboardID) as! OrderConfirmVc
                    aViewController.isFromSuccess = true
                    aViewController.orderId = orderID
                    self.navigationController?.pushViewController(aViewController, animated: true)
                }
                HELPER.hideLoadingAnimation()
            }else {
                HELPER.hideLoadingAnimation()
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: success["message"] as! String)
            }
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
}
