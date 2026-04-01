import SwiftUI

struct FullGameCard: View {
    let gameCard: GameCardData
    
    var sportBackgroundGradient: [Color] {
        return [Color(hex: "28282B") ?? Color.gray]
    }
    
    var body: some View {
        ZStack {
            // Background with #28282B matching home screen
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "28282B") ?? Color.gray)
            
            // Content - scores pushed closer to logos, more middle space
            HStack(spacing: 0) {
                // Home Team (Left)
                VStack(spacing: 8) {
                    // Team Logo
                    AsyncImage(url: gameCard.homeTeam.logoURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Circle()
                            .fill(Color(hex: gameCard.homeTeam.primaryColor) ?? Color.gray)
                            .overlay(
                                Text(gameCard.homeTeam.abbreviation.prefix(1))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    
                    Text(gameCard.homeTeam.abbreviation)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Score centered between logo and middle
                Text("\(gameCard.homeScore ?? 0)")
                    .font(.system(size: 38))
                    .fontWeight(.heavy)
                    .fontWidth(.compressed)
                    .foregroundColor(homeTeamScoreColor(gameCard: gameCard))
                    .frame(minWidth: 45)
                
                Spacer()
                
                // Score and Status (Center)
                VStack(spacing: 12) {
                    VStack(spacing: 2) {
                        if gameCard.isCompleted {
                            Text("Final")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Text(gameCard.gameDate)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Sport Badge with more spacing from date
                    Text(gameCard.sport)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .fontWidth(.compressed)
                        .foregroundColor(Color(hex: "17171B"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // Score centered between middle and logo
                Text("\(gameCard.awayScore ?? 0)")
                    .font(.system(size: 38))
                    .fontWeight(.heavy)
                    .fontWidth(.compressed)
                    .foregroundColor(awayTeamScoreColor(gameCard: gameCard))
                    .frame(minWidth: 45)
                
                Spacer()
                
                // Away Team (Right)
                VStack(spacing: 8) {
                    // Team Logo
                    AsyncImage(url: gameCard.awayTeam.logoURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Circle()
                            .fill(Color(hex: gameCard.awayTeam.primaryColor) ?? Color.gray)
                            .overlay(
                                Text(gameCard.awayTeam.abbreviation.prefix(1))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    
                    Text(gameCard.awayTeam.abbreviation)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .frame(height: 128)
    }
    
    private func homeTeamScoreColor(gameCard: GameCardData) -> Color {
        guard gameCard.isCompleted,
              let homeScore = gameCard.homeScore,
              let awayScore = gameCard.awayScore else {
            return .white
        }
        
        if homeScore < awayScore {
            return .gray
        }
        
        return .white
    }
    
    private func awayTeamScoreColor(gameCard: GameCardData) -> Color {
        guard gameCard.isCompleted,
              let homeScore = gameCard.homeScore,
              let awayScore = gameCard.awayScore else {
            return .white
        }
        
        if awayScore < homeScore {
            return .gray
        }
        
        return .white
    }
}
