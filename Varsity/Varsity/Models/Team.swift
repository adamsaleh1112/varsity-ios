import Foundation

struct Team: Decodable, Identifiable {
    let id: UUID
    let schoolId: UUID
    let sport: String
    let gender: String
    let level: String
    let displayName: String?
    let logoPath: String?

    enum CodingKeys: String, CodingKey {
        case id, sport, gender, level
        case schoolId = "school_id"
        case displayName = "display_name"
        case logoPath = "logo_path"
    }
}
