

import Foundation
import UIKit

class Session: NSObject {
    
    static let sharedInstance: Session = {
        
        let instance = Session()
        
        // setup code
        
        return instance
    }()
    
    func userdefaultsSynchronize() {
        
        UserDefaults.standard.synchronize()
    }
    
    func setUserToken(token: String) {
        UserDefaults.standard.setValue(token, forKey: "user_authorization")
        userdefaultsSynchronize()
    }
    
    func getUserToken() -> String {
        return UserDefaults.standard.string(forKey: "user_authorization") ?? ""
    }
//
//    func setWishList(vendorList : [AllRestroVendor]) {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(vendorList) {
//            let defaults = UserDefaults.standard
//            defaults.set(encoded, forKey: UD_WISHLIST)
//        }
//        userdefaultsSynchronize()
//    }
//
//    
//    func getWishList() -> [AllRestroVendor] {
//        let defaults = UserDefaults.standard
//        if let vendorList = defaults.object(forKey: UD_WISHLIST) as? [AllRestroVendor] {
//            return vendorList
//        }
//        let aData = AllRestroVendor.init(vendorID: "", name: "", banner: "", logo: "", cuisines: "", vendorStatus: "", deliveryCharge: "", minimumAmount: "", deliveryTime: "", rating: Rating(count: "", rating: "", image: "", name: ""), vendorTypeID: "", freeDelivery: "", storeTypes: "", new: "", offer: "")
//        return [aData]
//    }
}
