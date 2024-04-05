//
//  GroceryCategoryVc.swift
//  Talabat clone
//
//  Created by Adyas infotech on 24/08/22.
//

import UIKit

class GroceryCategoryVc: UIViewController {

    @IBOutlet var myCollCategory: UICollectionView!
    public var completion: ((GroceryCategoryModel) -> (Void))?
    var categoryModel = [GroceryCategoryModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI(){
        self.myCollCategory.register(UINib(nibName: "GroceryCategoryCollCell", bundle: nil), forCellWithReuseIdentifier: "groceryCategoryCell")
        self.myCollCategory.dataSource = self
        self.myCollCategory.delegate = self
        self.myCollCategory.reloadData()
    }
    
    //MARK: Button action
    @IBAction func clickBack(_ sender : Any){
        self.dismiss(animated: true)
    }
}


extension GroceryCategoryVc: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groceryCategoryCell", for: indexPath) as! GroceryCategoryCollCell
        cell.myLblCategory.text = self.categoryModel[indexPath.row].name
        let imageUrl = self.categoryModel[indexPath.row].picture
        let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""
        var activityLoader = UIActivityIndicatorView()
        activityLoader = UIActivityIndicatorView(style: .medium)
        activityLoader.center = cell.myImgCategory.center
        activityLoader.startAnimating()
        cell.myImgCategory.addSubview(activityLoader)
        cell.myImgCategory.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in
            if image != nil
            {
                activityLoader.stopAnimating()
            }
            else
            {
                print("image not found")
                cell.myImgCategory.image = UIImage(named: "no_image")
                activityLoader.stopAnimating()
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var categoryData = self.categoryModel[indexPath.row]
        categoryData.selectedCategory = indexPath.row
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(categoryData)
        })
    }
}

extension GroceryCategoryVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width / 4) - 20
        return CGSize(width: width, height: width + 30)
    }
}
