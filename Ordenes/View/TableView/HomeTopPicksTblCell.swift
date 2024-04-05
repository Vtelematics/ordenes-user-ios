//
//  HomeTopPicksTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 16/06/22.
//

import UIKit

class HomeTopPicksTblCell: UITableViewCell {

    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var collTopPicks: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collTopPicks.register(UINib(nibName: "HomeTopPicksCollCell", bundle: nil), forCellWithReuseIdentifier: "topPicksCollCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
