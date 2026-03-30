import Foundation
import Combine
import CryptoKit
import Supabase
import UIKit

@MainActor
final class SimpleAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: SimpleUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userFollows: [UserFollowWithSchool] = []
    
    private let supabase = SupabaseManager.shared.client

    init() {
        // Start unauthenticated - simple approach
        isAuthenticated = false
    }
    
    func signUpWithUsername(username: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Basic validation
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter username, email, and password"
            isLoading = false
            return
        }
        
        guard username.count >= 4 else {
            errorMessage = "Username must be at least 4 characters"
            isLoading = false
            return
        }
        
        // Validate username format
        let usernameRegex = "^[a-zA-Z0-9._-]+$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        guard usernamePredicate.evaluate(with: username) else {
            errorMessage = "Username can only contain letters, numbers, dots, dashes, and underscores"
            isLoading = false
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        // Check if username or email already exists
        do {
            let existingUsers: [SimpleUser] = try await supabase
                .from("simple_users")
                .select()
                .or("username.eq.\(username),email.eq.\(email)")
                .execute()
                .value
            
            if let existingUser = existingUsers.first {
                if existingUser.username == username {
                    errorMessage = "Username already exists"
                } else {
                    errorMessage = "Email already exists"
                }
                isLoading = false
                return
            }
        } catch {
            errorMessage = "Error checking existing users"
            isLoading = false
            return
        }
        
        // Create new user
        do {
            let passwordHash = hashPassword(password)
            let newUserInsert = SimpleUserInsert(
                username: username,
                email: email,
                passwordHash: passwordHash
            )
            
            let insertedUsers: [SimpleUser] = try await supabase
                .from("simple_users")
                .insert(newUserInsert)
                .select()
                .execute()
                .value
            
            if let user = insertedUsers.first {
                currentUser = user
                isAuthenticated = true
                await loadUserFollows()
            }
        } catch {
            print("Database error: \(error)")
            errorMessage = "Error creating account"
        }
        
        isLoading = false
    }

    func signInWithUsername(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Basic validation
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both username and password"
            isLoading = false
            return
        }
        
        // Find user by username
        do {
            let users: [SimpleUser] = try await supabase
                .from("simple_users")
                .select()
                .eq("username", value: username)
                .execute()
                .value
            
            guard let user = users.first else {
                errorMessage = "Username not found"
                isLoading = false
                return
            }
            
            // Verify password
            let passwordHash = hashPassword(password)
            guard user.passwordHash == passwordHash else {
                errorMessage = "Incorrect password"
                isLoading = false
                return
            }
            
            // Sign in successful
            currentUser = user
            isAuthenticated = true
            await loadUserFollows()
        } catch {
            print("Database error: \(error)")
            errorMessage = "Error signing in"
        }
        
        isLoading = false
    }
    
    func signInWithApple() async {
        isLoading = true
        errorMessage = "Apple Sign-In coming soon. Please use username/password for now."
        isLoading = false
    }
    
    func updateProfile(displayName: String?, bio: String?, avatarUrl: String?, bannerUrl: String?) async {
        guard let currentUser = currentUser else {
            errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Update user in database
        do {
            let updateData = SimpleUserUpdate(
                displayName: displayName,
                bio: bio,
                avatarUrl: avatarUrl,
                bannerUrl: bannerUrl,
                updatedAt: ISO8601DateFormatter().string(from: Date())
            )
            
            let updatedUsers: [SimpleUser] = try await supabase
                .from("simple_users")
                .update(updateData)
                .eq("id", value: currentUser.id)
                .select()
                .execute()
                .value
            
            if let updatedUser = updatedUsers.first {
                self.currentUser = updatedUser
            }
        } catch {
            print("Profile update error: \(error)")
            errorMessage = "Error updating profile"
        }
        
        isLoading = false
    }
    
    func uploadAvatarImage(imageData: Data) async -> String? {
        guard let currentUser = currentUser else {
            errorMessage = "Not authenticated"
            return nil
        }
        
        errorMessage = nil
        
        do {
            // Process image: resize and crop to 800x800 square
            guard let processedData = resizeAndCropToSquare(imageData: imageData, targetSize: 800) else {
                errorMessage = "Error processing image"
                return nil
            }
            
            // Use username as filename (e.g., "beetah.jpg")
            let filename = "\(currentUser.username).jpg"
            let filePath = "avatars/\(filename)"
            
            // Upload to Supabase Storage with upsert (overwrites existing)
            try await supabase.storage
                .from("user-assets")
                .upload(filePath, data: processedData, options: FileOptions(upsert: true))
            
            // Get public URL
            let publicURL = try supabase.storage
                .from("user-assets")
                .getPublicURL(path: filePath)
            
            return publicURL.absoluteString
            
        } catch {
            print("Avatar upload error: \(error)")
            errorMessage = "Error uploading profile picture"
            return nil
        }
    }
    
    func uploadBannerImage(imageData: Data) async -> String? {
        guard let currentUser = currentUser else {
            errorMessage = "Not authenticated"
            return nil
        }
        
        errorMessage = nil
        
        do {
            print("Processing banner image for upload...")
            
            // Process banner image: crop to 16:9 and resize to 1920x1080
            guard let processedData = resizeAndCropTo169(imageData: imageData, targetWidth: 1920, targetHeight: 1080) else {
                errorMessage = "Error processing banner"
                print("Banner processing failed")
                return nil
            }
            
            print("Banner processed successfully, size: \(processedData.count) bytes")
            
            // Use username as filename (e.g., "beetah.jpg")
            let filename = "\(currentUser.username).jpg"
            let filePath = "banners/\(filename)"
            
            print("Uploading banner to path: \(filePath)")
            
            // Upload to Supabase Storage with upsert (overwrites existing)
            try await supabase.storage
                .from("user-assets")
                .upload(filePath, data: processedData, options: FileOptions(upsert: true))
            
            print("Banner upload successful")
            
            // Get public URL
            let publicURL = try supabase.storage
                .from("user-assets")
                .getPublicURL(path: filePath)
            
            print("Banner public URL: \(publicURL.absoluteString)")
            
            return publicURL.absoluteString
            
        } catch {
            print("Banner upload error: \(error)")
            errorMessage = "Error uploading banner"
            return nil
        }
    }
    
    // Helper function to resize and crop image to 16:9 aspect ratio
    private func resizeAndCropTo169(imageData: Data, targetWidth: CGFloat, targetHeight: CGFloat) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }
        
        let targetAspectRatio: CGFloat = 16.0 / 9.0 // 16:9 aspect ratio
        let imageAspectRatio = image.size.width / image.size.height
        
        var cropRect: CGRect
        
        if imageAspectRatio > targetAspectRatio {
            // Image is wider than 16:9, crop width
            let newWidth = image.size.height * targetAspectRatio
            let xOffset = (image.size.width - newWidth) / 2
            cropRect = CGRect(x: xOffset, y: 0, width: newWidth, height: image.size.height)
        } else {
            // Image is taller than 16:9, crop height
            let newHeight = image.size.width / targetAspectRatio
            let yOffset = (image.size.height - newHeight) / 2
            cropRect = CGRect(x: 0, y: yOffset, width: image.size.width, height: newHeight)
        }
        
        // Crop to 16:9
        guard let croppedCGImage = image.cgImage?.cropping(to: cropRect) else { return nil }
        let croppedImage = UIImage(cgImage: croppedCGImage)
        
        // Resize to target size (1920x1080)
        let size = CGSize(width: targetWidth, height: targetHeight)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        croppedImage.draw(in: CGRect(origin: .zero, size: size))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        // Convert to JPEG data with 90% quality
        return resizedImage.jpegData(compressionQuality: 0.9)
    }
    
    // Helper function to resize and crop image to a square
    private func resizeAndCropToSquare(imageData: Data, targetSize: CGFloat) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }
        
        // Calculate crop rect to make it square (center crop)
        let minDimension = min(image.size.width, image.size.height)
        let xOffset = (image.size.width - minDimension) / 2
        let yOffset = (image.size.height - minDimension) / 2
        let cropRect = CGRect(x: xOffset, y: yOffset, width: minDimension, height: minDimension)
        
        // Crop to square
        guard let croppedCGImage = image.cgImage?.cropping(to: cropRect) else { return nil }
        let croppedImage = UIImage(cgImage: croppedCGImage)
        
        // Resize to target size
        let size = CGSize(width: targetSize, height: targetSize)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        croppedImage.draw(in: CGRect(origin: .zero, size: size))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        // Convert to JPEG data with 90% quality
        return resizedImage.jpegData(compressionQuality: 0.9)
    }
    
    func deleteAvatar() async {
        guard let currentUser = currentUser else { 
            print("Delete avatar failed: No current user")
            return 
        }
        
        do {
            let filename = "\(currentUser.username).jpg"
            let filePath = "avatars/\(filename)"
            
            print("Deleting avatar at path: \(filePath)")
            
            try await supabase.storage
                .from("user-assets")
                .remove(paths: [filePath])
            
            print("Avatar deleted successfully")
        } catch {
            print("Avatar delete error: \(error)")
        }
    }
    
    func deleteBanner() async {
        guard let currentUser = currentUser else { 
            print("Delete banner failed: No current user")
            return 
        }
        
        do {
            let filename = "\(currentUser.username).jpg"
            let filePath = "banners/\(filename)"
            
            print("Deleting banner at path: \(filePath)")
            
            try await supabase.storage
                .from("user-assets")
                .remove(paths: [filePath])
            
            print("Banner deleted successfully")
        } catch {
            print("Banner delete error: \(error)")
        }
    }
    
    func loadUserFollows() async {
        guard let currentUser = currentUser else { return }
        
        do {
            // Fetch follows with school data using join
            let response = try await supabase
                .from("user_follows")
                .select("""
                    id,
                    user_id,
                    school_id,
                    followed_at,
                    notifications_enabled,
                    schools:school_id (
                        id,
                        name,
                        short_name,
                        city,
                        state,
                        mascot,
                        primary_color,
                        secondary_color,
                        logo_path
                    )
                """)
                .eq("user_id", value: currentUser.id)
                .execute()
            
            let follows = try JSONDecoder().decode([UserFollowWithSchool].self, from: response.data)
            userFollows = follows
        } catch {
            print("Error loading user follows: \(error)")
        }
    }
    
    func signOut() async {
        currentUser = nil
        isAuthenticated = false
    }
    
    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// Simple user models
struct SimpleUser: Codable, Identifiable {
    let id: UUID
    let username: String
    let email: String
    let passwordHash: String
    let displayName: String?
    let bio: String?
    let avatarUrl: String?
    let bannerUrl: String?
    let createdAt: String
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case passwordHash = "password_hash"
        case displayName = "display_name"
        case bio
        case avatarUrl = "avatar_url"
        case bannerUrl = "banner_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SimpleUserInsert: Codable {
    let username: String
    let email: String
    let passwordHash: String
    
    enum CodingKeys: String, CodingKey {
        case username, email
        case passwordHash = "password_hash"
    }
}

struct SimpleUserUpdate: Codable {
    let displayName: String?
    let bio: String?
    let avatarUrl: String?
    let bannerUrl: String?
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case bio
        case avatarUrl = "avatar_url"
        case bannerUrl = "banner_url"
        case updatedAt = "updated_at"
    }
}

struct UserFollowWithSchool: Decodable, Identifiable {
    let id: UUID
    let userId: UUID
    let schoolId: UUID
    let followedAt: String
    let notificationsEnabled: Bool
    let school: School?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case schoolId = "school_id"
        case followedAt = "followed_at"
        case notificationsEnabled = "notifications_enabled"
        case school = "schools"
    }
}

struct SimpleUserFollow: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let schoolId: UUID
    let followedAt: String
    let notificationsEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case schoolId = "school_id"
        case followedAt = "followed_at"
        case notificationsEnabled = "notifications_enabled"
    }
}

struct SimpleUserFollowInsert: Codable {
    let userId: UUID
    let schoolId: UUID
    let notificationsEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case schoolId = "school_id"
        case notificationsEnabled = "notifications_enabled"
    }
}
