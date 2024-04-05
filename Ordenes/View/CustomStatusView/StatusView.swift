
import UIKit

class StatusView: UIView {

    @IBOutlet var myBtnContinue: UIButton!
    @IBOutlet var myBtnCancel: UIButton!
    @IBOutlet var myViewContent: UIView!
    @IBOutlet var myViewContent2: UIView!
    @IBOutlet var myLblMsg: UILabel!
    @IBOutlet var myLblHeader: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("StatusView", owner: self, options: nil)
        addSubview(myViewContent)
        myViewContent.frame = self.bounds
        myViewContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    @IBAction func clickCancel(_ sender: Any){
        self.removeFromSuperview()
    }
}
