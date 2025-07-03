import SwiftUI

struct FullscreenPhotoView: View {
    let photo: Photo
    let allPhotos: [Photo]
    @Binding var selectedPhoto: Photo?
    
    @State private var fullImage: UIImage?
    @State private var isLoading = true
    @State private var currentIndex: Int
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    
    private let photoService = PhotoService.shared
    
    init(photo: Photo, allPhotos: [Photo], selectedPhoto: Binding<Photo?>) {
        self.photo = photo
        self.allPhotos = allPhotos
        self._selectedPhoto = selectedPhoto
        self._currentIndex = State(initialValue: allPhotos.firstIndex(where: { $0.id == photo.id }) ?? 0)
    }
    
    var currentPhoto: Photo {
        guard currentIndex >= 0 && currentIndex < allPhotos.count else {
            return photo
        }
        return allPhotos[currentIndex]
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
                        selectedPhoto = nil
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

struct PhotoDetailView: View {
    let photo: Photo
    @State private var fullImage: UIImage?
    @State private var isLoading = true
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let photoService = PhotoService.shared
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let fullImage = fullImage {
                    Image(uiImage: fullImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = max(1.0, min(value, 5.0))
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        if scale > 1.0 {
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                        
                                        // Bounce back to bounds
                                        let maxX = (geometry.size.width * (scale - 1)) / 2
                                        let maxY = (geometry.size.height * (scale - 1)) / 2
                                        
                                        withAnimation(.spring()) {
                                            offset.width = max(-maxX, min(maxX, offset.width))
                                            offset.height = max(-maxY, min(maxY, offset.height))
                                        }
                                        
                                        lastOffset = offset
                                    }
                            )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = 2.0
                                }
                            }
                        }
                } else if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task {
            await loadFullImage()
        }
    }
    
    private func loadFullImage() async {
        isLoading = true
        fullImage = await photoService.loadFullImage(for: photo)
        isLoading = false
    }
}

#Preview {
    // Preview with sample data
    Text("Fullscreen Photo View")
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
}
