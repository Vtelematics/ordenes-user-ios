//
//  ProductDetailTableViewCell.swift
//  Foodco
//
//  Created by Exlcart Solutions on 30/08/21.
//  Copyright © 2021 Adyas Iinfotech. All rights reserved.
//

import UIKit

class ProductDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductDes: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblStrikePrice: UILabel!
    @IBOutlet weak var imgCheckBox: UIImageView!
    @IBOutlet weak var lblOption: UILabel!

    @IBOutlet weak var lblSectionTitle: UILabel!
    @IBOutlet weak var lblMin: UILabel!
    @IBOutlet weak var btnIncrease: UIButton!
    @IBOutlet weak var btnDecrease: UIButton!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var viewQuantity: UIView!
    
    //Product Category Tableview cell
    @IBOutlet weak var lblCategoryTitle: UILabel!
    @IBOutlet weak var lblProductCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if self.viewQuantity != nil {
            self.viewQuantity.dropShadow(cornerRadius: 10, opacity: 0.2, radius: 8)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
