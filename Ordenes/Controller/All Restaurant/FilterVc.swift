
import UIKit

class FilterVc: UIViewController {

    @IBOutlet var myTblFilters: UITableView!
    @IBOutlet var myLblApply: UILabel!
    @IBOutlet var myLblFilterCount: UILabel!
    
    var selectedFilters : [[String: Any]] = []
    public var completion : (([[String: Any]]) -> (Void))?
    public var completionTemp : (([FilterListModel]) -> (Void))?
    var filtersModel  = [FilterListModel]()
    var filter = [FilterListModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        self.myTblFilters.tableFooterView = UIView()
        self.myTblFilters.delegate = self
        self.myTblFilters.dataSource = self
        self.myTblFilters.reloadData()
        self.myTblFilters.register(UINib(nibName: "multiSelectionCell", bundle: nil), forCellReuseIdentifier: "selectionCell")
        setApplyBtn()
        callGetFilters()
    }
//
//    [Talabat_clone.FilterListModel(filterID: Optional("1"), name: Optional("Popular Filter"), type: Optional("2"), status: Optional("1"), filterType: Optional([Talabat_clone.FilterTypeModel(filterTypeID: Optional("1"), name: Optional("Fast Delivery"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("2"), name: Optional("Free Delivery"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("3"), name: Optional("Top Rated"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("4"), name: Optional("No Minimum Order"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("5"), name: Optional("Newly added"), status: Optional("1"))]), selectedtoAdd: Optional([Talabat_clone.FilterTypeModel(filterTypeID: Optional("1"), name: Optional("Fast Delivery"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("2"), name: Optional("Free Delivery"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("3"), name: Optional("Top Rated"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("5"), name: Optional("Newly added"), status: Optional("1"))]), selectedFilters: [0, 1, 2, 4]), Talabat_clone.FilterListModel(filterID: Optional("2"), name: Optional("Deals and Offers"), type: Optional("2"), status: Optional("1"), filterType: Optional([Talabat_clone.FilterTypeModel(filterTypeID: Optional("6"), name: Optional("Open Outlets"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("8"), name: Optional("Offers"), status: Optional("1"))]), selectedtoAdd: Optional([Talabat_clone.FilterTypeModel(filterTypeID: Optional("6"), name: Optional("Open Outlets"), status: Optional("1"))]), selectedFilters: [0]), Talabat_clone.FilterListModel(filterID: Optional("3"), name: Optional("Sort By"), type: Optional("1"), status: Optional("1"), filterType: Optional([Talabat_clone.FilterTypeModel(filterTypeID: Optional("9"), name: Optional("A to Z"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("10"), name: Optional("Min Order Amount"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("11"), name: Optional("Rating"), status: Optional("1"))]), selectedtoAdd: Optional([Talabat_clone.FilterTypeModel(filterTypeID: Optional("9"), name: Optional("A to Z"), status: Optional("1"))]), selectedFilters: [0])]
    
    func setApplyBtn(){
        var filterCount = 0
        if filtersModel.count != 0{
            let arrOfDict = (filtersModel.map { $0.getSelectedValues() })
            print(arrOfDict)
            (arrOfDict.flatMap { $0 }).forEach { (arg) in
                let (_, value) = arg
                if value.count>0 {
                    filterCount = filterCount + value.count
                }
            }
        }
        
        if filterCount != 0{
            self.myLblApply.frame.origin.y = 8
            self.myLblFilterCount.isHidden = false
            self.myLblFilterCount.text = "\(filterCount) \(NSLocalizedString("filters selected", comment: ""))"
        }else{
            self.myLblApply.frame.origin.y = 15
            self.myLblFilterCount.isHidden = true
        }
    }
    
    //MARK: API Calls
    func callGetFilters() {
        var aDictParameters = [String : Any]()
        aDictParameters[K_PARAMS_LANGUAGE_ID] = languageID
        aDictParameters[K_PARAMS_ORDER_TYPE] = orderType
        HELPER.showLoadingAnimationWithTitle(aViewController: self, aStrText: "Please wait..")
        HTTPMANAGER.callPostApiUsingEncryption(strCase: CASE_GET_FILTERS, isAuthorize: true, dictParameters: aDictParameters, aController: self, sucessBlock: { (response) in
           do {
                let aDictInfo = response as! [String : Any]
                if aDictInfo.count != 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: aDictInfo, options: .prettyPrinted)
                    let modelData = try! JSONDecoder().decode(FilterModel.self, from: jsonData)
                    self.filtersModel = modelData.filterList ?? []
                    for i in 0..<self.filtersModel.count{
                        let id1 = self.filtersModel[i].filterID
                        for j in 0..<self.filter.count{
                            if let id2 = self.filter[j].filterID{
                                if id1 == id2{
                                    let selectedFilters = self.filter[j].selectedFilters
                                    self.filtersModel[i].selectedFilters = selectedFilters
                                    let selectedtoAdd = self.filter[j].selectedtoAdd
                                    self.filtersModel[i].selectedtoAdd = selectedtoAdd
                                }
                            }
                        }
                    }
                } else {
                    HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: ALERT_TYPE_FILTER_MODULE_EMPTY)
                }
                self.myTblFilters.dataSource = self
                self.myTblFilters.delegate = self
                self.myTblFilters.reloadData()
            } catch {
                print(error.localizedDescription)
            }
            HELPER.hideLoadingAnimation()
        }, failureBlock: { (errorResponse) in
            HELPER.hideLoadingAnimation()

            HELPER.showDefaultAlertViewController(aViewController: self, alertTitle: NSLocalizedString("Sorry", comment: ""), aStrMessage: errorResponse)
        })
    }
    
    //MARK: Button Action
    @IBAction func clickApply(_ sender: Any) {
        if filtersModel.count != 0{
            selectedFilters = []
            for filtersModel in filtersModel {
                var filterObj = [String: Any]()
                let selected = filtersModel.selectedtoAdd
                var filterValues:[String]  = []
                for selectedObj in selected ?? []{
                    let id = selectedObj.filterTypeID ?? ""
                    filterValues.append(id)
                }
                if filterValues.count != 0{
                    filterObj["filter_id"] = filtersModel.filterID
                    filterObj["filter_value"] = filterValues
                    selectedFilters.append(filterObj)
                }
            }
            dismiss(animated: true, completion: { [weak self] in
                self?.completion?(self?.selectedFilters ?? [])
                self?.completionTemp?(self?.filtersModel ?? [])
            })
        }
    }
    
    @IBAction func clickClearAll(_ sender: Any) {
        for i in 0..<filtersModel.count {
            filtersModel[i].selectedFilters.removeAll()
            filtersModel[i].selectedtoAdd.removeAll()
        }
        setApplyBtn()
        self.myTblFilters.reloadData()
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension FilterVc : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filtersModel.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "filterHeaderCell") as! multiSelectionCell
        headerCell.lblHeader.text = filtersModel[section].name
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtersModel[section].filterType?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectionCell", for: indexPath) as! multiSelectionCell
        cell.lblSelectionTitle.text = filtersModel[indexPath.section].filterType?[indexPath.row].name
        cell.imgSelection.image = UIImage(named: "ic_uncheck")
        
        if filtersModel[indexPath.section].type == "2"
        {
            //Checkbox
            if (filtersModel[indexPath.section].selectedFilters.contains(indexPath.row))
            {
                HELPER.changeTintColor(imgVw: cell.imgSelection, img: "ic_checkbox", color: ConfigTheme.themeColor)
            }
            else
            {
                HELPER.changeTintColor(imgVw: cell.imgSelection, img: "ic_uncheck", color: ConfigTheme.themeColor)
            }
        }
        else
        {
            // Radio button
            if (filtersModel[indexPath.section].selectedFilters.contains(indexPath.row))
            {
                HELPER.changeTintColor(imgVw: cell.imgSelection, img: "ic_radio_check", color: ConfigTheme.themeColor)
            }
            else
            {
                HELPER.changeTintColor(imgVw: cell.imgSelection, img: "ic_radio_uncheck", color: ConfigTheme.themeColor)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let selected = filtersModel[indexPath.section].filterType?[indexPath.row].filterTypeID
        
        if (filtersModel[indexPath.section].selectedFilters.contains(indexPath.row))
        {
            filtersModel[indexPath.section].selectedFilters.remove(at: filtersModel[indexPath.section].selectedFilters.firstIndex(of: indexPath.row) ?? 0)
            //filtersModel[indexPath.section].selectedName.remove(at: filtersModel[indexPath.section].selectedName.firstIndex(of: selected!)!)
            let id = filtersModel[indexPath.section].filterType?[indexPath.row].filterTypeID
            for i in 0..<(filtersModel[indexPath.section].selectedtoAdd.count){
                let selected = filtersModel[indexPath.section].selectedtoAdd[i].filterTypeID
                if id == selected{
                    filtersModel[indexPath.section].selectedtoAdd.remove(at: i)
                    break
                }
            }
        }
        else
        {
            if filtersModel[indexPath.section].type == "1"
            {
                filtersModel[indexPath.section].selectedtoAdd.removeAll()
            }
            filtersModel[indexPath.section].selectedFilters.append(indexPath.row)
            let values = (filtersModel[indexPath.section].filterType?[indexPath.row])
            filtersModel[indexPath.section].selectedtoAdd.append(values!)
        }
        setApplyBtn()
        self.myTblFilters.reloadData()
    }
}

//(filterID: Optional("1"), name: Optional("Popular Filter"), type: Optional("2"), status: Optional("1"), filterType: Optional([Talabat_clone.FilterTypeModel(filterTypeID: Optional("1"), name: Optional("Fast Delivery"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("2"), name: Optional("Free Delivery"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("3"), name: Optional("Top Rated"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("4"), name: Optional("No Minimum Order"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("5"), name: Optional("Newly added"), status: Optional("1"))]), selectedtoAdd: Optional([Talabat_clone.FilterTypeModel(filterTypeID: Optional("1"), name: Optional("Fast Delivery"), status: Optional("1")), Talabat_clone.FilterTypeModel(filterTypeID: Optional("2"), name: Optional("Free Delivery"), status: Optional("1"))]), selectedFilters: [0, 1])
/*(
{
    "filter_id" = 1;
    "filter_type" =     (
                {
            "filter_type_id" = 1;
            name = "Fast Delivery";
            status = 1;
        },
                {
            "filter_type_id" = 2;
            name = "Free Delivery";
            status = 1;
        },
                {
            "filter_type_id" = 3;
            name = "Top Rated";
            status = 1;
        },
                {
            "filter_type_id" = 4;
            name = "No Minimum Order";
            status = 1;
        },
                {
            "filter_type_id" = 5;
            name = "Newly added";
            status = 1;
        }
    );
    name = "Popular Filter";
    status = 1;
    type = 2;
},
{
    "filter_id" = 2;
    "filter_type" =     (
                {
            "filter_type_id" = 6;
            name = "Open Outlets";
            status = 1;
        },
                {
            "filter_type_id" = 8;
            name = Offers;
            status = 1;
        }
    );
    name = "Deals and Offers";
    status = 1;
    type = 2;
},
{
    "filter_id" = 3;
    "filter_type" =     (
                {
            "filter_type_id" = 9;
            name = "A to Z";
            status = 1;
        },
                {
            "filter_type_id" = 10;
            name = "Min Order Amount";
            status = 1;
        },
                {
            "filter_type_id" = 11;
            name = Rating;
            status = 1;
        }
    );
    name = "Sort By";
    status = 1;
    type = 1;
}
)*/
