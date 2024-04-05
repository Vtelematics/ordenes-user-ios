import Foundation

// MARK: - Welcome
struct AddressModel: Codable {
    let address: [Address]?
    let success: Success?
    
    enum CodingKeys: String, CodingKey {
        case address = "addresses"
        case success
    }
}
