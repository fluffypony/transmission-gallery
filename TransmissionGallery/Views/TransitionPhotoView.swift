import SwiftUI

struct TransitionPhotoView: View {
    let photo: Photo
    let allPhotos: [Photo]
    let viewModel: PhotoGalleryViewModel
    
    @State private var isPresented = false
    @State private var selectedPhoto: Photo?
    
    var body: some View {
        PhotoThumbnailView(photo: photo, viewModel: viewModel)
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .onTapGesture {
                selectedPhoto = photo
                isPresented = true
            }
            .fullScreenCover(isPresented: $isPresented) {
                FullscreenPhotoView(
                    photo: photo,
                    allPhotos: allPhotos,
                    selectedPhoto: $selectedPhoto
                )
                .onDisappear {
                    selectedPhoto = nil
                }
            }
    }
}

struct TransmissionFullscreenView: View {
    let photo: Photo
    let allPhotos: [Photo]
    @Binding var isPresented: Bool
    
    @State private var currentIndex: Int
    
    init(photo: Photo, allPhotos: [Photo], isPresented: Binding<Bool>) {
        self.photo = photo
        self.allPhotos = allPhotos
        self._isPresented = isPresented
        self._currentIndex = State(initialValue: allPhotos.firstIndex(where: { $0.id == photo.id }) ?? 0)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(Array(allPhotos.enumerated()), id: \.element.id) { index, photo in
                    PhotoDetailView(photo: photo)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                    
                    Text("\(currentIndex + 1) of \(allPhotos.count)")
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
    }
}

#Preview {
    Rectangle()
        .fill(Color.gray.opacity(0.3))
        .frame(width: 120, height: 120)
        .cornerRadius(8)
}
