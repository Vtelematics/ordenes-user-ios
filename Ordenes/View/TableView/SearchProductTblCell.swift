//
//  SearchProductTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 26/08/22.
//

import UIKit

class SearchProductTblCell: UITableViewCell {

    @IBOutlet var imgProduct : UIImageView!
    @IBOutlet var lblProductName : UILabel!
    @IBOutlet var lblProductDesc : UILabel!
    @IBOutlet var lblPrice : UILabel!
    @IBOutlet var lblQuantity : UILabel!
    @IBOutlet var imgDec : UIImageView!
    @IBOutlet var imgInc : UIImageView!
    @IBOutlet var btnDec : UIButton!
    @IBOutlet var btnInc : UIButton!
    @IBOutlet var viewAdd1 : UIView!
    @IBOutlet var viewAdd2 : UIView!
    @IBOutlet var viewBusy : UIView!
    @IBOutlet var lblStatus : UILabel!
    @IBOutlet var imgAdd : UIImageView!
    @IBOutlet var btnAdd : UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgDec.image = self.imgDec.image!.withRenderingMode(.alwaysTemplate)
        self.imgDec.tintColor = ConfigTheme.themeColor
        self.imgInc.image = self.imgInc.image!.withRenderingMode(.alwaysTemplate)
        self.imgInc.tintColor = ConfigTheme.themeColor
        self.imgAdd.image = self.imgAdd.image!.withRenderingMode(.alwaysTemplate)
        self.imgAdd.tintColor = ConfigTheme.themeColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
