//
//  multiSelectionCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 06/07/22.
//

import UIKit

class multiSelectionCell: UITableViewCell {

    @IBOutlet var lblHeader: UILabel!
    @IBOutlet var lblSelectionTitle: UILabel!
    @IBOutlet var imgSelection: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
