//
//  OrderInfoModule.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 19/08/22.
//

import Foundation

// MARK: - Welcome
struct OrderInfoModel: Codable {
    let order: OrderInfo?
}

// MARK: - Order
struct OrderInfo: Codable {
    let cancelStatus, orderID, orderedDate, orderedTime, scheduleStatus, scheduleDate, orderedType, deliveryAddress: String?
    let paymentMethod, orderStatusID, orderStatus, note: String?
    let reviewStatus, vendorName, vendorLatitude, vendorLongitude: String?
    let product: [OrderInfoProduct]?
    let total: [OrderInfoTotal]?

    enum CodingKeys: String, CodingKey {
        case cancelStatus = "cancel_status"
        case orderID = "order_id"
        case scheduleStatus = "schedule_status"
        case scheduleDate = "schedule_date"
        case orderedDate = "ordered_date"
        case orderedTime = "ordered_time"
        case orderedType = "order_type"
        case deliveryAddress = "delivery_address"
        case paymentMethod = "payment_method"
        case orderStatusID = "order_status_id"
        case orderStatus = "order_status"
        case reviewStatus = "review_status"
        case note
        case vendorName = "vendor_name"
        case vendorLatitude = "vendor_latitude"
        case vendorLongitude = "vendor_longitude"
        case product, total
    }
}

// MARK: - Product
struct OrderInfoProduct: Codable {
    let name, quantity, price, total: String?
    let option: [OrderInfoOption]?
}

// MARK: - Option
struct OrderInfoOption: Codable {
    let optionName, optionValue: String?

    enum CodingKeys: String, CodingKey {
        case optionName = "option_name"
        case optionValue = "option_value"
    }
}

// MARK: - Total
struct OrderInfoTotal: Codable {
    let title, text: String?
}
