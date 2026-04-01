import SwiftUI

struct GamesView: View {
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
                                        FullGameCard(gameCard: gameCard)
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

#Preview {
    GamesView()
}

