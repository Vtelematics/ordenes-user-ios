//
//  ProductTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 08/07/22.
//

import UIKit

class ProductTblCell: UITableViewCell {

    @IBOutlet var lblHeader : UILabel!
    @IBOutlet var lblRestaurantName : UILabel!
    @IBOutlet var lblCuisines : UILabel!
    @IBOutlet var lblRating : UILabel!
    @IBOutlet var imgRating : UIImageView!
    @IBOutlet var viewInfo : UIView!
    @IBOutlet var viewReviews : UIView!
    @IBOutlet var viewDeliveryInfo : UIView!
    @IBOutlet var lblDeliveryDetails : UILabel!
    @IBOutlet var imgDeliveryIcon : UIImageView!
    
    @IBOutlet var imgProduct : UIImageView!
    @IBOutlet var lblProductName : UILabel!
    @IBOutlet var lblProductDesc : UILabel!
    @IBOutlet var lblPrice : UILabel!
    @IBOutlet var imgAdd : UIImageView!
    @IBOutlet var viewBg : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if self.viewBg != nil{
            //self.viewBg.dropShadow(cornerRadius: 12, opacity: 0.2, radius: 8)
            self.imgProduct.clipsToBounds = true
            self.imgProduct.layer.cornerRadius = 12
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
