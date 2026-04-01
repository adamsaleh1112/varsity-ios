import SwiftUI

struct HomeView: View {
    @StateObject private var schoolsViewModel = SchoolsViewModel()
    @StateObject private var gamesViewModel = GamesViewModel()
    @State private var selectedSchoolId: UUID? = nil
    @State private var selectedScope = "District"
    
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
                        Text("Home")
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .fontWidth(.expanded)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Menu {
                            Button("District") {
                                selectedScope = "District"
                            }
                            Button("Nation") {
                                selectedScope = "Nation"
                            }
                        } label: {
                            HStack {
                                Text(selectedScope)
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    
                    // Team Selector (using schools for now)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // ALL button
                            Button(action: {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                                    selectedSchoolId = nil
                                }
                            }) {
                                VStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "28282B"))
                                        .frame(width: 67, height: 67)
                                        .overlay(
                                            Text("ALL")
                                                .font(.system(size: 18, weight: .medium))
                                                .fontWidth(.expanded)
                                                .foregroundColor(.white)
                                        )
                                        .overlay(
                                            ZStack {
                                                let isSelected = (selectedSchoolId == nil)
                                                let lw = isSelected ? CGFloat(2) : CGFloat(0)
                                                
                                                RoundedRectangle(cornerRadius: 16)
                                                    .strokeBorder(Color.white, lineWidth: lw)
                                                
                                                RoundedRectangle(cornerRadius: 16)
                                                    .inset(by: lw)
                                                    .strokeBorder(Color(hex: "17171B"), lineWidth: lw)
                                            }
                                            .animation(.spring(response: 0.28, dampingFraction: 0.8), value: selectedSchoolId == nil)
                                        )
                                }
                            }
                            .buttonStyle(NoEffectButtonStyle())
                            
                            // School buttons (representing teams for now)
                            ForEach(schoolsViewModel.schools) { school in
                                Button(action: {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                                        selectedSchoolId = school.id
                                    }
                                }) {
                                    VStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(hex: school.primaryColor ?? "#333333"))
                                            .frame(width: 67, height: 67)
                                            .overlay(
                                                AsyncImage(url: schoolsViewModel.logoURL(for: school)) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .padding(10)
                                                } placeholder: {
                                                    Text(school.shortName ?? "S")
                                                        .font(.system(size: 13, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                            )
                                            .overlay(
                                                ZStack {
                                                    let isSelected = (selectedSchoolId == school.id)
                                                    let lw = isSelected ? CGFloat(2) : CGFloat(0)
                                                    
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .strokeBorder(Color.white, lineWidth: lw)
                                                    
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .inset(by: lw)
                                                        .strokeBorder(Color(hex: "17171B"), lineWidth: lw)
                                                }
                                                .animation(.spring(response: 0.28, dampingFraction: 0.8), value: selectedSchoolId == school.id)
                                            )
                                    }
                                }
                                .buttonStyle(NoEffectButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    .padding(.top, 16)
                    
                    // Horizontal Game Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            if gamesViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: UIScreen.main.bounds.width * 0.5 - 28, height: 140)
                            } else if gamesViewModel.gameCards.isEmpty {
                                Text("No games available")
                                    .foregroundColor(.gray)
                                    .frame(width: UIScreen.main.bounds.width * 0.5 - 28, height: 140)
                            } else {
                                ForEach(gamesViewModel.gameCards) { gameCard in
                                    CompactGameCard(gameData: gameCard)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                }
            }
        }
        .task {
            await schoolsViewModel.loadSchools()
            await gamesViewModel.loadRecentGames()
        }
        .onAppear {
            // Force reload when view appears (e.g., after sign out/sign in)
            Task {
                await schoolsViewModel.loadSchools()
                await gamesViewModel.loadRecentGames()
            }
        }
    }
}

struct CompactGameCard: View {
    let gameData: GameCardData
    
    var body: some View {
        VStack(spacing: 0) {
            // Centered date header
            HStack {
                Spacer()
                Text(gameData.displayDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.top, 14)
            
            // Teams stacked vertically
            VStack(spacing: 4) {
                // Away team row
                HStack(spacing: 12) {
                    if let logoURL = gameData.awayTeam.logoURL {
                        AsyncImage(url: logoURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Circle()
                                .fill(Color(hex: gameData.awayTeam.primaryColor))
                                .overlay(
                                    Text(gameData.awayTeam.abbreviation.prefix(1))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        }
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(hex: gameData.awayTeam.primaryColor))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(gameData.awayTeam.abbreviation.prefix(1))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                    
                    Text(gameData.awayTeam.abbreviation)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(gameData.awayScore != nil ? "\(gameData.awayScore!)" : "-")
                        .font(.title)
                        .fontWeight(.heavy)
                        .fontWidth(.compressed)
                        .foregroundColor(awayTeamScoreColor(gameData: gameData))
                }
                
                // Home team row
                HStack(spacing: 12) {
                    if let logoURL = gameData.homeTeam.logoURL {
                        AsyncImage(url: logoURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Circle()
                                .fill(Color(hex: gameData.homeTeam.primaryColor))
                                .overlay(
                                    Text(gameData.homeTeam.abbreviation.prefix(1))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        }
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(hex: gameData.homeTeam.primaryColor))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(gameData.homeTeam.abbreviation.prefix(1))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                    
                    Text(gameData.homeTeam.abbreviation)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(gameData.homeScore != nil ? "\(gameData.homeScore!)" : "-")
                        .font(.title)
                        .fontWeight(.heavy)
                        .fontWidth(.compressed)
                        .foregroundColor(homeTeamScoreColor(gameData: gameData))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            // Sport tag
            HStack {
                Spacer()
                Text(gameData.sport)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .fontWidth(.compressed)
                    .foregroundColor(Color(hex: "17171B"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .clipShape(Capsule())
                Spacer()
            }
            .padding(.bottom, 16)
        }
        .background(Color(hex: "28282B"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(width: UIScreen.main.bounds.width * 0.5 - 28) // 50% screen width minus padding
        .frame(height: 164)
    }
    
    private func homeTeamScoreColor(gameData: GameCardData) -> Color {
        // If game is not completed, show white
        guard gameData.isCompleted,
              let homeScore = gameData.homeScore,
              let awayScore = gameData.awayScore else {
            return .white
        }
        
        // If home team lost, grey out the score
        if homeScore < awayScore {
            return .gray
        }
        
        // If home team won or tied, keep white
        return .white
    }
    
    private func awayTeamScoreColor(gameData: GameCardData) -> Color {
        // If game is not completed, show white
        guard gameData.isCompleted,
              let homeScore = gameData.homeScore,
              let awayScore = gameData.awayScore else {
            return .white
        }
        
        // If away team lost, grey out the score
        if awayScore < homeScore {
            return .gray
        }
        
        // If away team won or tied, keep white
        return .white
    }
}


struct NoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

#Preview {
    HomeView()
}
