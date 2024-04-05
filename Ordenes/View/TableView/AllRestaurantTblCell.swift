//
//  AllRestaurantTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 23/06/22.
//

import UIKit

class AllRestaurantTblCell: UITableViewCell {

    @IBOutlet var vwBg : UIView!
    @IBOutlet var imgRestaurant : UIImageView!
    @IBOutlet var lblRestaurantName : UILabel!
    @IBOutlet var lblRestaurantDesc : UILabel!
    @IBOutlet var imgRating : UIImageView!
    @IBOutlet var viewRating : UIView!
    @IBOutlet var lblMinOrder : UILabel!
    @IBOutlet var imgMinOrder : UIImageView!
    @IBOutlet var lblRestaurantRating : UILabel!
    @IBOutlet var lblRestaurantDeliveryCharge : UILabel!
    @IBOutlet var imgRestaurantDeliveryCharge : UIImageView!
    @IBOutlet var lblRestaurantDeliveryTime : UILabel!
    @IBOutlet var imgRestaurantDeliveryTime : UIImageView!
    @IBOutlet var viewBusy1 : UIView!
    @IBOutlet var lblRestaurantStatus1 : UILabel!
    @IBOutlet var imgOffer : UIImageView!
    @IBOutlet var lblRestaurantOffer : UILabel!
    @IBOutlet var lblLine : UILabel!
    @IBOutlet var viewPreparing : UIView!
    @IBOutlet var lblRestaurantPreparingTime : UILabel!
    @IBOutlet var imgRestaurantPreparingTime : UIImageView!
    @IBOutlet var imgFav : UIImageView!
    @IBOutlet var btnFav : UIButton!
    @IBOutlet var btnSelect : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vwBg.dropShadow(cornerRadius: 8, opacity: 0.2, radius: 8)
        lblRestaurantDesc.textColor = ConfigTheme.customLightGray
        lblRestaurantRating.textColor = ConfigTheme.customLightGray
        lblMinOrder.textColor = ConfigTheme.customLightGray
        lblRestaurantDeliveryCharge.textColor = ConfigTheme.customLightGray
        lblRestaurantDeliveryTime.textColor = ConfigTheme.customLightGray
        lblRestaurantPreparingTime.textColor = ConfigTheme.customLightGray
        HELPER.changeTintColor(imgVw: imgRestaurantDeliveryCharge, img: "ic_deliverycost", color: ConfigTheme.themeColor)
        HELPER.changeTintColor(imgVw: imgRestaurantDeliveryTime, img: "ic_clock", color: ConfigTheme.customLightGray)
        HELPER.changeTintColor(imgVw: imgRestaurantPreparingTime, img: "ic_clock", color: ConfigTheme.customLightGray)
        HELPER.changeTintColor(imgVw: imgMinOrder, img: "ic_wallet_2", color: ConfigTheme.customLightGray)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
