import SwiftUI
import PhotosUI
import UIKit
import UniformTypeIdentifiers

struct EditProfileView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var selectedBannerItem: PhotosPickerItem? = nil
    @State private var selectedBannerData: Data? = nil
    @State private var isUploading = false
    @State private var showingPhotoOptions = false
    @State private var showingPhotoPicker = false
    @State private var showingDocumentPicker = false
    @State private var showingBannerOptions = false
    @State private var showingBannerPicker = false
    @State private var showingBannerDocumentPicker = false
    
    // Image cropping states
    @State private var showingAvatarCrop = false
    @State private var showingBannerCrop = false
    @State private var imageToCrop: UIImage? = nil
    @State private var bannerToCrop: UIImage? = nil
    
    // Helper computed property for banner view
    private var bannerView: some View {
        Group {
            if let selectedBannerData,
               let uiImage = UIImage(data: selectedBannerData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if let bannerUrl = authManager.currentUser?.bannerUrl,
                      !bannerUrl.isEmpty {
                AsyncImage(url: URL(string: bannerUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // Default banner - no placeholder
                AsyncImage(url: URL(string: "https://hpfxonowaopgclnujptn.supabase.co/storage/v1/object/public/user-assets/banners/defaultuserpic.jpg")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // Helper computed property for avatar view
    private var avatarView: some View {
        Group {
            if let selectedImageData,
               let uiImage = UIImage(data: selectedImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            } else if let currentUrl = authManager.currentUser?.avatarUrl,
                      !currentUrl.isEmpty {
                AsyncImage(url: URL(string: currentUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            } else {
                AsyncImage(url: URL(string: "https://hpfxonowaopgclnujptn.supabase.co/storage/v1/object/public/user-assets/avatars/defaultuserpic.jpg")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            }
        }
    }
    
    // Helper computed property for banner section
    private var bannerSection: some View {
        VStack(spacing: 12) {
            bannerView
            
            Button(action: {
                showingBannerOptions = true
            }) {
                Text(isUploading ? "Uploading..." : "Change Banner")
                    .foregroundColor(Color(hex: "6e27e8"))
                    .font(.subheadline)
            }
            .disabled(isUploading)
            .confirmationDialog("Change Banner", isPresented: $showingBannerOptions, titleVisibility: .visible) {
                Button("Photo Library") {
                    showingBannerPicker = true
                }
                Button("Files") {
                    showingBannerDocumentPicker = true
                }
                Button("Remove Banner", role: .destructive) {
                    selectedBannerData = nil
                    selectedBannerItem = nil
                    Task {
                        // Delete from storage first
                        await authManager.deleteBanner()
                        // Then update profile to default
                        await authManager.updateProfile(
                            displayName: displayName.isEmpty ? nil : displayName,
                            bio: bio.isEmpty ? nil : bio,
                            avatarUrl: nil,
                            bannerUrl: "https://hpfxonowaopgclnujptn.supabase.co/storage/v1/object/public/user-assets/banners/defaultuserpic.jpg"
                        )
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .photosPicker(isPresented: $showingBannerPicker, selection: $selectedBannerItem, matching: .images)
            .sheet(isPresented: $showingBannerDocumentPicker) {
                DocumentPicker { url in
                    if let data = try? Data(contentsOf: url) {
                        selectedBannerData = data
                    }
                    showingBannerDocumentPicker = false
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // Helper computed property for profile picture section
    private var profilePictureSection: some View {
        VStack(spacing: 16) {
            avatarView
            
            Button(action: {
                showingPhotoOptions = true
            }) {
                Text(isUploading ? "Uploading..." : "Change Photo")
                    .foregroundColor(Color(hex: "6e27e8"))
                    .font(.subheadline)
            }
            .disabled(isUploading)
            .confirmationDialog("Change Profile Picture", isPresented: $showingPhotoOptions, titleVisibility: .visible) {
                Button("Photo Library") {
                    showingPhotoPicker = true
                }
                Button("Files") {
                    showingDocumentPicker = true
                }
                Button("Remove Avatar", role: .destructive) {
                    selectedImageData = nil
                    selectedPhotoItem = nil
                    Task {
                        // Delete from storage first
                        await authManager.deleteAvatar()
                        // Then update profile to default
                        await authManager.updateProfile(
                            displayName: displayName.isEmpty ? nil : displayName,
                            bio: bio.isEmpty ? nil : bio,
                            avatarUrl: "https://hpfxonowaopgclnujptn.supabase.co/storage/v1/object/public/user-assets/avatars/defaultuserpic.jpg",
                            bannerUrl: nil
                        )
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker { url in
                    if let data = try? Data(contentsOf: url) {
                        selectedImageData = data
                    }
                    showingDocumentPicker = false
                }
            }
        }
        .padding(.top, 8)
    }
    
    // Helper computed property for form fields
    private var formFieldsSection: some View {
        VStack(spacing: 16) {
            // Display Name Field
            TextField("", text: $displayName, prompt: Text("Display Name").foregroundColor(.gray.opacity(0.6)))
                .padding()
                .background(Color.clear)
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "28282B"), lineWidth: 1)
                )
                .frame(height: 50)
            
            // Bio Field
            TextField("", text: $bio, prompt: Text("Bio").foregroundColor(.gray.opacity(0.6)), axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(Color.clear)
                .foregroundColor(.white)
                .autocapitalization(.none)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "28282B"), lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
    }
    
    // Helper computed property for save button
    private var saveButton: some View {
        Button(action: {
            Task {
                var uploadedAvatarUrl: String? = nil
                var uploadedBannerUrl: String? = nil
                
                print("Save button tapped")
                print("selectedImageData: \(selectedImageData != nil ? "present" : "nil")")
                print("selectedBannerData: \(selectedBannerData != nil ? "present" : "nil")")
                
                // Upload avatar if selected
                if let imageData = selectedImageData {
                    print("Uploading avatar...")
                    isUploading = true
                    uploadedAvatarUrl = await authManager.uploadAvatarImage(imageData: imageData)
                    print("Avatar upload result: \(uploadedAvatarUrl ?? "nil")")
                }
                
                // Upload banner if selected
                if let bannerData = selectedBannerData {
                    print("Uploading banner...")
                    isUploading = true
                    uploadedBannerUrl = await authManager.uploadBannerImage(imageData: bannerData)
                    print("Banner upload result: \(uploadedBannerUrl ?? "nil")")
                }
                
                isUploading = false
                
                print("Updating profile with avatar: \(uploadedAvatarUrl ?? "nil"), banner: \(uploadedBannerUrl ?? "nil")")
                
                await authManager.updateProfile(
                    displayName: displayName.isEmpty ? nil : displayName,
                    bio: bio.isEmpty ? nil : bio,
                    avatarUrl: uploadedAvatarUrl,
                    bannerUrl: uploadedBannerUrl
                )
                if authManager.errorMessage == nil {
                    dismiss()
                }
            }
        }) {
            HStack {
                if authManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text("Save Changes")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(hex: "6e27e8"))
            .cornerRadius(20)
        }
        .disabled(authManager.isLoading)
        .padding(.horizontal, 20)
    }
    
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
                    
                    Text("Edit Profile")
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        bannerSection
                        profilePictureSection
                        formFieldsSection
                        saveButton
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                // Pre-populate fields with current user data
                displayName = authManager.currentUser?.displayName ?? ""
                bio = authManager.currentUser?.bio ?? ""
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    print("Photo item selected, loading data...")
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            imageToCrop = uiImage
                        }
                        print("Photo data loaded and ready for cropping: \(data.count) bytes")
                    } else {
                        print("Failed to load photo data")
                    }
                }
            }
            .onChange(of: selectedBannerItem) { _, newItem in
                Task {
                    print("Banner item selected, loading data...")
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            bannerToCrop = uiImage
                        }
                        print("Banner data loaded and ready for cropping: \(data.count) bytes")
                    } else {
                        print("Failed to load banner data")
                    }
                }
            }
            .fullScreenCover(item: $imageToCrop) { image in
                ImageCropView(
                    image: image,
                    cropShape: .circle,
                    onCrop: { croppedImage in
                        if let croppedData = croppedImage.jpegData(compressionQuality: 0.9) {
                            selectedImageData = croppedData
                        }
                    }
                )
            }
            .fullScreenCover(item: $bannerToCrop) { image in
                ImageCropView(
                    image: image,
                    cropShape: .rectangle,
                    onCrop: { croppedImage in
                        if let croppedData = croppedImage.jpegData(compressionQuality: 0.9) {
                            selectedBannerData = croppedData
                        }
                    }
                )
            }
            .alert("Error", isPresented: .constant(authManager.errorMessage != nil)) {
                Button("OK") {
                    authManager.errorMessage = nil
                }
            } message: {
                Text(authManager.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    EditProfileView()
}

// DocumentPicker for selecting files
struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onPick(url)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
    }
}
