import SwiftUI
import Transmission

struct TransitionPhotoView: View {
    let photo: Photo
    let allPhotos: [Photo]
    let viewModel: PhotoGalleryViewModel
    
    @State private var isPresented = false
    @State private var selectedPhoto: Photo?
    
    var body: some View {
        ZStack {
            PhotoThumbnailView(photo: photo, viewModel: viewModel)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
        .onTapGesture {
            selectedPhoto = photo
            isPresented = true
        }
        .presentation(
            transition: .matchedGeometry(
                preferredFromCornerRadius: .rounded(cornerRadius: 8),
                prefersScaleEffect: false,
                isInteractive: true
            ),
            isPresented: $isPresented
        ) {
            FullscreenPhotoView(
                photo: photo,
                allPhotos: allPhotos,
                selectedPhoto: $selectedPhoto
            )
        }
        .onChange(of: selectedPhoto) { _, newValue in
            if newValue == nil {
                isPresented = false
            }
        }
    }
}

#Preview {
    Rectangle()
        .fill(Color.gray.opacity(0.3))
        .frame(width: 120, height: 120)
        .cornerRadius(8)
}
