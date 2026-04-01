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
    
    // Combined header section with full-width banner and centered overlapping PFP
    private var headerSection: some View {
        ZStack(alignment: .top) {
            // Full-width banner (tappable)
            Button(action: {
                showingBannerOptions = true
            }) {
                Group {
                    if let selectedBannerData,
                       let uiImage = UIImage(data: selectedBannerData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if let bannerUrl = authManager.currentUser?.bannerUrl,
                              !bannerUrl.isEmpty {
                        AsyncImage(url: URL(string: bannerUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                    } else {
                        Rectangle()
                            .fill(Color(hex: "28282B"))
                    }
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())

            // Centered profile picture overlapping banner with half hanging off
            Button(action: {
                showingPhotoOptions = true
            }) {
                Group {
                    if let selectedImageData,
                       let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
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
                        }
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(width: 100, height: 100)
                .background(Color(hex: "17171B"))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(hex: "17171B"), lineWidth: 4)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 140) // Position so half overlaps banner, half hangs below
            .padding(.bottom, 50)
        }
        .frame(height: 190) // Total height: 140 banner + 50px of PFP hanging below
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
                    await authManager.deleteBanner()
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
                    await authManager.deleteAvatar()
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
    
    // Helper computed property for form fields with labels on left and inputs on right
    private var formFieldsSection: some View {
        VStack(spacing: 0) {
            // Name field row
            HStack(spacing: 16) {
                Text("Name")
                    .font(.body)
                    .foregroundColor(.gray)
                    .frame(width: 60, alignment: .leading)
                
                TextField("", text: $displayName, prompt: Text("Add your name").foregroundColor(.gray.opacity(0.6)))
                    .font(.body)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
                .background(Color(hex: "28282B"))
                .padding(.leading, 20)
            
            // Bio field row
            HStack(alignment: .top, spacing: 16) {
                Text("Bio")
                    .font(.body)
                    .foregroundColor(.gray)
                    .frame(width: 60, alignment: .leading)
                
                TextField("", text: $bio, prompt: Text("Add a bio to your profile").foregroundColor(.gray.opacity(0.6)), axis: .vertical)
                    .font(.body)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .lineLimit(1...4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
                .background(Color(hex: "28282B"))
        }
        .background(Color(hex: "17171B"))
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
                    VStack(spacing: 0) {
                        headerSection
                        
                        // 20px padding under PFP, then divider
                        Divider()
                            .background(Color(hex: "28282B"))
                            .padding(.top, 20)
                        
                        formFieldsSection
                        saveButton
                            .padding(.top, 30)
                        
                        Spacer(minLength: 50)
                    }
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
            .fullScreenCover(isPresented: .init(
                get: { imageToCrop != nil },
                set: { if !$0 { imageToCrop = nil } }
            )) {
                if let image = imageToCrop {
                    ImageCropView(
                        image: image,
                        cropShape: .circle,
                        onCrop: { croppedImage in
                            if let croppedData = croppedImage.jpegData(compressionQuality: 0.9) {
                                selectedImageData = croppedData
                            }
                            imageToCrop = nil
                        }
                    )
                }
            }
            .fullScreenCover(isPresented: .init(
                get: { bannerToCrop != nil },
                set: { if !$0 { bannerToCrop = nil } }
            )) {
                if let image = bannerToCrop {
                    ImageCropView(
                        image: image,
                        cropShape: .rectangle,
                        onCrop: { croppedImage in
                            if let croppedData = croppedImage.jpegData(compressionQuality: 0.9) {
                                selectedBannerData = croppedData
                            }
                            bannerToCrop = nil
                        }
                    )
                }
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
