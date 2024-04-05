//
//  OrderTypeTblCell.swift
//  Ordenes
//
//  Created by Adyas infotech on 04/11/22.
//

import UIKit

class OrderTypeTblCell: UITableViewCell {

    @IBOutlet weak var mySegmentController: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if #available(iOS 13.0, *) {
            let titleTextAttributesSelect: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 15.0) ?? "",
                NSAttributedString.Key.foregroundColor: UIColor.white,
            ]
            let titleTextAttributesNormal: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 15.0) ?? "",
                NSAttributedString.Key.foregroundColor: UIColor.black,
            ]
            mySegmentController.setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
            mySegmentController.setTitleTextAttributes(titleTextAttributesSelect, for: .selected)
            self.mySegmentController.tintColor = ConfigTheme.posBtnColor
            self.mySegmentController.selectedSegmentTintColor = ConfigTheme.posBtnColor
        } else {
            self.mySegmentController.tintColor = ConfigTheme.posBtnColor
        }
        self.mySegmentController.frame.size.height = 50
        self.mySegmentController.translatesAutoresizingMaskIntoConstraints = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
