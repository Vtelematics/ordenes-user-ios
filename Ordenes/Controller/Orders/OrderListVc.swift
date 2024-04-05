//
//  OrderListVc.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 18/08/22.
//

import UIKit

class OrderListVc: UIViewController {
    
    @IBOutlet weak var myTableOrderList: UITableView!
    @IBOutlet weak var myViewEmpty: UIView!
    
    var orderListModel = [Order]()
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "20"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callGetOrderListApi()
    }
    
    func setupUI() {
        self.myTableOrderList.register(UINib(nibName: "OrderListTblCell", bundle: nil), forCellReuseIdentifier: "orderListCell")
    }
    
    //MARK: Button Back action
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func callGetOrderListApi() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
        aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_ORDER_LIST, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
               print(response)
               let aDictInfo = response as! [String : Any]
               if aDictInfo.count != 0 {
                   let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                   let modelData = try! JSONDecoder().decode(OrderListModel.self, from: jsonData)
                   print(modelData)
                   self.orderListModel = modelData.orders ?? []
                   if self.orderListModel.count == 0{
                       self.myViewEmpty.isHidden = false
                   }else{
                       self.myViewEmpty.isHidden = true
                   }
                   if aDictInfo["error"] != nil{
                       let error = aDictInfo["error"] as! [String: String]
                       HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                   }
                   HELPER.hideLoadingAnimation()
               } else {
                   HELPER.hideLoadingAnimation()
                   HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_ORDER_MODULE_EMPTY)
               }
               self.myTableOrderList.dataSource = self
               self.myTableOrderList.delegate = self
               self.myTableOrderList.reloadData()
            } catch {
                HELPER.hideLoadingAnimation()
                print(error.localizedDescription)
            }
            
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()
            
            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView == myTableOrderList{
            let offset: CGPoint = scrollView.contentOffset
            let bounds: CGRect = scrollView.bounds
            let size: CGSize = scrollView.contentSize
            let inset: UIEdgeInsets = scrollView.contentInset
            let y = Float(offset.y + bounds.size.height - inset.bottom)
            let h = Float(size.height)
            let reload_distance: Float = 10
            if y > h + reload_distance
            {
                if isScrolledOnce == false
                {
                    self.pullToRefresh()
                }
            }
        }
    }
    
    func pullToRefresh()
    {
        if (self.isScrolledOnce == true)
        {
            return
        }
        self.isScrolledOnce = true
        if page <= Int(self.pageCount)
        {
            print("\(page) time loading")
            page += 1
            HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
            var aDictParameters = [String : Any]()
            aDictParameters[K_PARAMS_PAGE] = page
            aDictParameters[K_PARAMS_LIMIT] = limit
            aDictParameters[K_PARAMS_GUEST_STATUS] = guestStatus
            aDictParameters[K_PARAMS_GUEST_ID] = deviceTokenStr
            aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
            HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_POST_ORDER_LIST, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
               do {
                    let aDictInfo = response as! [String : Any]
                    if aDictInfo.count != 0 {
                        let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                        let modelData = try! JSONDecoder().decode(OrderListModel.self, from: jsonData)
                        self.orderListModel.append(contentsOf: modelData.orders ?? [])
                        self.myTableOrderList.reloadData()
                        if aDictInfo["error"] != nil{
                            let error = aDictInfo["error"] as! [String: String]
                            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: error["message"]!)
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                self.isScrolledOnce = false
                HELPER.hideLoadingAnimation()
            }, failureBlock: { (errorResponse) in
                self.isScrolledOnce = false
                HELPER.hideLoadingAnimation()
                HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
            })
        }
        else
        {
            self.isScrolledOnce = false
        }
    }
}

extension OrderListVc : UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderListModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderListCell", for: indexPath) as! OrderListTblCell
        
        cell.myLblRestaurantName.text = self.orderListModel[indexPath.row].vendorName
        cell.myLblOrderStatus.text = self.orderListModel[indexPath.row].status
        if isRTLenabled{
            cell.myLblOrderDate.text = (self.orderListModel[indexPath.row].orderedDate ?? "") + " :" + NSLocalizedString("Order Date", comment: "")
            cell.myLblOrderID.text = (self.orderListModel[indexPath.row].orderID ?? "") + " :" + NSLocalizedString("Order ID", comment: "")
            if let orderType = self.orderListModel[indexPath.row].orderType, orderType == "1"{
                cell.myLblOrderType.text = NSLocalizedString("Delivery", comment: "") + " :" +  NSLocalizedString("Order type", comment: "")
            }else{
                cell.myLblOrderType.text = NSLocalizedString("Pickup", comment: "") + " :" + NSLocalizedString("Order type", comment: "")
            }
        }else{
            cell.myLblOrderDate.text = NSLocalizedString("Order Date", comment: "") + ": " + (self.orderListModel[indexPath.row].orderedDate ?? "")
            cell.myLblOrderID.text = NSLocalizedString("Order ID", comment: "") + ": " + (self.orderListModel[indexPath.row].orderID ?? "")
            if let orderType = self.orderListModel[indexPath.row].orderType, orderType == "1"{
                cell.myLblOrderType.text =  NSLocalizedString("Order type", comment: "") + ": " + NSLocalizedString("Delivery", comment: "")
            }else{
                cell.myLblOrderType.text =  NSLocalizedString("Order type", comment: "") + ": " + NSLocalizedString("Pickup", comment: "")
            }
        }
       
        let imageUrl = self.orderListModel[indexPath.row].logo
        let trimmedUrl = imageUrl?.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") ?? ""

        var activityLoader = UIActivityIndicatorView()
        activityLoader = UIActivityIndicatorView(style: .medium)
        activityLoader.center = cell.myImgRestaurant.center
        activityLoader.startAnimating()
        cell.myImgRestaurant.addSubview(activityLoader)

        cell.myImgRestaurant.sd_setImage(with: URL(string: trimmedUrl), completed: { (image, error, imageCacheType, imageUrl) in

            if image != nil
            {
                activityLoader.stopAnimating()
            }
            else
            {
                print("image not found")
                cell.myImgRestaurant.image = UIImage(named: "no_image")
                activityLoader.stopAnimating()
            }
        })
        
        cell.myImgRestaurant.layer.borderWidth = 0.6
        cell.myImgRestaurant.layer.borderColor = ConfigTheme.customLightGray.cgColor
        cell.myImgRestaurant.layer.cornerRadius = 8
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let aViewController = UIStoryboard(.info).instantiateViewController(withIdentifier: OrderInfoVc.storyboardID) as! OrderInfoVc
        aViewController.orderId = self.orderListModel[indexPath.row].orderID ?? ""
        self.navigationController?.pushViewController(aViewController, animated: true)
    }
    
}
