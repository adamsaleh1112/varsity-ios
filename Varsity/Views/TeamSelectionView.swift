import SwiftUI
import Supabase

struct TeamSelectionView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @Environment(\.dismiss) private var dismiss
    
    // Remove local state - use authManager.userFollows instead
    @State private var availableSchools: [School] = []
    @State private var filteredSchools: [School] = []
    @State private var searchText: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color(hex: "17171B").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header with back button and title inline
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Text("Manage Following")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Spacer to balance the back button
                    Spacer()
                        .frame(width: 24) // Same width as back button
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(Color(hex: "17171B"))
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("", text: $searchText, prompt: Text("Search schools...").foregroundColor(.gray.opacity(0.6)))
                        .foregroundColor(.white)
                        .onChange(of: searchText) {
                            filterSchools()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            filterSchools()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "28282B"), lineWidth: 1)
                )
                .frame(height: 50)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 18)
                    
                    // Schools List
                    if isLoading {
                        ProgressView("Loading schools...")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredSchools.isEmpty && !searchText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Schools Found")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Try adjusting your search terms.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if availableSchools.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "graduationcap")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Schools Available")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Schools will appear here once they're added to the system.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredSchools) { school in
                                    TeamRowView(
                                        school: school,
                                        isFollowed: authManager.isFollowingSchool(school.id),
                                        onToggle: {
                                            toggleTeamFollow(school: school)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .onAppear {
                loadTeamsAndFollowing()
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
    }
    
    private func loadTeamsAndFollowing() {
        isLoading = true
        
        Task {
            await loadSchoolsFromDatabase()
            await loadFollowedSchools()
        }
    }
    
    private func loadSchoolsFromDatabase() async {
        do {
            let supabase = SupabaseManager.shared.client
            let response = try await supabase
                .from("schools")
                .select("*")
                .execute()
            
            // Debug: print raw response
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("Raw schools response: \(jsonString)")
            }
            
            let schools = try JSONDecoder().decode([School].self, from: response.data)
            
            // Debug: print parsed schools
            for school in schools {
                print("Parsed school: \(school.name), logoPath: \(school.logoPath ?? "nil")")
            }
            
            await MainActor.run {
                availableSchools = schools
                filteredSchools = schools
                isLoading = false
            }
        } catch {
            print("Error fetching schools: \(error)")
            await MainActor.run {
                errorMessage = "Failed to load schools"
                isLoading = false
            }
        }
    }
    
    private func loadFollowedSchools() async {
        // Load actual followed schools from database
        await authManager.loadUserFollows()
    }
    
    private func filterSchools() {
        if searchText.isEmpty {
            filteredSchools = availableSchools
        } else {
            filteredSchools = availableSchools.filter { school in
                school.name.localizedCaseInsensitiveContains(searchText) ||
                (school.city?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (school.state?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (school.shortName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    private func toggleTeamFollow(school: School) {
        Task {
            if authManager.isFollowingSchool(school.id) {
                await authManager.unfollowSchool(school.id)
            } else {
                await authManager.followSchool(school.id)
            }
        }
    }
}

struct TeamRowView: View {
    let school: School
    let isFollowed: Bool
    let onToggle: () -> Void
    @EnvironmentObject var authManager: SimpleAuthManager
    
    // Use the same service as Home screen
    private var logoURL: URL? {
        SportsDataService().publicImageURL(bucket: "school-assets", path: school.logoPath)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // School Logo - use same technique as Home screen
            AsyncImage(url: logoURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Circle()
                    .fill(Color(hex: school.primaryColor ?? "28282B"))
                    .overlay(
                        Text(school.shortName ?? String(school.name.prefix(1)))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            
            // School Info
            VStack(alignment: .leading, spacing: 4) {
                Text(school.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(school.city ?? ""), \(school.state ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Follow Button - plus/checkmark icon
            Button(action: onToggle) {
                Image(systemName: isFollowed ? "checkmark" : "plus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isFollowed ? .white : Color(hex: "6e27e8"))
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(isFollowed ? Color(hex: "6e27e8") : Color.clear)
                            .stroke(isFollowed ? Color(hex: "6e27e8") : Color(hex: "6e27e8"), lineWidth: 2)
                    )
            }
            .padding(.trailing, 8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "28282B"))
        )
    }
}

// Using existing School model from Models/School.swift

#Preview {
    TeamSelectionView()
}
