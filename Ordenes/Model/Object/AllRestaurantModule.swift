//
//  AllRestaurantModule.swift
//  Talabat clone
//
//  Created by Adyas infotech on 30/06/22.
//

import Foundation

// MARK: - Welcome
struct AllRestraurantModel: Codable {
    let filter: [AllRestroFilter]?
    let banner: [Banner]?
    let vendor: [AllRestroVendor]?
    let vendorList: [AllRestroVendor]?
    let total: String?
    let success: Success?

    enum CodingKeys: String, CodingKey {
        case filter, banner, vendor
        case vendorList = "vendor_list"
        case total, success
    }
}

// MARK: - Filter
struct AllRestroFilter: Codable {
    let filterID, key, name: String?
    let logo: String?

    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case name, logo, key
    }
}

// MARK: - Vendor
struct AllRestroVendor: Codable {
    let vendorID, name: String?
    let banner: String?
    let logo: String?
    let cuisines: String?
    let vendorStatus, deliveryCharge, minimumAmount, deliveryTime: String?
    let rating: Rating?
    let vendorTypeID, freeDelivery, storeTypes, new, offer: String?

    enum CodingKeys: String, CodingKey {
        case vendorID = "vendor_id"
        case name, banner, logo, new
        case cuisines = "cuisines"
        case vendorStatus = "vendor_status"
        case deliveryCharge = "delivery_charge"
        case minimumAmount = "minimum_amount"
        case deliveryTime = "delivery_time"
        case vendorTypeID = "vendor_type_id"
        case freeDelivery = "free_delivery"
        case storeTypes = "store_types"
        case rating, offer
    }
}

struct WishlistModel: Codable {
    let vendorList: [AllRestroVendor]?
    let success: Success?

    enum CodingKeys: String, CodingKey {
        case vendorList = "vendor_list"
        case success
    }
}
