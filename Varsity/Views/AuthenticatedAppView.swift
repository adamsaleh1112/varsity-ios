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
    @State private var searchText = ""
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                VarsityHomeView()
            }
            
            Tab("Games", systemImage: "sportscourt.fill") {
                VarsityGamesView()
            }
            
            Tab("Profile", systemImage: "person.fill") {
                ProfileView()
            }
            
            // Dedicated Search Tab (separate on the right)
            Tab(role: .search) {
                NavigationStack {
                    SearchView()
                        .searchable(text: $searchText)
                }
            }
        }
        .accentColor(.white)
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
