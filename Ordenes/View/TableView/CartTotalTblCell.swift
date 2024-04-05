//
//  CartTotalTblCell.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 22/07/22.
//

import UIKit

class CartTotalTblCell: UITableViewCell {
    @IBOutlet weak var myLblPriceType: UILabel!
    @IBOutlet weak var myLblTotalPrice: UILabel!
    @IBOutlet weak var myLblCurrency: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.myLblTotalPrice.textAlignment = isRTLenabled == true ? .left : .right
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
