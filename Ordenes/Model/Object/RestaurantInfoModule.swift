
import Foundation

// MARK: - Welcome
struct RestaurantModel: Codable {
    let vendor: Vendor?
    let success: Success?
}

// MARK: - Vendor
struct Vendor: Codable {
    let vendorID, name, pickup, delivery: String?
    let image: String?
    let logo: String?
    let address, latitude, longitude: String?
    let rating: Rating?
    let vendorStatus: String?
    let workingHours: String?
    let businessType: BusinessTypeInfo?
    let cuisine: [Cuisine]?
    let deliveryCharge, minimumAmount, deliveryTime, preparingTime, vendorDistance: String?
    let paymentMethod: [PaymentMethod]?
    let category: [Category]?

    enum CodingKeys: String, CodingKey {
        case vendorID = "vendor_id"
        case name, image, logo, address, latitude, longitude, rating
        case vendorStatus = "vendor_status"
        case businessType = "business_type"
        case cuisine
        case pickup = "pick_up"
        case delivery
        case workingHours = "working_hours"
        case deliveryCharge = "delivery_charge"
        case minimumAmount = "minimum_amount"
        case deliveryTime = "delivery_time"
        case preparingTime = "preparing_time"
        case vendorDistance = "vendor_distance"
        case paymentMethod = "payment_method"
        case category
    }
}

// MARK: - BusinessType
struct BusinessTypeInfo: Codable {
    let businessTypeID, name: String?

    enum CodingKeys: String, CodingKey {
        case businessTypeID = "business_type_id"
        case name
    }
}

// MARK: - Category
struct Category: Codable {
    let productCategoryID, name, count: String?
    var product: [Product]?

    enum CodingKeys: String, CodingKey {
        case productCategoryID = "product_category_id"
        case name, count, product
    }
}

// MARK: - Product
struct Product: Codable {
    let productItemID, itemName, productDescription: String?
    let image, picture, logo: String?
    let price, priceStatus, discount, stock, hasOptions: String?
    let options: [Option]?

    enum CodingKeys: String, CodingKey {
        case productItemID = "product_item_id"
        case itemName = "item_name"
        case productDescription = "description"
        case image, price, discount, stock, logo, picture
        case priceStatus = "price_status"
        case hasOptions = "has_options"
        case options
    }
}

// MARK: - Option
struct Option: Codable {
    let productOptionID, name: String?
    let type: String?
    var minimumLimit, maximumLimit, isRequired: String?
    let productValue: [ProductValue]?
    //var selectedName : [String] = []
    var selectedtoAdd:[ProductValue]! = []{
        didSet {
            if type == "1"
            {
                selectedtoAdd = Array(selectedtoAdd.suffix(1))
            }
            else if selectedtoAdd.count > Int(maximumLimit ?? "0") ?? 0 && type == "2"
            {
                if Int(maximumLimit ?? "0") ?? 0 > 0
                {
                    selectedtoAdd = oldValue
                }
            }
        }
    }
    
    var selectedOptions:[Int]  = [] {
        didSet {
            if type == "1"
            {
                selectedOptions = Array(selectedOptions.suffix(1))
            }
            else if selectedOptions.count > Int(maximumLimit ?? "0") ?? 0 && type == "2"
            {
                if Int(maximumLimit ?? "0") ?? 0 > 0
                {
                    selectedOptions = oldValue
                }
            }
        }
    }
    
    func getSelectedValues()->[String:AnyObject]
    {
        let test = selectedtoAdd.map { $0.optionValueID }
        
        if type == "1"
        {
            return test.isEmpty ? [:] : [productOptionID ?? "0":test[0] as AnyObject]
        }
        else
        {
            return [productOptionID ?? "0":test.sorted(by: { $0! < $1! }) as AnyObject]
        }
    }

    enum CodingKeys: String, CodingKey {
        case productOptionID = "product_option_id"
        case name, type
        case minimumLimit = "minimum_limit"
        case maximumLimit = "maximum_limit"
        case isRequired = "required"
        case productValue = "product_value"
    }
    
    init(productOptionID: String? = nil, type: String? = nil, isRequired: String? = nil, productValue: [ProductValue]? = nil, minimumLimit: String? = nil, maximumLimit: String? = nil, name: String? = nil) {
        self.productOptionID = productOptionID
        self.type = type
        self.isRequired = isRequired
        self.productValue = productValue
        self.minimumLimit = minimumLimit
        self.maximumLimit = maximumLimit
        self.name = name
        }
    
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            productOptionID = try container.decode(String.self, forKey: .productOptionID)
            type = try container.decode(String.self, forKey: .type)
            isRequired = try container.decode(String.self, forKey: .isRequired)
            productValue = try container.decode([ProductValue]?.self, forKey: .productValue)
            name = try container.decode(String.self, forKey: .name)
            do {
                minimumLimit = try String(container.decode(Int.self, forKey: .minimumLimit))
                maximumLimit = try String(container.decode(Int.self, forKey: .maximumLimit))
            } catch DecodingError.typeMismatch {
                minimumLimit = try container.decode(String.self, forKey: .minimumLimit)
                maximumLimit = try container.decode(String.self, forKey: .maximumLimit)
            }
        }
}

// MARK: - ProductValue
struct ProductValue: Codable {
    let optionValueID, optionID, name, price: String?

    enum CodingKeys: String, CodingKey {
        case optionValueID = "option_value_id"
        case optionID = "option_id"
        case name, price
    }
}

// MARK: - Cuisine
struct Cuisine: Codable {
    let cuisineID, name: String?

    enum CodingKeys: String, CodingKey {
        case cuisineID = "cuisine_id"
        case name
    }
}

// MARK: - PaymentMethod
struct PaymentMethod: Codable {
    let code: String?
    let image: String?
    let title: String?
}

struct ReviewsModel: Codable {
    let avgVendorRating, avgDeliveryTime, avgQuality, avgValueForMoney: String?
    let avgOrderPacking: String?
    var reviewList: [ReviewList]?
    let total: String?
    let success: Success?

    enum CodingKeys: String, CodingKey {
        case avgVendorRating = "avg_vendor_rating"
        case avgDeliveryTime = "avg_delivery_time"
        case avgQuality = "avg_quality"
        case avgValueForMoney = "avg_value_for_money"
        case avgOrderPacking = "avg_order_packing"
        case reviewList = "review_list"
        case total, success
    }
}

// MARK: - ReviewList
struct ReviewList: Codable {
    let vendorRating, comment, customerName, date: String?

    enum CodingKeys: String, CodingKey {
        case vendorRating = "vendor_rating"
        case comment
        case customerName = "customer_name"
        case date
    }
}
