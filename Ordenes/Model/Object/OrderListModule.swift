//
//  OrderModule.swift
//  Talabat clone
//
//  Created by Exlcart Solutions on 18/08/22.
//

import Foundation

// MARK: - Welcome
struct OrderListModel: Codable {
    let total: String?
    let orders: [Order]?
    let success: Success?
}

// MARK: - Order
struct Order: Codable {
    let orderID, orderType, firstName, lastName, status: String?
    let orderedDate, orderedTime, vendorID, vendorName: String?
    let price: String?
    let logo: String?

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case status
        case orderedDate = "ordered_date"
        case orderedTime = "ordered_time"
        case vendorID = "vendor_id"
        case vendorName = "vendor_name"
        case orderType = "order_type"
        case price, logo
    }
}


