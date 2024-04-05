//
//  AddressTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 06/08/22.
//

import UIKit

class AddressTblCell: UITableViewCell {

    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblAddress : UILabel!
    @IBOutlet var lblStreet : UILabel!
    @IBOutlet var lblMobile : UILabel!
    @IBOutlet var btnEdit : UIButton!
    @IBOutlet var btnDelete : UIButton!
    @IBOutlet var imgEdit : UIImageView!
    @IBOutlet var imgDelete : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgEdit.image = self.imgEdit.image!.withRenderingMode(.alwaysTemplate)
        self.imgEdit.tintColor = ConfigTheme.themeColor
        self.imgDelete.image = self.imgDelete.image!.withRenderingMode(.alwaysTemplate)
        self.imgDelete.tintColor = ConfigTheme.themeColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
