import Foundation
import Supabase

final class SportsDataService {
    private let supabase = SupabaseManager.shared.client

    func fetchSchools() async throws -> [School] {
        try await supabase
            .from("schools")
            .select()
            .order("name")
            .execute()
            .value
    }

    func fetchTeams(for schoolID: UUID) async throws -> [Team] {
        try await supabase
            .from("teams")
            .select()
            .eq("school_id", value: schoolID)
            .order("sport")
            .execute()
            .value
    }

    func fetchGames(for teamID: UUID) async throws -> [Game] {
        try await supabase
            .from("games")
            .select()
            .or("home_team_id.eq.\(teamID),away_team_id.eq.\(teamID)")
            .order("game_date")
            .execute()
            .value
    }

    func fetchRecentGames() async throws -> [Game] {
        try await supabase
            .from("games")
            .select()
            .order("game_date", ascending: false)
            .limit(10)
            .execute()
            .value
    }
    
    func fetchTeam(by teamID: UUID) async throws -> Team {
        let teams: [Team] = try await supabase
            .from("teams")
            .select()
            .eq("id", value: teamID)
            .execute()
            .value
        
        guard let team = teams.first else {
            throw NSError(domain: "SportsDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Team not found"])
        }
        
        return team
    }
    
    func fetchSchool(by schoolID: UUID) async throws -> School {
        let schools: [School] = try await supabase
            .from("schools")
            .select()
            .eq("id", value: schoolID)
            .execute()
            .value
        
        guard let school = schools.first else {
            throw NSError(domain: "SportsDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "School not found"])
        }
        
        return school
    }

    func publicImageURL(bucket: String, path: String?) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return try? supabase.storage
            .from(bucket)
            .getPublicURL(path: path)
    }
}
