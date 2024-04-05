import Foundation

struct OrderConfirmModule: Codable {
    let order: OrderConfirmModel?
    let success: Success?
}

// MARK: - Order
struct OrderConfirmModel: Codable {
    let orderID, deliveryTime, vendorName, vendorLatitude, zoneName: String?
    let vendorLongitude, customerFirstName, customerLastName, customerLatitude, customerMobile: String?
    let customerLongitude, deliveryAddress, driverID, driverName, driverMobile: String?
    let driverProfile: String?
    let orderedDate, scheduleDate, scheduleStatus, scheduleTime, orderedTime, paymentMethod, orderStatusID: String?
    let orderStatus, note: String?
    let product: [OrderInfoProduct]?
    let total: String?

    enum CodingKeys: String, CodingKey {
        case driverMobile = "driver_mobile"
        case orderID = "order_id"
        case deliveryTime = "delivery_time"
        case scheduleDate = "schedule_date"
        case scheduleStatus = "schedule_status"
        case scheduleTime = "schedule_time"
        case vendorName = "vendor_name"
        case vendorLatitude = "vendor_latitude"
        case vendorLongitude = "vendor_longitude"
        case customerFirstName = "customer_first_name"
        case customerLastName = "customer_last_name"
        case customerLatitude = "customer_latitude"
        case customerLongitude = "customer_longitude"
        case customerMobile = "customer_mobile"
        case deliveryAddress = "delivery_address"
        case driverID = "driver_id"
        case driverName = "driver_name"
        case driverProfile = "driver_profile"
        case orderedDate = "ordered_date"
        case orderedTime = "ordered_time"
        case paymentMethod = "payment_method"
        case orderStatusID = "order_status_id"
        case orderStatus = "order_status"
        case zoneName = "zone_name"
        case note, product, total
    }
}
