//
//  CheckoutTblCell.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 25/07/22.
//

import UIKit

class CheckoutTblCell: UITableViewCell {

    @IBOutlet weak var myLblHeader: UILabel!
    @IBOutlet weak var myLblTotalAmtTitle: UILabel!
    @IBOutlet weak var myLblTotalAmtValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
