import SwiftUI

struct VarsityMeView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @State private var showingEditProfile = false
    @State private var showingTeamSelection = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Banner at top - extends to very top of screen
                        ZStack(alignment: .top) {
                            // Banner background - extends to top of screen
                            if let bannerUrl = authManager.currentUser?.bannerUrl,
                               !bannerUrl.isEmpty {
                                AsyncImage(url: URL(string: bannerUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(height: 200)
                            } else {
                                Rectangle()
                                    .fill(Color(hex: "28282B"))
                                    .frame(height: 200)
                            }
                        }
                        .frame(height: 200)
                        .clipped()
                        .padding(.top, -geometry.safeAreaInsets.top)
                        
                        // Profile Picture - overlapping effect
                        let avatarUrl = authManager.currentUser?.avatarUrl
                        let defaultUrl = "https://hpfxonowaopgclnujptn.supabase.co/storage/v1/object/public/user-assets/avatars/defaultuserpic.jpg"
                        let imageUrl = (avatarUrl == nil || avatarUrl!.isEmpty) ? defaultUrl : avatarUrl!
                        
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "17171B"), lineWidth: 4)
                        )
                        .offset(y: -50)
                        .zIndex(1)
                        
                        // User Info
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Text(authManager.currentUser?.displayName ?? authManager.currentUser?.username ?? "User")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("@\(authManager.currentUser?.username ?? "")")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                            
                            if let bio = authManager.currentUser?.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Date Joined
                            if let createdAt = authManager.currentUser?.createdAt {
                                Text(formatDateJoined(createdAt))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.top, -20)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                NavigationLink(destination: EditProfileView()) {
                                    Text("Edit Profile")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color(hex: "28282B"))
                                        .cornerRadius(12)
                                }
                            }
                            
                            Button(action: {
                                Task {
                                    await authManager.signOut()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Sign Out")
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        // Favorites Section
                        VStack(spacing: 16) {
                            // Favorites Header
                            HStack {
                                Text("Favorites")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                NavigationLink(destination: TeamSelectionView()) {
                                    HStack(spacing: 4) {
                                        Text("Manage")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color(hex: "6e27e8"))
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "6e27e8"))
                                    }
                                }
                            }
                            
                            // Favorites Grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 20) {
                                ForEach(authManager.userFollows) { follow in
                                    if let school = follow.school {
                                        FavoriteSchoolCell(school: school)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .background(Color(hex: "17171B"))
            .navigationTitle("")
        }
    }
}

#Preview {
    VarsityMeView()
}

// Helper function to format date joined
private func formatDateJoined(_ dateString: String) -> String {
    let formatter = ISO8601DateFormatter()
    if let date = formatter.date(from: dateString) {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMMM yyyy"
        return "Joined \(displayFormatter.string(from: date))"
    }
    return "Joined recently"
}

