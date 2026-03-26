import SwiftUI

struct VarsityGamesView: View {
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
                            
                            HStack {
                                Text("District")
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        Spacer()
                        
                        Text("Coming Soon")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    VarsityGamesView()
}

