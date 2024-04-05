//
//  HomeBrandsCollCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 20/06/22.
//

import UIKit

class HomeBrandsCollCell: UICollectionViewCell {
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblBrandName: UILabel!
    @IBOutlet var lblDeliveryTime: UILabel!
    @IBOutlet var viewBusy : UIView!
    @IBOutlet var lblRestaurantStatus : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgView.layer.borderColor = ConfigTheme.customLightGray.cgColor
        self.imgView.layer.borderWidth = 0.6
        self.imgView.layer.cornerRadius = 8
        self.lblDeliveryTime.textColor = ConfigTheme.customLightGray
        self.viewBusy.layer.cornerRadius = 8
    }

}
