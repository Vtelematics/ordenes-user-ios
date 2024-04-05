//
//  VendorSplFilterCollCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 01/07/22.
//

import UIKit

class VendorSplFilterCollCell: UICollectionViewCell {

    @IBOutlet var viewBg: UIView!
    @IBOutlet var lblFilterName: UILabel!
    @IBOutlet var imgFilter: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.viewBg.backgroundColor = ConfigTheme.themeColor
        self.viewBg.layer.cornerRadius = 8
        // Initialization code
    }

}
