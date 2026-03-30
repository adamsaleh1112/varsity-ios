import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let username: String
    let email: String?
    let displayName: String?
    let avatarURL: String?
    let bannerURL: String?
    let authProvider: String
    let createdAt: String
    let lastLogin: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case bannerURL = "banner_url"
        case authProvider = "auth_provider"
        case createdAt = "created_at"
        case lastLogin = "last_login"
    }
}

enum AuthProvider: String, Codable, CaseIterable {
    case apple = "apple"
    case google = "google"
    case email = "email"
}

struct UserFollow: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let schoolId: UUID
    let followedAt: String
    let notificationsEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case schoolId = "school_id"
        case followedAt = "followed_at"
        case notificationsEnabled = "notifications_enabled"
    }
}
