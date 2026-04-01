import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @State private var showingEditProfile = false
    @State private var showingTeamSelection = false
    @State private var showingSettings = false
    @State private var scrollOffset: CGFloat = 0
    @State private var bannerRefreshToken = Date().timeIntervalSince1970
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Banner at top - extends to very top of screen with scaling effect
                        GeometryReader { bannerGeometry in
                            let minY = bannerGeometry.frame(in: .global).minY
                            // Only scale when pulling down from top (overscroll)
                            let isAtTop = minY > 0
                            let overscroll = isAtTop ? minY : 0
                            let scale = 1 + (overscroll / 200)
                            
                            ZStack(alignment: .top) {
                                if let bannerUrl = authManager.currentUser?.bannerUrl,
                                   !bannerUrl.isEmpty {
                                    // Add cache-busting timestamp to force reload
                                    let cacheBustedUrl = "\(bannerUrl)?t=\(bannerRefreshToken)"
                                    AsyncImage(url: URL(string: cacheBustedUrl)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                    }
                                    .frame(height: 200)
                                    .scaleEffect(scale, anchor: .bottom)
                                } else {
                                    Rectangle()
                                        .fill(Color(hex: "28282B"))
                                        .frame(height: 200)
                                        .scaleEffect(scale, anchor: .bottom)
                                }
                            }
                            .frame(height: 200)
                        }
                        .frame(height: 200)
                        .padding(.top, -geometry.safeAreaInsets.top)
                        
                        profilePictureSection
                        userInfoSection
                        actionButtonsSection
                        favoritesSection
                        
                        Spacer(minLength: 100)
                    }
                }
                .coordinateSpace(name: "scroll")
            }
            .background(Color(hex: "17171B"))
            .navigationTitle("")
            .overlay(
                // Floating Settings Button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    Spacer()
                }
            )
            .onChange(of: authManager.currentUser?.bannerUrl) { _ in
                bannerRefreshToken = Date().timeIntervalSince1970
            }
            .onAppear {
                Task {
                    await authManager.loadUserFollows()
                }
            }
            .fullScreenCover(isPresented: $showingTeamSelection) {
                TeamSelectionView()
            }
            .fullScreenCover(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .fullScreenCover(isPresented: $showingSettings) {
                UserSettingsView()
            }
        }
    }
    
    private var profilePictureSection: some View {
        let avatarUrl = authManager.currentUser?.avatarUrl
        let defaultUrl = "https://hpfxonowaopgclnujptn.supabase.co/storage/v1/object/public/user-assets/avatars/defaultuserpic.jpg"
        let imageUrl = (avatarUrl == nil || avatarUrl!.isEmpty) ? defaultUrl : avatarUrl!
        
        return AsyncImage(url: URL(string: imageUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                )
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color(hex: "17171B"), lineWidth: 4)
        )
        .padding(.top, -60)
    }
    
    private var userInfoSection: some View {
        VStack(spacing: 8) {
            // Display name and username on same line
            HStack(spacing: 6) {
                Text(authManager.currentUser?.displayName ?? authManager.currentUser?.username ?? "User")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let username = authManager.currentUser?.username {
                    Text("@\(username)")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            
            if let bio = authManager.currentUser?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            if let createdAt = authManager.currentUser?.createdAt {
                Text(formatDateJoined(createdAt))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 20)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: {
                    showingEditProfile = true
                }) {
                    Text("Edit Profile")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "28282B"))
                        .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    private var favoritesSection: some View {
        VStack(spacing: 16) {
            // Favorites Header
            HStack {
                Text("Favorites")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingTeamSelection = true
                }) {
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
            if authManager.userFollows.isEmpty {
                Text("No schools followed yet")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.top, 20)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 20) {
                    ForEach(authManager.userFollows) { follow in
                        if let school = follow.school {
                            FavoriteSchoolCell(school: school)
                        } else {
                            Text("School data missing")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
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

