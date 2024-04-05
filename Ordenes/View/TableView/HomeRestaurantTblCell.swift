//
//  HomeRestaurantTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 16/06/22.
//

import UIKit

class HomeRestaurantTblCell: UITableViewCell {

    @IBOutlet var collRestaurants: UICollectionView!
    @IBOutlet var lblTitle : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collRestaurants.register(UINib(nibName: "HomeRestaurantCollCell", bundle: nil), forCellWithReuseIdentifier: "restaurantCollCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
