

import Foundation
import UIKit
import AudioToolbox

extension UIViewController {
    class var storyboardID : String {
        return "\(self)"
    }
    
    func showFavToastView(message : String) {
        let toastView = UILabel(frame: CGRect(x: 5, y: self.view.frame.size.height + 100, width: self.view.frame.size.width - 10, height: 50))
        toastView.backgroundColor = ConfigTheme.posBtnColor
        let toastLabel = UILabel(frame: CGRect(x: 5, y: 0, width: self.view.frame.size.width - 20, height: 50))
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .left;
        toastLabel.font = UIFont(name: "Poppins-Medium", size: 14.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.clipsToBounds = true
        let viewAllBtn = UIButton(frame: CGRect(x: self.view.frame.size.width - 90, y: self.view.frame.size.height + 100, width: 80, height: 50))
        viewAllBtn.setTitle(NSLocalizedString("View all", comment: ""), for: .normal)
        viewAllBtn.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 14.0)
        viewAllBtn.addTarget(self, action: #selector(self.clickViewAllFav(_:)), for: .touchUpInside)
        toastView.addSubview(toastLabel)
        self.view.addSubview(toastView)
        self.view.addSubview(viewAllBtn)
        UIView.animate(withDuration: 0.7, animations: { () -> Void in
            toastView.frame.origin.y = self.view.frame.size.height - 85
            viewAllBtn.frame.origin.y = self.view.frame.size.height - 85
        }, completion: { (bol) -> Void in
            
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            UIView.animate(withDuration: 1.0, delay: 0, options: .allowUserInteraction, animations: {
                toastLabel.alpha = 0.0
                viewAllBtn.alpha = 0.0
                toastView.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
                viewAllBtn.removeFromSuperview()
                toastView.removeFromSuperview()
            })
        }
    }
    
    @objc func clickViewAllFav(_ sender: UIButton){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: FavouriteVc.storyboardID) as! FavouriteVc
        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 130, y: self.view.frame.size.height - 200, width: 260, height: 50))
        toastLabel.backgroundColor = ConfigTheme.posBtnColor
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Helvatica-Regular", size: 8.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension Notification.Name {
    static let restaurantNavigation = Notification.Name("navigation_to_restaurant")
}

extension UIStoryboard {
    
    convenience init(_ storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    enum Storyboard: String {
        case main = "Main"
        case info = "Info"
        case grocery = "Grocery"
    }
}

extension NSObject {
    
    func smSearch(text: String, action: Selector, afterDelay: Double = 0.6) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(action, with: text, afterDelay: afterDelay)
    }
}

extension Date {
    func getTimeStamp() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

extension URLRequest {
    var isHttpLink: Bool {
        return self.url?.scheme?.contains("http") ?? false
    }
}

extension UIImage {
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}

extension UIView{
    
    func addDashBorder() {
        let color = ConfigTheme.themeColor.cgColor

            let shapeLayer:CAShapeLayer = CAShapeLayer()

            let frameSize = self.frame.size
            let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

            shapeLayer.bounds = shapeRect
            shapeLayer.name = "DashBorder"
            shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = color
            shapeLayer.lineWidth = 1.5
            shapeLayer.lineJoin = .round
            shapeLayer.lineDashPattern = [10,4]
            shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 10).cgPath

            self.layer.masksToBounds = false

            self.layer.addSublayer(shapeLayer)
    }
    
    func dropShadow(cornerRadius : CGFloat, opacity : Float, radius: CGFloat) {
        layer.masksToBounds = false
        layer.rasterizationScale = UIScreen.main.scale
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = radius
    }
    
    func removeShadow(cornerRadius : CGFloat) {
        layer.masksToBounds = false
        layer.rasterizationScale = UIScreen.main.scale
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 0
    }
    
    func shake(){
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
            self.layer.add(animation, forKey: "position")
            UIDevice.vibrate()
    }
    
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.alpha = 1.0
            }, completion: completion)
    }

    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 3.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
            UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.alpha = 0.0
            }, completion: completion)
    }
    
    func applyGradient() {
        
        let colorRight =  UIColor(red: 247.0/255.0, green: 145.0/255.0, blue: 2.0/255.0, alpha: 1.0).cgColor
        let colorLeft = UIColor(red: 255.0/255.0, green: 64.0/255.0, blue: 1.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorLeft, colorRight]
        gradientLayer.locations = [0.0 , 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
        //gradientLayer.frame.size.width = self.view.frame.size.width
        //self.viewOrangeBg.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        clipsToBounds = true
    }
    
    func roundTopCorners(radius: CGFloat) {
        
           self.clipsToBounds = true
           self.layer.cornerRadius = radius
           if #available(iOS 11.0, *) {
               self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
           } else {
               self.roundCorners(corners: [.topLeft, .topRight], radius: radius)
           }
    }
    
    func roundBottomCorners(radius: CGFloat) {
           self.clipsToBounds = true
           self.layer.cornerRadius = radius
           if #available(iOS 11.0, *) {
               self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
           } else {
               self.roundCorners(corners: [.bottomLeft, .bottomRight], radius: radius)
           }
    }
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

extension UINavigationController {
    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)

        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }

    func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)

        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}
