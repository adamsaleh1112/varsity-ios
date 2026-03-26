import Foundation

struct Game: Decodable, Identifiable {
    let id: UUID
    let homeTeamId: UUID
    let awayTeamId: UUID
    let locationSchoolId: UUID?
    let gameDate: String
    let startTime: String?
    let status: String
    let homeScore: Int?
    let awayScore: Int?

    enum CodingKeys: String, CodingKey {
        case id, status
        case homeTeamId = "home_team_id"
        case awayTeamId = "away_team_id"
        case locationSchoolId = "location_school_id"
        case gameDate = "game_date"
        case startTime = "start_time"
        case homeScore = "home_score"
        case awayScore = "away_score"
    }
}
