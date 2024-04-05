//
//  CartNoteTblCell.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 22/07/22.
//

import UIKit

class CartNoteTblCell: UITableViewCell {
    
    @IBOutlet weak var mybtnClear: UIButton!
    @IBOutlet weak var myTxtNote: UITextField!
    @IBOutlet weak var myLblAdditionalReq: UILabel!
    @IBOutlet weak var myLblAddNote: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.myTxtNote.textAlignment = isRTLenabled == true ? .right : .left
        self.myLblAdditionalReq.text = NSLocalizedString("Additional request", comment: "")
        self.myLblAddNote.text = NSLocalizedString("Add note", comment: "")
        self.mybtnClear.setTitle(NSLocalizedString("Clear", comment: ""), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
