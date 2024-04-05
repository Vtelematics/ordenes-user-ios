//
//  GroceryCategoryCollCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 24/08/22.
//

import UIKit

class GroceryCategoryCollCell: UICollectionViewCell {

    @IBOutlet var myViewBg: UIView!
    @IBOutlet var myImgCategory: UIImageView!
    @IBOutlet var myImgCategoryMore: UIImageView!
    @IBOutlet var myLblCategory: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.myViewBg.dropShadow(cornerRadius: 5, opacity: 0.2, radius: 8)
        self.myImgCategory.layer.cornerRadius = 5
    }
}
