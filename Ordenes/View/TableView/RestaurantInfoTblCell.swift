//
//  RestaurantInfoTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 16/07/22.
//

import UIKit

class RestaurantInfoTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var imgPayment1: UIImageView!
    @IBOutlet weak var imgPayment2: UIImageView!
    @IBOutlet weak var imgPayment3: UIImageView!
    @IBOutlet weak var imgPayment4: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if self.lblValue != nil{
            self.lblValue.textAlignment = isRTLenabled == true ? .left : .right
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
