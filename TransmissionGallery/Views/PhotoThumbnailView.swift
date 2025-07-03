import SwiftUI

struct PhotoThumbnailView: View {
    let photo: Photo
    let viewModel: PhotoGalleryViewModel
    
    @State private var thumbnailImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let thumbnailImage = thumbnailImage {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await loadThumbnail()
        }
    }
    
    private func loadThumbnail() async {
        isLoading = true
        thumbnailImage = await viewModel.loadThumbnail(for: photo)
        isLoading = false
    }
}

#Preview {
    // Preview requires a sample photo - this will be handled in the main app
    Rectangle()
        .fill(Color.gray.opacity(0.3))
        .frame(width: 120, height: 120)
}
