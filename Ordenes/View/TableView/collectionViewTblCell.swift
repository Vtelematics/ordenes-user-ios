//
//  collectionViewTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 01/07/22.
//

import UIKit

class collectionViewTblCell: UITableViewCell {

    @IBOutlet var defaultCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.defaultCollectionView.register(UINib(nibName: "VendorSplFilterCollCell", bundle: nil), forCellWithReuseIdentifier: "vendorSplFilterCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
