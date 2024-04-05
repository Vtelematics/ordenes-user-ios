//
//  CartWarningTableCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 29/08/22.
//

import UIKit

class CartWarningTableCell: UITableViewCell {

    @IBOutlet weak var myLblWarning: UILabel!
    @IBOutlet weak var myViewWarning: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
