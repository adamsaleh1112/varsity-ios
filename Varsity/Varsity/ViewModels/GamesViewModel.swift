import Foundation
import Combine

@MainActor
final class GamesViewModel: ObservableObject {
    @Published var gameCards: [GameCardData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = SportsDataService()
    
    func loadRecentGames() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let games = try await service.fetchRecentGames()
            var gameCardDataArray: [GameCardData] = []
            
            for game in games {
                do {
                    let homeTeam = try await service.fetchTeam(by: game.homeTeamId)
                    let awayTeam = try await service.fetchTeam(by: game.awayTeamId)
                    let homeSchool = try await service.fetchSchool(by: homeTeam.schoolId)
                    let awaySchool = try await service.fetchSchool(by: awayTeam.schoolId)
                    
                    let homeTeamInfo = TeamInfo(
                        id: homeTeam.id,
                        name: homeSchool.shortName ?? homeSchool.name,
                        abbreviation: homeSchool.shortName ?? String(homeSchool.name.prefix(3)).uppercased(),
                        logoURL: service.publicImageURL(bucket: "school-assets", path: homeSchool.logoPath),
                        primaryColor: homeSchool.primaryColor ?? "#333333",
                        sport: homeTeam.sport
                    )
                    
                    let awayTeamInfo = TeamInfo(
                        id: awayTeam.id,
                        name: awaySchool.shortName ?? awaySchool.name,
                        abbreviation: awaySchool.shortName ?? String(awaySchool.name.prefix(3)).uppercased(),
                        logoURL: service.publicImageURL(bucket: "school-assets", path: awaySchool.logoPath),
                        primaryColor: awaySchool.primaryColor ?? "#333333",
                        sport: awayTeam.sport
                    )
                    
                    let gameCardData = GameCardData(
                        id: game.id,
                        homeTeam: homeTeamInfo,
                        awayTeam: awayTeamInfo,
                        gameDate: formatGameDate(game.gameDate),
                        startTime: game.startTime,
                        homeScore: game.homeScore,
                        awayScore: game.awayScore,
                        sport: homeTeam.sport.uppercased(),
                        isCompleted: game.homeScore != nil && game.awayScore != nil
                    )
                    
                    gameCardDataArray.append(gameCardData)
                } catch {
                    print("Error fetching team data for game \(game.id): \(error)")
                }
            }
            
            gameCards = gameCardDataArray
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func formatGameDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d"
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}
