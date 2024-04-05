//  LanguageManger.swift
//  Created by abedalkareem omreyh on 10/23/17.
//  Copyright © 2017 abedlkareem omreyh. All rights reserved.

import UIKit

var AssociatedObjectHandle: UInt8 = 0

class LanguageManger: Bundle {
    static let shared:LanguageManger = {
        object_setClass(Bundle.main, LanguageManger.self)
        return LanguageManger()
    }()
    
    // set/get seleccted language
    var currentLang:String{
        get{
            return UserDefaults.standard.string(forKey: "selectedLanguage") ?? NSLocale.preferredLanguages[0]
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "selectedLanguage")
        }
    }
    
    var isRightToLeft:Bool{
        get{
            let lang = currentLang
            return lang.contains("ar") || lang.contains("he")
        }
    }
    
    var appLocale:Locale{
        get{
            return Locale(identifier: currentLang)
        }
    }
    
    // overide localized string function
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &AssociatedObjectHandle) as? Bundle{
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }else{
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
    
    // set language useing enum
    @available(iOS 9.0, *)
    func setLanguage(language:Languages){
        let semanticContentAttribute:UISemanticContentAttribute = language == .ar ? .forceRightToLeft : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = semanticContentAttribute
        UINavigationBar.appearance().semanticContentAttribute = semanticContentAttribute
        UITextField.appearance().semanticContentAttribute = semanticContentAttribute
        UITextView.appearance().semanticContentAttribute = semanticContentAttribute
        setLanguage(language: language.rawValue)
    }
    
    // set language using string
    private func setLanguage(language:String){
        
        // change current bundle path from main to selected language
        if let value = Bundle.main.path(forResource: language, ofType: "lproj")
        {
            let bundle = Bundle(path: value)
            objc_setAssociatedObject(Bundle.main, &AssociatedObjectHandle, bundle, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
     /*   if let value = Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj")
        {
            
        }*/
        
        // change app language
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // set current language
        currentLang = language
        
        // used to get notification when language change (if you have somthing to do)
        NotificationCenter.default.post(name: NSNotification.Name.LanguageDidChange, object: nil)
    }
}

// MARK: NSNotification.Name extension
extension NSNotification.Name {
    // used to get notification when language change (if you have somthing to do)
    static var LanguageDidChange:NSNotification.Name{
        return NSNotification.Name.init("languageDidChange")
    }
}


// MARK: String extension
extension String {
    
    // used to localize string from code
    func localiz() -> String{
        guard let bundle = Bundle.main.path(forResource: LanguageManger.shared.currentLang, ofType: "lproj") else {
            return NSLocalizedString(self, comment: "")
        }
        
        let langBundle = Bundle(path: bundle)
        return NSLocalizedString(self, tableName: nil, bundle: langBundle!, comment: "")
    }
}

enum Languages:String{
    case ar,en,nl,ja,ko,vi,ru,sv,fr,es,pt,it,de,da,fi,nb,tr,el,id,ms,th,hi,hu,pl,cs,sk,uk,hr,ca,ro,he
    case enGB = "en-GB"
    case enAU = "en-AU"
    case enCA = "en-CA"
    case enIN = "en-IN"
    case frCA = "fr-CA"
    case esMX = "es-MX"
    case ptBR = "pt-BR"
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case zhHK = "zh-HK"
}


// MARK: UIApplication extension
extension UIApplication {
    // used to get top view controller
    static var topViewController:UIViewController?{
        get{
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            }else{
                return nil
            }
        }
    }
    
}

