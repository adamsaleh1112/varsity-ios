import SwiftUI
import UIKit

struct ImageCropView: View {
    @Environment(\.dismiss) var dismiss
    let image: UIImage
    let cropShape: CropShape
    let onCrop: (UIImage) -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var imageSize: CGSize = .zero
    
    enum CropShape {
        case circle // For avatar
        case rectangle // For banner
        
        var aspectRatio: CGFloat {
            switch self {
            case .circle: return 1.0
            case .rectangle: return 3.0 / 1.0 // Banner aspect ratio
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(cropShape == .circle ? "Edit Avatar" : "Edit Banner")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Done") {
                        let croppedImage = cropImage()
                        onCrop(croppedImage)
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "6e27e8"))
                    .fontWeight(.semibold)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                Spacer()
                
                // Image Editor
                GeometryReader { geometry in
                    let containerSize = geometry.size
                    let cropSize = calculateCropSize(containerSize: containerSize)
                    
                    ZStack {
                        // Background dimming
                        Color.black.opacity(0.5)
                            .mask(
                                Rectangle()
                                    .overlay(
                                        cropOverlay(size: cropSize, shape: cropShape)
                                            .blendMode(.destinationOut)
                                    )
                            )
                        
                        // Draggable Image
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageSize.width * scale, height: imageSize.height * scale)
                            .position(
                                x: containerSize.width / 2 + offset.width,
                                y: containerSize.height / 2 + offset.height
                            )
                            .gesture(
                                SimultaneousGesture(
                                    // Pan gesture
                                    DragGesture()
                                        .onChanged { value in
                                            let newOffset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                            offset = constrainOffset(newOffset, cropSize: cropSize, containerSize: containerSize)
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        },
                                    // Zoom gesture
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let newScale = lastScale * value
                                            scale = min(max(newScale, 0.5), 5.0)
                                        }
                                        .onEnded { _ in
                                            lastScale = scale
                                            // Re-constrain offset after zoom
                                            offset = constrainOffset(offset, cropSize: cropSize, containerSize: containerSize)
                                            lastOffset = offset
                                        }
                                )
                            )
                        
                        // Crop Overlay Border
                        cropOverlay(size: cropSize, shape: cropShape)
                    }
                    .onAppear {
                        setupInitialState(containerSize: containerSize)
                    }
                }
                
                Spacer()
                
                // Instructions
                Text("Pinch to zoom, drag to move")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
            }
        }
    }
    
    private func calculateCropSize(containerSize: CGSize) -> CGSize {
        let maxWidth = containerSize.width - 40
        let maxHeight = containerSize.height - 100
        
        switch cropShape {
        case .circle:
            let size = min(maxWidth, maxHeight, 300)
            return CGSize(width: size, height: size)
        case .rectangle:
            let width = maxWidth
            let height = width / cropShape.aspectRatio
            return CGSize(width: width, height: min(height, maxHeight))
        }
    }
    
    @ViewBuilder
    private func cropOverlay(size: CGSize, shape: CropShape) -> some View {
        switch shape {
        case .circle:
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: size.width, height: size.height)
        case .rectangle:
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 2)
                .frame(width: size.width, height: size.height)
        }
    }
    
    private func setupInitialState(containerSize: CGSize) {
        let cropSize = calculateCropSize(containerSize: containerSize)
        
        // Calculate initial image size to fit within crop area
        let imageAspect = image.size.width / image.size.height
        let cropAspect = cropSize.width / cropSize.height
        
        if imageAspect > cropAspect {
            // Image is wider, fit to height
            imageSize = CGSize(width: cropSize.height * imageAspect, height: cropSize.height)
        } else {
            // Image is taller, fit to width
            imageSize = CGSize(width: cropSize.width, height: cropSize.width / imageAspect)
        }
        
        // Set minimum scale to ensure image fills crop area
        let scaleX = cropSize.width / (image.size.width * (imageSize.width / image.size.width))
        let scaleY = cropSize.height / (image.size.height * (imageSize.height / image.size.height))
        scale = max(scaleX, scaleY)
        lastScale = scale
    }
    
    private func constrainOffset(_ offset: CGSize, cropSize: CGSize, containerSize: CGSize) -> CGSize {
        let scaledImageWidth = imageSize.width * scale
        let scaledImageHeight = imageSize.height * scale
        
        let maxOffsetX = max(0, (scaledImageWidth - cropSize.width) / 2)
        let maxOffsetY = max(0, (scaledImageHeight - cropSize.height) / 2)
        
        return CGSize(
            width: min(max(offset.width, -maxOffsetX), maxOffsetX),
            height: min(max(offset.height, -maxOffsetY), maxOffsetY)
        )
    }
    
    private func cropImage() -> UIImage {
        let containerSize = CGSize(width: UIScreen.main.bounds.width, 
                                   height: UIScreen.main.bounds.height - 150)
        let cropSize = calculateCropSize(containerSize: containerSize)
        
        let scaledImageWidth = imageSize.width * scale
        let scaledImageHeight = imageSize.height * scale
        
        // Calculate the crop rect in the scaled image coordinates
        let cropX = (scaledImageWidth - cropSize.width) / 2 - offset.width
        let cropY = (scaledImageHeight - cropSize.height) / 2 - offset.height
        
        // Convert to original image coordinates
        let scaleFactor = image.size.width / scaledImageWidth
        let finalCropRect = CGRect(
            x: cropX * scaleFactor,
            y: cropY * scaleFactor,
            width: cropSize.width * scaleFactor,
            height: cropSize.height * scaleFactor
        )
        
        // Perform the crop
        guard let cgImage = image.cgImage else { return image }
        
        // Ensure crop rect is within image bounds
        let boundedRect = CGRect(
            x: max(0, min(finalCropRect.origin.x, image.size.width - 1)),
            y: max(0, min(finalCropRect.origin.y, image.size.height - 1)),
            width: min(finalCropRect.width, image.size.width - finalCropRect.origin.x),
            height: min(finalCropRect.height, image.size.height - finalCropRect.origin.y)
        )
        
        guard let croppedCGImage = cgImage.cropping(to: boundedRect) else { return image }
        let croppedImage = UIImage(cgImage: croppedCGImage)
        
        // For circular avatars, apply circular mask
        if cropShape == .circle {
            return applyCircularMask(to: croppedImage)
        }
        
        return croppedImage
    }
    
    private func applyCircularMask(to image: UIImage) -> UIImage {
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // Create circular path
            let path = UIBezierPath(ovalIn: rect)
            path.addClip()
            
            // Draw the image
            image.draw(in: rect)
        }
    }
}

#Preview {
    ImageCropView(
        image: UIImage(systemName: "person.fill")!,
        cropShape: .circle,
        onCrop: { _ in }
    )
}
