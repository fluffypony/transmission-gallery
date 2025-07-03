import SwiftUI
import Photos

struct PhotoGridView: View {
    @StateObject private var viewModel = PhotoGalleryViewModel()
    
    private let columns = [
        GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 2),
    ]
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.authorizationStatus {
                case .authorized, .limited:
                    photoGrid
                case .denied, .restricted:
                    PermissionDeniedView()
                case .notDetermined:
                    PermissionRequestView {
                        Task {
                            await viewModel.requestPhotoAccess()
                        }
                    }
                @unknown default:
                    PermissionRequestView {
                        Task {
                            await viewModel.requestPhotoAccess()
                        }
                    }
                }
            }
            .navigationTitle("Photos")
            .refreshable {
                await viewModel.refreshPhotos()
            }
        }
        .task {
            if viewModel.authorizationStatus == .authorized || viewModel.authorizationStatus == .limited {
                await viewModel.loadPhotos()
            }
        }
    }
    
    private var photoGrid: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading photos...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else if viewModel.photos.isEmpty {
                EmptyStateView()
            } else {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(viewModel.photos) { photo in
                        TransitionPhotoView(
                            photo: photo, 
                            allPhotos: viewModel.photos,
                            viewModel: viewModel
                        )
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
}

#Preview {
    PhotoGridView()
}
