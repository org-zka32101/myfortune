import Foundation

struct Fortune: Codable {
    let id: String
    let text: String
    let date: Date
    let category: String

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case date
        case category
    }
}
