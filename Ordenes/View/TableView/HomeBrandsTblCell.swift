//
//  HomeBrandsCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 16/06/22.
//

import UIKit

class HomeBrandsTblCell: UITableViewCell {

    @IBOutlet var collBrands: UICollectionView!
    @IBOutlet var lblTitle : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collBrands.register(UINib(nibName: "HomeBrandsCollCell", bundle: nil), forCellWithReuseIdentifier: "brandsCollCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
