import SwiftUI

struct VarsityGamesView: View {
    @StateObject private var gamesViewModel = GamesViewModel()
    @State private var selectedFilter = "Past"
    let filters = ["Upcoming", "Live", "Past"]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color(hex: "17171B").ignoresSafeArea()
                    
                    // Subtle pink/blue gradient at top
                    VStack {
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.blue.opacity(0.2), location: 0.0),
                                .init(color: Color.pink.opacity(0.2), location: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 180)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black, Color.clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Games")
                                .font(.largeTitle)
                                .fontWeight(.medium)
                                .fontWidth(.expanded)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Filter Dropdown
                            Menu {
                                ForEach(filters, id: \.self) { filter in
                                    Button(filter) {
                                        selectedFilter = filter
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedFilter)
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                        
                        // Games List
                        if gamesViewModel.isLoading {
                            Spacer()
                            ProgressView("Loading games...")
                                .foregroundColor(.white)
                            Spacer()
                        } else if let errorMessage = gamesViewModel.errorMessage {
                            Spacer()
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                            Spacer()
                        } else if gamesViewModel.gameCards.isEmpty {
                            Spacer()
                            Text("No games found")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Spacer()
                        } else {
                            ScrollView(showsIndicators: false) {
                                LazyVStack(spacing: 12) {
                                    ForEach(gamesViewModel.gameCards) { gameCard in
                                        GameListCard(gameCard: gameCard)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await gamesViewModel.loadRecentGames()
            }
        }
    }
}

struct GameListCard: View {
    let gameCard: GameCardData
    
    var sportBackgroundGradient: [Color] {
        return [Color(hex: "28282B")]
    }
    
    var body: some View {
        ZStack {
            // Background with #28282B matching home screen
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "28282B"))
            
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
                            .fill(Color(hex: gameCard.homeTeam.primaryColor))
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
                            .fill(Color(hex: gameCard.awayTeam.primaryColor))
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

#Preview {
    VarsityGamesView()
}

