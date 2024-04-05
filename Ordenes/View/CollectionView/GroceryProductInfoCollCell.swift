//
//  GroceryProductInfoCollCell.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 25/08/22.
//

import UIKit

class GroceryProductInfoCollCell: UICollectionViewCell {
    @IBOutlet weak var myImgProduct: UIImageView!
    @IBOutlet weak var mylblProductTitle: UILabel!
    @IBOutlet weak var mylblProductPrice: UILabel!
    @IBOutlet weak var mylblQuantity1: UILabel!
    @IBOutlet weak var mylblQuantity2: UILabel!
    @IBOutlet weak var myViewCart1: UIView!
    @IBOutlet weak var myViewCart2: UIView!
    @IBOutlet weak var myBtnInc: UIButton!
    @IBOutlet weak var myBtnDec: UIButton!
    @IBOutlet weak var myImgInc: UIImageView!
    @IBOutlet weak var myImgDec: UIImageView!
    @IBOutlet weak var myImgAdd: UIImageView!
    @IBOutlet weak var myBtnAdd: UIButton!
    @IBOutlet weak var myViewBg: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        self.myImgInc.image = UIImage(named: "ic_plus")
        self.myImgInc.image = self.myImgInc.image!.withRenderingMode(.alwaysTemplate)
        self.myImgInc.tintColor = ConfigTheme.themeColor
        self.myImgAdd.image = UIImage(named: "ic_plus")
        self.myImgAdd.image = self.myImgAdd.image!.withRenderingMode(.alwaysTemplate)
        self.myImgAdd.tintColor = ConfigTheme.themeColor
        self.myViewCart1.dropShadow(cornerRadius: 10, opacity: 0.2, radius: 8)
        self.myViewCart2.dropShadow(cornerRadius: 10, opacity: 0.2, radius: 8)
        self.myViewBg.dropShadow(cornerRadius: 10, opacity: 0.1, radius: 6)
    }
}
