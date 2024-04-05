//
//  MenuTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 27/07/22.
//

import UIKit

class MenuTblCell: UITableViewCell {

    // MenuListTblCell - this is used for menu and language selection
    @IBOutlet weak var myLblUser: UILabel!
    @IBOutlet weak var myImgUser: UIImageView!
    @IBOutlet weak var myLblViewAccount: UILabel!
    @IBOutlet weak var myBtnViewAccount: UIButton!
    @IBOutlet weak var myLblMenuTitle: UILabel!
    @IBOutlet weak var myImgMenu: UIImageView!
    @IBOutlet weak var myLblLine: UILabel!
    @IBOutlet weak var myLblAppVersion: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if myLblViewAccount != nil{
            self.myLblViewAccount.text = NSLocalizedString("View Account", comment: "")
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
