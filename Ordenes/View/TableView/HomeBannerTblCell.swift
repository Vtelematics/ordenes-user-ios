//
//  HomeBannerTblCell.swift
//  Talabat clone
//
//  Created by Adyas infotech on 16/06/22.
//

import UIKit
import FSPagerView

class HomeBannerTblCell: UITableViewCell {
    var bannerModel = [Banner]()
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet weak var pagerView: FSPagerView!
        {
        didSet {
            pagerView.dataSource = self
            pagerView.delegate = self
            pagerView.automaticSlidingInterval = 3
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.itemSize = .zero
        }
    }
    
    @IBOutlet weak var pagerControl: FSPageControl!
    {
        didSet
        {
            self.pagerControl.numberOfPages = self.bannerModel.count
            self.pagerControl.contentHorizontalAlignment = .center
            self.pagerControl.backgroundColor = .clear
            self.pagerControl.setFillColor(ConfigTheme.themeColor, for: .selected)
            self.pagerControl.currentPage = 0
            self.pagerControl.setStrokeColor(ConfigTheme.themeColor, for: .normal)
            self.pagerControl.setStrokeColor(.white, for: .selected)
            self.pagerControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension HomeBannerTblCell : FSPagerViewDataSource, FSPagerViewDelegate{
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int
    {
        return bannerModel.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell
    {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        let imageUrl = bannerModel[index].banner
        
        let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
        
        var activityLoader = UIActivityIndicatorView()
        activityLoader = UIActivityIndicatorView(style: .medium)
        activityLoader.center = cell.center
        activityLoader.startAnimating()
        cell.imageView?.addSubview(activityLoader)
                
        cell.imageView?.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
            
            if image != nil
            {
                activityLoader.stopAnimating()
            }else
            {
                print("image not found")
                cell.imageView?.image = UIImage(named: "no_image")
                activityLoader.stopAnimating()
            }
        })
        
        cell.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        
        return cell
    }    
    
    func pagerViewDidScroll(_ pagerView: FSPagerView)
    {
        guard self.pagerControl.currentPage != pagerView.currentIndex else
        {
            return
        }
        self.pagerControl.currentPage = pagerView.currentIndex
        self.pagerControl.currentPage = pagerView.currentIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int)
    {
        let data = bannerModel[index]
        NotificationCenter.default.post(name: .restaurantNavigation, object: data)
    }
}
