//
//  HomeRestaurantCollCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 17/06/22.
//

import UIKit

class HomeRestaurantCollCell: UICollectionViewCell {
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblRestaurantName: UILabel!
    @IBOutlet var lblDeliveryTime: UILabel!
    @IBOutlet var lblRestaurantDesc: UILabel!
    @IBOutlet var lblRating: UILabel!
    @IBOutlet var imgRating: UIImageView!
    @IBOutlet var lblDeliveryCharge: UILabel!
    @IBOutlet var lblOffers: UILabel!
    @IBOutlet var imgDeliveryTime: UIImageView!
    @IBOutlet var imgDeliveryCharge: UIImageView!
    @IBOutlet var imgOfferAlert: UIImageView!
    @IBOutlet var viewBusy : UIView!
    @IBOutlet var lblRestaurantStatus : UILabel!
    @IBOutlet var viewSeparater: UIView!
    @IBOutlet var viewPickup: UIView!
    @IBOutlet var lblRating2: UILabel!
    @IBOutlet var imgRating2: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblDeliveryTime.textColor = ConfigTheme.customLightGray
        self.lblRestaurantDesc.textColor = ConfigTheme.customLightGray
        self.lblOffers.textColor = ConfigTheme.customLightGreen
        self.imgView.layer.cornerRadius = 8
        self.viewBusy.layer.cornerRadius = 8
        HELPER.changeTintColor(imgVw: imgDeliveryTime, img: "ic_clock", color: ConfigTheme.customLightGray)
        HELPER.changeTintColor(imgVw: imgDeliveryCharge, img: "ic_deliverycost", color: ConfigTheme.themeColor)
        HELPER.changeTintColor(imgVw: imgOfferAlert, img: "ic_alert_clock", color: ConfigTheme.customLightGreen)
    }
}
