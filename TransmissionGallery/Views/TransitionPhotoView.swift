import SwiftUI
import Transmission

struct TransitionPhotoView: View {
    let photo: Photo
    let allPhotos: [Photo]
    let viewModel: PhotoGalleryViewModel
    
    @State private var selectedPhoto: Photo?
    
    var body: some View {
        PresentationSourceViewLink(
            transition: .matchedGeometry(
                preferredFromCornerRadius: .rounded(cornerRadius: 8),
                prefersScaleEffect: false,
                minimumScaleFactor: 1.0,
                isInteractive: true
            )
        ) {
            FullscreenPhotoView(
                photo: photo,
                allPhotos: allPhotos,
                selectedPhoto: $selectedPhoto
            )
        } label: {
            PhotoThumbnailView(photo: photo, viewModel: viewModel)
                .aspectRatio(1, contentMode: .fit)
                .clipped()
        }
    }
}

#Preview {
    Rectangle()
        .fill(Color.gray.opacity(0.3))
        .frame(width: 120, height: 120)
        .cornerRadius(8)
}
