import Foundation

// MARK: - HomeModel
struct HomeModel: Codable {
    let businessTypes: [BusinessType]?
    let banners: [Banner]?
    let topPick: [TopPick]?
    let pickupDescription, deliveryDescription: String?
    let bestOffer: [BestOffer]?
    let brands: [Brand]?
    let drinks: [BestOffer]?
    let content: Content?
    let success: Success?

    enum CodingKeys: String, CodingKey {
        case businessTypes = "business_types"
        case banners, content
        case pickupDescription = "pick_up_description"
        case deliveryDescription = "delivery_description"
        case topPick = "top_pick"
        case bestOffer = "best_offer"
        case brands, drinks, success
    }
}

// MARK: - Banner
struct Content: Codable {
    let brand, drinks, loginDescription, loginTitle: String?

    enum CodingKeys: String, CodingKey {
        case brand
        case drinks
        case loginDescription = "login_description"
        case loginTitle = "login_title"
    }
}

// MARK: - Banner
struct Banner: Codable {
    let bannerID, vendorID, vendorTypeId: String?
    let banner: String?

    enum CodingKeys: String, CodingKey {
        case bannerID = "banner_id"
        case vendorID = "vendor_id"
        case vendorTypeId = "vendor_type_id"
        case banner
    }
}

// MARK: - BestOffer
struct BestOffer: Codable {
    let vendorID, vendorTypeID: String?
    let offerID: String?
    let vendorName: String?
    let vendorStatus: String?
    let rating: Rating?
    let offerValue: String?
    let offer: String?
    let cuisines: String?
    let deliveryTime, deliveryFee: String?
    let banner: String?
    let logo: String?

    enum CodingKeys: String, CodingKey {
        case vendorID = "vendor_id"
        case vendorTypeID = "vendor_type_id"
        case offerID = "offer_id"
        case vendorName = "vendor_name"
        case vendorStatus = "vendor_status"
        case rating
        case offer
        case cuisines
        case offerValue = "offer_value"
        case deliveryTime = "delivery_time"
        case deliveryFee = "delivery_fee"
        case banner, logo
    }
}

// MARK: - Brand
struct Brand: Codable {
    let vendorID, vendorTypeID, vendorName, deliveryTime: String?
    let vendorStatus, logo: String?

    enum CodingKeys: String, CodingKey {
        case vendorID = "vendor_id"
        case vendorTypeID = "vendor_type_id"
        case vendorName = "vendor_name"
        case deliveryTime = "delivery_time"
        case vendorStatus = "vendor_status"
        case logo
    }
}

// MARK: - BusinessType
struct BusinessType: Codable {
    let typeID, name: String?
    let logo: String?

    enum CodingKeys: String, CodingKey {
        case typeID = "type_id"
        case name, logo
    }
}

// MARK: - Success
struct Success: Codable {
    let message, status: String?
}

// MARK: - TopPick
struct TopPick: Codable {
    let id, name: String?
    let logo: String?
}

// MARK: - Rating
struct Rating: Codable {
    let count, rating, vendorRatingImage, vendorRatingName: String?
    enum CodingKeys: String, CodingKey {
        case vendorRatingImage = "vendor_rating_image"
        case vendorRatingName = "vendor_rating_name"
        case count, rating
    }
}

