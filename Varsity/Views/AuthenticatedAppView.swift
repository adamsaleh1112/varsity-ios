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
    
    var body: some View {
        TabView {
            VarsityHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            VarsityGamesView()
                .tabItem {
                    Image(systemName: "sportscourt.fill")
                    Text("Games")
                }
            
            VarsityMeView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Me")
                }
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
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
