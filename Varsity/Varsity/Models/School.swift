import Foundation

struct School: Decodable, Identifiable {
    let id: UUID
    let name: String
    let shortName: String?
    let city: String?
    let state: String?
    let mascot: String?
    let primaryColor: String?
    let secondaryColor: String?
    let logoPath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, city, state, mascot
        case shortName = "short_name"
        case primaryColor = "primary_color"
        case secondaryColor = "secondary_color"
        case logoPath = "logo_path"
    }
}
