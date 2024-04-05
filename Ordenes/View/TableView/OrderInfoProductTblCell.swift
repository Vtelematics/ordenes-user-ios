//
//  OrderInfoProductCell.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 19/08/22.
//

import UIKit

class OrderInfoProductTblCell: UITableViewCell {

    @IBOutlet var lblProductName : UILabel!
    @IBOutlet var lblProductPrice : UILabel!
    @IBOutlet var lblProductOption : UILabel!
    @IBOutlet weak var myLblPaymentType: UILabel!
    @IBOutlet var lblLine : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
