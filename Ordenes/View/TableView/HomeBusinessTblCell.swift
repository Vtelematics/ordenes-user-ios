//
//  HomeCategoryTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 16/06/22.
//

import UIKit

class HomeBusinessTblCell: UITableViewCell {

    @IBOutlet var lblGreeting: UILabel!
    @IBOutlet var collBusinessType: UICollectionView!
    @IBOutlet var viewPickup: UIView!
    @IBOutlet var viewDelivery: UIView!
    @IBOutlet var lblPickup: UILabel!
    @IBOutlet var lblDelivery: UILabel!
    @IBOutlet var lblPickupGreeting: UILabel!
    @IBOutlet var lblDeliveryGreeting: UILabel!
    @IBOutlet var viewOrderType: UIView!
    @IBOutlet var btnDelivey: UIButton!
    @IBOutlet var btnPickup: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collBusinessType.register(UINib(nibName: "HomeBusinessCollCell", bundle: nil), forCellWithReuseIdentifier: "businessCollCell")
        self.viewPickup.dropShadow(cornerRadius: 5, opacity: 0.2, radius: 8)
        self.viewDelivery.dropShadow(cornerRadius: 5, opacity: 0.2, radius: 8)
        self.lblPickup.layer.cornerRadius = 8
        self.lblDelivery.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
