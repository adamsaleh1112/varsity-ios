import SwiftUI

struct ContentView: View {
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
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
