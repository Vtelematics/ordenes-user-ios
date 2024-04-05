//
//  CartProductWithOptionTblCell.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 22/07/22.
//

import UIKit

class CartProductWithOptionTblCell: UITableViewCell {
    
    @IBOutlet weak var myImgProduct: UIImageView!
    @IBOutlet weak var myLblTitle: UILabel!
    @IBOutlet weak var myLblOptions: UILabel!
    @IBOutlet weak var myLblPrice: UILabel!
    @IBOutlet weak var myLblOutofStock: UILabel!
    @IBOutlet weak var mylblQuantity: UILabel!
    @IBOutlet weak var myBtnIncrease: UIButton!
    @IBOutlet weak var myBtnDecrease: UIButton!
    @IBOutlet weak var myViewIncDec: UIView!
    @IBOutlet weak var myImgIncrease: UIImageView!
    @IBOutlet weak var myImgDecrease: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.myImgProduct.layer.cornerRadius = 8
        HELPER.changeTintColor(imgVw: self.myImgDecrease, img: "ic_minus", color: ConfigTheme.themeColor)
        HELPER.changeTintColor(imgVw: self.myImgIncrease, img: "ic_plus", color: ConfigTheme.themeColor)
        self.myLblOutofStock.text = NSLocalizedString("Out of stock", comment: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
