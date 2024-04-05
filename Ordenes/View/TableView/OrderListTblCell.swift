//
//  OrderListTblCell.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 18/08/22.
//

import UIKit

class OrderListTblCell: UITableViewCell {
    
    @IBOutlet weak var myLblRestaurantName: UILabel!
    @IBOutlet weak var myLblOrderStatus: UILabel!
    @IBOutlet weak var myLblOrderDate: UILabel!
    @IBOutlet weak var myLblOrderID: UILabel!
    @IBOutlet weak var myLblOrderType: UILabel!
    @IBOutlet weak var myImgRestaurant: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
