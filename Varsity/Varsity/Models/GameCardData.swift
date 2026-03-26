import Foundation

struct GameCardData: Identifiable {
    let id: UUID
    let homeTeam: TeamInfo
    let awayTeam: TeamInfo
    let gameDate: String
    let startTime: String?
    let homeScore: Int?
    let awayScore: Int?
    let sport: String
    let isCompleted: Bool
    
    var displayDate: String {
        if isCompleted {
            return "Final \(gameDate)"
        } else {
            if let startTime = startTime {
                let formattedTime = formatTimeToAMPM(startTime)
                return "\(gameDate) \(formattedTime)"
            } else {
                return gameDate
            }
        }
    }
    
    private func formatTimeToAMPM(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        if let time = formatter.date(from: timeString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a"
            return displayFormatter.string(from: time)
        }
        
        // Fallback for HH:mm format (without seconds)
        formatter.dateFormat = "HH:mm"
        if let time = formatter.date(from: timeString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a"
            return displayFormatter.string(from: time)
        }
        
        return timeString
    }
}

struct TeamInfo {
    let id: UUID
    let name: String
    let abbreviation: String
    let logoURL: URL?
    let primaryColor: String
    let sport: String
}
