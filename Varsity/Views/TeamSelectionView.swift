import SwiftUI
import Supabase

struct TeamSelectionView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var followedTeams: Set<UUID> = []
    @State private var availableSchools: [School] = []
    @State private var filteredSchools: [School] = []
    @State private var searchText: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "17171B").ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                                        isFollowed: followedTeams.contains(school.id),
                                        onToggle: {
                                            toggleTeamFollow(school: school)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                    }
                }
            }
            .navigationTitle("Manage Following")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "17171B"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                loadTeamsAndFollowing()
            }
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
        // Mock followed schools - first school is followed by default
        await MainActor.run {
            followedTeams = Set([availableSchools.first?.id].compactMap { $0 })
        }
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
        // Simple toggle for mock data
        if followedTeams.contains(school.id) {
            followedTeams.remove(school.id)
        } else {
            followedTeams.insert(school.id)
        }
    }
}

struct TeamRowView: View {
    let school: School
    let isFollowed: Bool
    let onToggle: () -> Void
    
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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isFollowed ? .white : Color(hex: "6e27e8"))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(isFollowed ? Color(hex: "6e27e8") : Color.clear)
                            .stroke(isFollowed ? Color(hex: "6e27e8") : Color(hex: "6e27e8"), lineWidth: 2)
                    )
            }
        }
        .padding()
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
