import SwiftUI

struct GamesView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("Games")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Coming Soon")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    GamesView()
}
