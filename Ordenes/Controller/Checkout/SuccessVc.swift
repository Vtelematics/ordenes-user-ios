
import UIKit

class SuccessVc: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clickContinue (_ sender : Any){
        let aViewController = UIStoryboard(.main).instantiateViewController(withIdentifier: HomeVc.storyboardID) as! HomeVc
        let navi = UINavigationController.init(rootViewController: aViewController)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window?.rootViewController = navi
        appDelegate.window?.makeKeyAndVisible()
    }
}
