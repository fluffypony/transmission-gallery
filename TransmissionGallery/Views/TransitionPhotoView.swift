import SwiftUI
import Transmission

struct TransitionPhotoView: View {
    let photo: Photo
    let allPhotos: [Photo]
    let viewModel: PhotoGalleryViewModel
    
    var body: some View {
        PresentationLink(
            transition: .matchedGeometry(
                preferredFromCornerRadius: .rounded(cornerRadius: 8),
                prefersScaleEffect: false,
                isInteractive: true
            )
        ) {
            FullscreenPhotoView(
                photo: photo,
                allPhotos: allPhotos,
                selectedPhoto: .constant(nil)
            )
        } label: {
            PhotoThumbnailView(photo: photo, viewModel: viewModel)
        }
    }
}

#Preview {
    Rectangle()
        .fill(Color.gray.opacity(0.3))
        .frame(width: 120, height: 120)
        .cornerRadius(8)
}
