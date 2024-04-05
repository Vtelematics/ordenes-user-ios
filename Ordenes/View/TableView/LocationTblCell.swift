//
//  LocationTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 02/09/22.
//

import UIKit

class LocationTblCell: UITableViewCell {

    @IBOutlet weak var lblAddress1: UILabel!
    @IBOutlet weak var lblAddress2: UILabel!
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var imgBanner: UIImageView!
    @IBOutlet weak var btnAddressSelection: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
