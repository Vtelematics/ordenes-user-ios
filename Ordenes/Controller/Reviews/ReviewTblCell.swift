//
//  ReviewTblCell.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 29/08/22.
//

import UIKit
//import FloatRatingView

class ReviewTblCell: UITableViewCell {
    @IBOutlet weak var myImgVendor: UIImageView!
    @IBOutlet weak var myLblReviewCount: UILabel!
    @IBOutlet weak var myLblBasedOn: UILabel!
    @IBOutlet weak var myLblReviewCategory: UILabel!
    @IBOutlet weak var myLblReviewCategoryCount: UILabel!
    @IBOutlet weak var myViewRating: FloatRatingView?
    @IBOutlet weak var myLblReviewRating: UILabel!
    @IBOutlet weak var myLblReview: UILabel!
    @IBOutlet weak var myLblReviewDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        myViewRating?.emptyImage = UIImage(named: "ic_starEmpty")
        myViewRating?.fullImage = UIImage(named: "ic_starFull")
        myViewRating?.minRating = 0
        myViewRating?.maxRating = 5
        myViewRating?.rating = 0
        myViewRating?.halfRatings = true
        myViewRating?.editable = false
        if !isRTLenabled{
            self.myViewRating?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
