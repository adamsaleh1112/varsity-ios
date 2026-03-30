import SwiftUI

struct GameDisplay: Identifiable {
    let id = UUID()
    let homeTeam: GameTeam
    let awayTeam: GameTeam
    let homeScore: Int
    let awayScore: Int
    let date: String
    let sport: Sport
    let isFinal: Bool
}

struct GameTeam {
    let name: String
    let shortName: String
    let logo: String
    let primaryColor: String
}

enum Sport: String {
    case football = "FOOTBALL"
    case basketball = "BASKETBALL"
    case soccer = "SOCCER"
    case baseball = "BASEBALL"
    
    var badgeColor: Color {
        switch self {
        case .football:
            return Color(red: 0.23, green: 0.51, blue: 0.96)
        case .basketball:
            return Color(red: 0.55, green: 0.36, blue: 0.96)
        case .soccer:
            return Color(red: 0.06, green: 0.73, blue: 0.51)
        case .baseball:
            return Color(red: 0.96, green: 0.62, blue: 0.04)
        }
    }
    
    var backgroundGradient: [Color] {
        switch self {
        case .football:
            return [Color(red: 0.12, green: 0.23, blue: 0.37).opacity(0.8), Color(red: 0.06, green: 0.09, blue: 0.16)]
        case .basketball:
            return [Color(red: 0.30, green: 0.11, blue: 0.58).opacity(0.8), Color(red: 0.06, green: 0.09, blue: 0.16)]
        case .soccer:
            return [Color(red: 0.02, green: 0.31, blue: 0.23).opacity(0.8), Color(red: 0.06, green: 0.09, blue: 0.16)]
        case .baseball:
            return [Color(red: 0.47, green: 0.21, blue: 0.06).opacity(0.8), Color(red: 0.06, green: 0.09, blue: 0.16)]
        }
    }
}

struct GamesView: View {
    @State private var selectedFilter = "Past"
    let filters = ["Upcoming", "Live", "Past"]
    
    let games = [
        GameDisplay(
            homeTeam: GameTeam(name: "Mater Dei", shortName: "MD", logo: "md.logo", primaryColor: "C41E3A"),
            awayTeam: GameTeam(name: "St. John Bosco", shortName: "SJB", logo: "sjb.logo", primaryColor: "1E3A8A"),
            homeScore: 28,
            awayScore: 33,
            date: "Oct. 14",
            sport: .football,
            isFinal: true
        ),
        GameDisplay(
            homeTeam: GameTeam(name: "IMG Academy", shortName: "IMG", logo: "img.logo", primaryColor: "0066CC"),
            awayTeam: GameTeam(name: "Montverde", shortName: "MV", logo: "mv.logo", primaryColor: "8B1538"),
            homeScore: 62,
            awayScore: 83,
            date: "Jan. 7",
            sport: .basketball,
            isFinal: true
        ),
        GameDisplay(
            homeTeam: GameTeam(name: "St. Thomas Aquinas", shortName: "STA", logo: "sta.logo", primaryColor: "1E40AF"),
            awayTeam: GameTeam(name: "American Heritage", shortName: "AH", logo: "ah.logo", primaryColor: "FACC15"),
            homeScore: 62,
            awayScore: 83,
            date: "Jan. 7",
            sport: .basketball,
            isFinal: true
        ),
        GameDisplay(
            homeTeam: GameTeam(name: "Mater Dei", shortName: "MD", logo: "md.logo", primaryColor: "C41E3A"),
            awayTeam: GameTeam(name: "St. John Bosco", shortName: "SJB", logo: "sjb.logo", primaryColor: "1E3A8A"),
            homeScore: 14,
            awayScore: 3,
            date: "Oct. 16",
            sport: .football,
            isFinal: true
        ),
        GameDisplay(
            homeTeam: GameTeam(name: "IMG Academy", shortName: "IMG", logo: "img.logo", primaryColor: "0066CC"),
            awayTeam: GameTeam(name: "Montverde", shortName: "MV", logo: "mv.logo", primaryColor: "8B1538"),
            homeScore: 64,
            awayScore: 62,
            date: "Jan. 7",
            sport: .basketball,
            isFinal: true
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.06, green: 0.06, blue: 0.06).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Games")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(filters, id: \.self) { filter in
                                Button(filter) {
                                    selectedFilter = filter
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(selectedFilter)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 16)
                    
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(games) { game in
                                GameCard(game: game)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

struct GameCard: View {
    let game: GameDisplay
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: game.sport.backgroundGradient),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            HStack(spacing: 0) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 56, height: 56)
                        
                        Text(game.homeTeam.shortName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.77, green: 0.12, blue: 0.23))
                    }
                    
                    Text(game.homeTeam.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: 80)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 4) {
                    HStack(spacing: 12) {
                        Text("\(game.homeScore)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 2) {
                            if game.isFinal {
                                Text("Final")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            Text(game.date)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        
                        Text("\(game.awayScore)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Text(game.sport.rawValue)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 56, height: 56)
                        
                        Text(game.awayTeam.shortName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.55, green: 0.08, blue: 0.22))
                    }
                    
                    Text(game.awayTeam.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: 80)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
        }
        .frame(height: 140)
    }
}

#Preview {
    GamesView()
}
