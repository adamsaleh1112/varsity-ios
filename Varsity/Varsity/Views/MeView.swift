import SwiftUI

struct MeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("Me")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Profile Coming Soon")
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
    MeView()
}
