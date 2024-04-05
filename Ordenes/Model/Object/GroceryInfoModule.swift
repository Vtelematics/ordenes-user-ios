import Foundation

// MARK: - Welcome
struct GroceryInfoModel: Codable {
    let vendorInfo: VendorInfoModel?
    let category: [GroceryCategoryModel]?
    let success: Success?

    enum CodingKeys: String, CodingKey {
        case vendorInfo = "vendor_info"
        case category, success
    }
}

// MARK: - Category
struct GroceryCategoryModel: Codable {
    let categoryID, name: String?
    let picture: String?
    var selectedCategory: Int?

    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case selectedCategory = "selected_category"
        case name, picture
    }
}

// MARK: - VendorInfo
struct VendorInfoModel: Codable {
    let vendorID, vendorName, vendorTypeID, deliveryCharge, pickup, delivery: String?
    let minimumAmount, vendorStatus, deliveryTime, preparingTime, vendorDistance: String?

    enum CodingKeys: String, CodingKey {
        case pickup = "pick_up"
        case delivery
        case vendorID = "vendor_id"
        case vendorName = "vendor_name"
        case vendorTypeID = "vendor_type_id"
        case deliveryCharge = "delivery_charge"
        case minimumAmount = "minimum_amount"
        case vendorStatus = "vendor_status"
        case deliveryTime = "delivery_time"
        case preparingTime = "preparing_time"
        case vendorDistance = "vendor_distance"
    }
}

struct GrocerySearchProductModel: Codable {
    let product: [GroceryProduct]?
    let total: String?
    let vendor: GroceryVendor?
    let success: Success?
}

struct GroceryVendor: Codable {
    let vendorId, vendorName, vendorStatus: String?
    enum CodingKeys: String, CodingKey {
        case vendorId = "vendor_id"
        case vendorName = "vendor_name"
        case vendorStatus = "vendor_status"
    }
}

// MARK: - GroceryProduct
struct GroceryProductModel: Codable {
    let product: [Product]?
    let total: String?
}

// MARK: - GroceryProductInfo
struct GroceryProductInfoModel: Codable {
    let product: Product?
    let success: Success?
}

// MARK: - Product
struct GroceryProduct: Codable {
    let productItemID, itemName, productDescription, price: String?
    let qty, cartQuantity, cartId, discount, logo: String?
    let picture: String?
    let vendorData: VendorDataModel?

    enum CodingKeys: String, CodingKey {
        case productItemID = "product_item_id"
        case itemName = "item_name"
        case productDescription = "description"
        case price, qty, picture, discount, logo
        case cartQuantity = "cart_qty"
        case cartId = "cart_id"
        case vendorData = "vendorData"
    }
}

struct VendorDataModel: Codable{
    let vendorId, vendorName, vendorStatus : String?
    
    enum CodingKeys: String, CodingKey{
        case vendorId = "vendor_id"
        case vendorName = "vendor_name"
        case vendorStatus = "vendor_status"
    }
}

struct SubCategoryListModel: Codable {
    let subCategory: [SubCategory]?

    enum CodingKeys: String, CodingKey {
        case subCategory = "sub_category"
    }
}

// MARK: - SubCategory
struct SubCategory: Codable {
    let subCategoryID, categoryID, name: String?

    enum CodingKeys: String, CodingKey {
        case subCategoryID = "sub_category_id"
        case categoryID = "category_id"
        case name
    }
}

