import SwiftUI

struct AuthenticatedAppView: View {
    @StateObject private var authManager = SimpleAuthManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainAppView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            // SimpleAuthManager doesn't need checkAuthenticationStatus - it starts unauthenticated
        }
    }
}

struct MainAppView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    VarsityHomeView()
                case 1:
                    VarsityGamesView()
                case 2:
                    VarsityMeView()
                case 3:
                    SearchView()
                default:
                    VarsityHomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            VStack(spacing: 0) {
                Spacer()
                
                HStack(spacing: 8) {
                    // Left group: Home, Games, Me
                    HStack(spacing: 0) {
                        TabButton(
                            icon: "house.fill",
                            label: "Home",
                            isSelected: selectedTab == 0,
                            action: { selectedTab = 0 }
                        )
                        
                        TabButton(
                            icon: "sportscourt.fill",
                            label: "Games",
                            isSelected: selectedTab == 1,
                            action: { selectedTab = 1 }
                        )
                        
                        TabButton(
                            icon: "person.fill",
                            label: "Me",
                            isSelected: selectedTab == 2,
                            action: { selectedTab = 2 }
                        )
                    }
                    .background(Color(hex: "28282B").opacity(0.9))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Right: Search (separated)
                    TabButton(
                        icon: "magnifyingglass",
                        label: "Search",
                        isSelected: selectedTab == 3,
                        action: { selectedTab = 3 }
                    )
                    .background(Color(hex: "28282B").opacity(0.9))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct TabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .white : .gray)
            .frame(width: 70, height: 50)
        }
    }
}

struct SearchView: View {
    var body: some View {
        ZStack {
            Color(hex: "17171B").ignoresSafeArea()
            
            Text("Search")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    AuthenticatedAppView()
}
