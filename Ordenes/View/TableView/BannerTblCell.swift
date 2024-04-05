//
//  BannerTblCell.swift
//  Ordenes
//
//  Created by Adyas infotech on 05/11/22.
//

import UIKit

class BannerTblCell: UITableViewCell {

    @IBOutlet weak var myBtnPickup : UIButton!
    @IBOutlet weak var myImgBanner : UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
