import SwiftUI

struct UserSettingsView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "17171B").ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Sign Out Button
                    Button(action: {
                        authManager.signOut()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 30)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    UserSettingsView()
}
