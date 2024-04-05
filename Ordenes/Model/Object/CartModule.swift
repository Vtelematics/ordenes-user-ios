
import Foundation

// MARK: - Welcome
struct CartModel: Codable {
    let products: [CartProduct]?
    let totals: [Total]?
    let errorWarning, vendorDeliveryTime, vendorID, vendorTypeID, vendorName, vendorMobile: String?
    let latitude, longitude, restaurantLatitude, restaurantLongitude: String?
    let orderType, vendorAddress, offerStatus, couponStatus: String?
    let productCount, total: String?
    let success: Success?

    enum CodingKeys: String, CodingKey {
        case products, totals
        case errorWarning = "error_warning"
        case offerStatus = "offer_status"
        case couponStatus = "coupon_status"
        case vendorDeliveryTime = "vendor_delivery_time"
        case vendorID = "vendor_id"
        case vendorTypeID = "vendor_type_id"
        case vendorName = "vendor_name"
        case latitude, longitude
        case restaurantLatitude = "restaurant_latitude"
        case restaurantLongitude = "restaurant_longitude"
        case orderType = "order_type"
        case vendorAddress = "vendor_address"
        case vendorMobile = "vendor_mobile"
        case productCount = "product_count"
        case total, success
    }
}

// MARK: - Product
struct CartProduct: Codable {
    let cartID, productID, name: String?
    let image: String?
    let quantity, stockStatus, optionStatus: String?
    let option: [CartProductOption]?
    let priceStatus, price, discountPrice, total, actualTotal: String?

    enum CodingKeys: String, CodingKey {
        case cartID = "cart_id"
        case productID = "product_id"
        case name, image, quantity
        case stockStatus = "stock_status"
        case optionStatus = "option_status"
        case option
        case discountPrice = "discount_price"
        case priceStatus = "price_status"
        case price, total
        case actualTotal = "actual_total"
    }
}

// MARK: - Option
struct CartProductOption: Codable {
    let optionID, optionValueID, price, name: String?
    let value, type, quantity: String?

    enum CodingKeys: String, CodingKey {
        case optionID = "option_id"
        case optionValueID = "option_value_id"
        case price, name, value, type, quantity
    }
}

// MARK: - Total
struct Total: Codable {
    let titleKey, title, textAmount, amount, currency, text: String?
    
    enum CodingKeys: String, CodingKey {
            case titleKey = "title_key"
            case textAmount = "text_amount"
            case amount = "amount"
            case currency = "currency"
            case title, text
        }
}

// MARK: - Payment
struct PaymentModel: Codable {
    let address: Address?
    let payment: [Payment]?
    let scheduleStatus: String?
    let deliveryTime: String?
    let schedule: Schedule?
    let orderType: String?
    let success: Success?
    let errorWarning: String?
    
    enum CodingKeys: String, CodingKey {
        case address, payment
        case scheduleStatus = "schedule_status"
        case deliveryTime = "delivery_time"
        case schedule
        case orderType = "order_type"
        case errorWarning = "error_warning"
        case success
    }
}

struct Schedule: Codable {
    let day, date: [String]?
}

// MARK: - Address
struct Address: Codable {
    let addressID, customerID, firstName, lastName: String?
    let email, countryCode, mobile, landline, area, address: String?
    let addressType, block, street, way: String?
    let buildingName, floor, doorNo, additionalDirection: String?
    let zoneId, latitude, longitude: String?

    enum CodingKeys: String, CodingKey {
        case addressID = "address_id"
        case customerID = "customer_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case countryCode = "country_code"
        case mobile, landline, area, address
        case addressType = "address_type"
        case block, street, way
        case buildingName = "building_name"
        case floor
        case zoneId = "zone_id"
        case doorNo = "door_no"
        case additionalDirection = "additional_direction"
        case latitude, longitude
    }
}

// MARK: - Payment
struct Payment: Codable {
    let paymentListID, paymentName, paymentCode, status: String?
    enum CodingKeys: String, CodingKey {
        case paymentListID = "payment_list_id"
        case paymentName = "payment_name"
        case paymentCode = "payment_code"
        case status
    }
}
