

import Foundation
import UIKit
import Alamofire

class HttpManager: NSObject {
    
    var dictDefaultParams = [String : String]()
    
    static let sharedInstance: HttpManager = {
        let instance = HttpManager()
        
        return instance
    }()
    
    func callGetApiUsingEncryption(strCase:String, isAuthorize: Bool, dictParameters:[String : String], aController : UIViewController, sucessBlock: @escaping (NSDictionary)->(), failureBlock:@escaping (String) ->()) {
        
        if !Reachability.isConnectedToNetwork() {
            
            HELPER.hideLoadingAnimation()
            //NotificationCenter.default.post(name: .noInternetAlert, object: nil)
            return
        }
        var secretKey = ""
        if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
            secretKey = UserDefaults.standard.value(forKey: UD_SECRET_KEY) as! String
        }
        var headers:HTTPHeaders? = nil
        if isAuthorize {
            headers = ["Content-Type": "application/json", "Accept" : "application/json", "Customer-Authorization" : secretKey ]
        } else {
            headers = ["Content-Type": "application/json", "Accept" : "application/json" ]
        }
        
        var aStrApiUrl = String()
        aStrApiUrl = API_BASE_URL + strCase
        AF.request(aStrApiUrl, method: .get, parameters: dictParameters, encoding: Alamofire.URLEncoding.default, headers: headers).responseJSON {
            (dataResponse) in
            var jsonResponse  = [String :Any]()
            
            switch dataResponse.result {
            case .success(let json):
                if dataResponse.response!.statusCode == 200 {
                    
                    if let encryptedData:NSData = dataResponse.data as NSData? {
                        
                        do {
                            jsonResponse = try JSONSerialization.jsonObject(with: encryptedData as Data, options: .mutableContainers) as! [String : Any]
                            sucessBlock(jsonResponse as NSDictionary)
                        }
                        
                        catch let error
                        {
                            print(error)
                        }
                    }
                    else {
                        HELPER.hideLoadingAnimation()
                    }
                } else {
                    let jsonResponseMessage = json as? [String:Any]
                    HELPER.hideLoadingAnimation()
                    let data = jsonResponseMessage?["error"] as? [String: Any]
                    HELPER.showAlertControllerWithOkActionBlock(aViewController: aController, aStrMessage: data!["message"] as! String, okActionBlock: { (okAction) in
                    })
                }
            case .failure(let error):
                print(error)
                HELPER.hideLoadingAnimation()
                failureBlock(error.errorDescription!)
            }
        }
    }
    
    func callPostApiUsingEncryption(strCase:String, isAuthorize: Bool, dictParameters:[String : Any], aController : UIViewController, sucessBlock: @escaping (NSDictionary)->(), failureBlock:@escaping (String) ->()) {
        
        if !Reachability.isConnectedToNetwork() {
            
            HELPER.hideLoadingAnimation()
            //NotificationCenter.default.post(name: .noInternetAlert, object: nil)
            return
        }
        var secretKey = ""
        if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
            secretKey = UserDefaults.standard.value(forKey: UD_SECRET_KEY) as! String
        }
        print(secretKey)
        
        var headers:HTTPHeaders? = nil
        if isAuthorize {
            headers = ["Content-Type": "application/json", "Accept" : "application/json", "Customer-Authorization" : secretKey ]
        } else {
            headers = ["Content-Type": "application/json", "Accept" : "application/json" ]
        }
        
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: dictParameters, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)!
            print(jsonString)
        }
        
        var aStrApi = String()
        aStrApi = API_BASE_URL + strCase
        print(aStrApi)
        AF.request(aStrApi, method : .post, parameters : dictParameters, encoding : JSONEncoding.default, headers: headers).responseJSON {
            (dataResponse) in
            var jsonResponse  = [String :Any]()
            switch dataResponse.result {
            case .success(let json):
                if dataResponse.response!.statusCode == 200 {
                    if let encryptedData:NSData = dataResponse.data as NSData? {
                        do {
                            jsonResponse = try JSONSerialization.jsonObject(with: encryptedData as Data, options: .mutableContainers) as! [String : Any]
                            //print(jsonResponse)
                            sucessBlock(jsonResponse as NSDictionary)
                        }
                        catch let error {
                            print(error)
                        }
                    }
                    else {
                        HELPER.hideLoadingAnimation()
                    }
                } else {
                    
                    let jsonResponseMessage = json as? [String:Any]
                    HELPER.hideLoadingAnimation()
                    let data = jsonResponseMessage?["error"] as? [String: Any]
//                    HELPER.showAlertControllerWithOkActionBlock(aViewController: aController, aStrMessage: data!["message"] as! String, okActionBlock: { (okAction) in
//                    })
                }
            case .failure(let error):
                print(error)
                HELPER.hideLoadingAnimation()
                failureBlock(error.errorDescription!)
            }
        }
    }
//
//    func callPostApiWithErrorUsingEncryption(strCase:String, isAuthorize: Bool, dictParameters:[String : Any], aController : UIViewController, sucessBlock: @escaping (NSDictionary)->(), sucessBlockWithError: @escaping (NSDictionary)->(), failureBlock:@escaping (String) ->()) {
//
//        if !Reachability.isConnectedToNetwork() {
//
//            HELPER.hideLoadingAnimation()
//            //NotificationCenter.default.post(name: .noInternetAlert, object: nil)
//            return
//        }
//        var secretKey = ""
//        if UserDefaults.standard.value(forKey: UD_SECRET_KEY) != nil{
//            secretKey = UserDefaults.standard.value(forKey: UD_SECRET_KEY) as! String
//        }
//
//        var headers:HTTPHeaders? = nil
//        if isAuthorize {
//            headers = ["Content-Type": "application/json", "Accept" : "application/json", "Customer-Authorization" : secretKey ]
//        } else {
//            headers = ["Content-Type": "application/json", "Accept" : "application/json" ]
//        }
//        var aStrApi = String()
//        aStrApi = API_BASE_URL + strCase
//        AF.request(aStrApi, method : .post, parameters : dictParameters, encoding : JSONEncoding.default, headers: headers).responseJSON {
//            (dataResponse) in
//
//            var jsonResponse  = [String :Any]()
//
//            switch dataResponse.result {
//            case .success(let json):
//                if dataResponse.response!.statusCode == 200 {
//
//                    if let encryptedData:NSData = dataResponse.data as NSData? {
//
//                        do {
//
//                            jsonResponse = try JSONSerialization.jsonObject(with: encryptedData as Data, options: .mutableContainers) as! [String : Any]
//
//                            sucessBlock(jsonResponse as NSDictionary)
//                        }
//
//                        catch let error {
//
//                            print(error)
//                        }
//                    }
//                    else {
//
//                        HELPER.hideLoadingAnimation()
//                    }
//
//                } else {
//                    if let encryptedData:NSData = dataResponse.data as NSData? {
//
//                        do {
//
//                            jsonResponse = try JSONSerialization.jsonObject(with: encryptedData as Data, options: .mutableContainers) as! [String : Any]
//                            sucessBlockWithError(jsonResponse as NSDictionary)
//                        }
//                        catch let error {
//
//                            print(error)
//                        }
//                    }
//                    else {
//
//                        HELPER.hideLoadingAnimation()
//                    }
//                }
//            case .failure(let error):
//                print(error)
//                HELPER.hideLoadingAnimation()
//                failureBlock(error.errorDescription!)
//            }
//        }
//    }
}
