
import UIKit

class OrderConfirmTblCell: UITableViewCell {

    @IBOutlet weak var myLblHeader: UILabel!
    @IBOutlet weak var myLblProductName: UILabel!
    @IBOutlet weak var myLblOptions: UILabel!
    @IBOutlet weak var myLblQuantity: UILabel!
    @IBOutlet weak var myLblOrderNo: UILabel!
    @IBOutlet weak var myLblAmount: UILabel!
    @IBOutlet weak var myLblPaymentMode: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
