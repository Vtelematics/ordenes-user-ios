import Foundation

// MARK: - Filter
struct FilterModel: Codable {
    var filterList: [FilterListModel]?
    let success: Success?
    enum CodingKeys: String, CodingKey {
        case filterList = "filter_list"
        case success
    }
}

// MARK: - FilterList
struct FilterListModel: Codable {
    let filterID, name, type, status: String?
    let filterType: [FilterTypeModel]?
    //var selectedName : [String] = []
    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case name, type, status
        case filterType = "filter_type"
    }
    
    var selectedtoAdd:[FilterTypeModel]! = []{
        didSet {
            if type == "1"
            {
                selectedtoAdd = Array(selectedtoAdd.suffix(1))
            }
            else if type == "2"
            {
                //selectedtoAdd = oldValue
            }
        }
    }
    
    var selectedFilters:[Int]  = [] {
        didSet {
            if type == "1"
            {
                selectedFilters = Array(selectedFilters.suffix(1))
            }
            else if type == "2"
            {
                //selectedFilters = oldValue
            }
        }
    }
    
    func getSelectedValues()->[String:AnyObject]
    {
        let test = selectedtoAdd.map { $0.filterTypeID }
        return [filterID ?? "0":test.sorted(by: { $0! < $1! }) as AnyObject]
//        if type == "1"
//        {
//            print(test.isEmpty ? [:] : [filterID ?? "0":test[0] as AnyObject])
//            return test.isEmpty ? [:] : [filterID ?? "0":test[0] as AnyObject]
//        }
//        else
//        {
//            print([filterID ?? "0":test.sorted(by: { $0! < $1! }) as AnyObject])
//            return [filterID ?? "0":test.sorted(by: { $0! < $1! }) as AnyObject]
//        }
    }
}

// MARK: - FilterType
struct FilterTypeModel: Codable {
    let filterTypeID, name, status: String?
    enum CodingKeys: String, CodingKey {
        case filterTypeID = "filter_type_id"
        case name, status
    }
}
