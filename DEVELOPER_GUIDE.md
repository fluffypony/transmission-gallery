# Developer Guide

This guide provides technical details for developers working with or extending TransmissionGallery.

## Architecture Overview

TransmissionGallery follows MVVM (Model-View-ViewModel) pattern with SwiftUI:

- **Models**: Data structures wrapping PhotoKit entities
- **Views**: SwiftUI declarative UI components  
- **ViewModels**: Observable state management with Combine
- **Services**: Business logic and data access layer

## Core Components

### Photo Model

The [`Photo`](file:///Users/ric/Desktop/working/transmission-gallery/TransmissionGallery/Models/Photo.swift) struct wraps `PHAsset` with additional functionality:

```swift
// SOURCE: TransmissionGallery/Models/Photo.swift:5-16
struct Photo: Identifiable, Hashable {
    let id: String
    let asset: PHAsset
    var thumbnail: UIImage?
    var fullImage: UIImage?
    
    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.thumbnail = nil
        self.fullImage = nil
    }
}
```

Key properties:
- `id`: Unique identifier from `PHAsset.localIdentifier`
- `asset`: Reference to PhotoKit asset
- `creationDate`: Asset creation date
- `mediaType`: Photo/video type
- `aspectRatio`: Calculated width/height ratio

### PhotoService

[`PhotoService`](file:///Users/ric/Desktop/working/transmission-gallery/TransmissionGallery/Services/PhotoService.swift) handles PhotoKit integration:

```swift
// SOURCE: TransmissionGallery/Services/PhotoService.swift:15-29
func fetchPhotos() async -> [Photo] {
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
    
    let assets = PHAsset.fetchAssets(with: fetchOptions)
    var photos: [Photo] = []
    
    assets.enumerateObjects { asset, _, _ in
        let photo = Photo(asset: asset)
        photos.append(photo)
    }
    
    return photos
}
```

Image loading with caching:

```swift
// SOURCE: TransmissionGallery/Services/PhotoService.swift:31-38
func loadThumbnail(for photo: Photo) async -> UIImage? {
    let cacheKey = "\(photo.id)_thumbnail"
    
    // Check cache first
    if let cachedImage = ImageCache.shared.getThumbnail(forKey: cacheKey) {
        return cachedImage
    }
    
    // Load from PhotoKit...
}
```

### PhotoGalleryViewModel

[`PhotoGalleryViewModel`](file:///Users/ric/Desktop/working/transmission-gallery/TransmissionGallery/ViewModels/PhotoGalleryViewModel.swift) manages application state:

```swift
// SOURCE: TransmissionGallery/ViewModels/PhotoGalleryViewModel.swift:6-12
@MainActor
class PhotoGalleryViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isLoading = false
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
    private let photoService = PhotoService.shared
}
```

Permission handling:

```swift
// SOURCE: TransmissionGallery/ViewModels/PhotoGalleryViewModel.swift:22-29
func requestPhotoAccess() async {
    let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    authorizationStatus = status
    
    if status == .authorized || status == .limited {
        await loadPhotos()
    }
}
```

### ImageCache

[`ImageCache`](file:///Users/ric/Desktop/working/transmission-gallery/TransmissionGallery/Services/ImageCache.swift) provides memory-efficient caching:

```swift
// SOURCE: TransmissionGallery/Services/ImageCache.swift:15-23
private func setupCaches() {
    // Thumbnail cache - smaller images, more entries
    thumbnailCache.countLimit = 500
    thumbnailCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    
    // Full image cache - larger images, fewer entries
    fullImageCache.countLimit = 50
    fullImageCache.totalCostLimit = 100 * 1024 * 1024 // 100MB
}
```

Automatic memory management:

```swift
// SOURCE: TransmissionGallery/Services/ImageCache.swift:25-33
private func observeMemoryWarnings() {
    NotificationCenter.default.addObserver(
        forName: UIApplication.didReceiveMemoryWarningNotification,
        object: nil,
        queue: .main
    ) { [weak self] _ in
        self?.clearCaches()
    }
}
```

### PhotoGridView

[`PhotoGridView`](file:///Users/ric/Desktop/working/transmission-gallery/TransmissionGallery/Views/PhotoGridView.swift) implements the main UI:

Grid configuration:
```swift
// SOURCE: TransmissionGallery/Views/PhotoGridView.swift:7-9
private let columns = [
    GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 2),
]
```

Permission-based UI:
```swift
// SOURCE: TransmissionGallery/Views/PhotoGridView.swift:14-31
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
```

## Configuration

### Image Sizes

Modify thumbnail and high-quality image sizes in [`PhotoService`](file:///Users/ric/Desktop/working/transmission-gallery/TransmissionGallery/Services/PhotoService.swift):

```swift
// SOURCE: TransmissionGallery/Services/PhotoService.swift:10-11
private let thumbnailSize = CGSize(width: 300, height: 300)
private let highQualitySize = CGSize(width: 1024, height: 1024)
```

### Cache Limits

Adjust memory limits in [`ImageCache`](file:///Users/ric/Desktop/working/transmission-gallery/TransmissionGallery/Services/ImageCache.swift):

```swift
// Thumbnail cache configuration
thumbnailCache.countLimit = 500
thumbnailCache.totalCostLimit = 50 * 1024 * 1024 // 50MB

// Full image cache configuration  
fullImageCache.countLimit = 50
fullImageCache.totalCostLimit = 100 * 1024 * 1024 // 100MB
```

### Grid Layout

Modify grid columns in [`PhotoGridView`](file:///Users/ric/Desktop/working/transmission-gallery/TransmissionGallery/Views/PhotoGridView.swift):

```swift
// Current: Adaptive grid with 120-200pt columns
private let columns = [
    GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 2),
]

// Alternative: Fixed 3-column grid
private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
```

## Key Implementation Details

### Async/Await Pattern

All image loading uses modern Swift concurrency:

```swift
// PhotoService uses withCheckedContinuation to bridge PHImageManager callbacks
let image = await withCheckedContinuation { continuation in
    imageManager.requestImage(for: photo.asset, ...) { image, _ in
        continuation.resume(returning: image)
    }
}
```

### MainActor Usage

UI-related classes are marked with `@MainActor` to ensure main thread execution:

```swift
@MainActor
class PhotoService: ObservableObject { ... }

@MainActor  
class PhotoGalleryViewModel: ObservableObject { ... }
```

### Memory Management

- Automatic cache eviction on memory warnings
- Separate thumbnail and full image caches with different limits
- Cost-based caching using estimated memory usage

### Permission Handling

- Graceful handling of all PhotoKit authorization states
- Automatic photo loading when permissions granted
- User-friendly permission request views

## Extension Points

### Custom Photo Filters

Extend `PhotoService.fetchPhotos()` to support filtering:

```swift
func fetchPhotos(mediaType: PHAssetMediaType = .image, 
                 creationDateRange: DateInterval? = nil) async -> [Photo] {
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    
    var predicates: [NSPredicate] = [
        NSPredicate(format: "mediaType == %d", mediaType.rawValue)
    ]
    
    if let dateRange = creationDateRange {
        predicates.append(NSPredicate(format: "creationDate >= %@ AND creationDate <= %@", 
                                    dateRange.start as NSDate, dateRange.end as NSDate))
    }
    
    fetchOptions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    // ... rest of implementation
}
```

### Custom Grid Layouts

Create alternative grid configurations:

```swift
// Pinterest-style grid
private let staggeredColumns = [
    GridItem(.adaptive(minimum: 150), spacing: 4),
    GridItem(.adaptive(minimum: 150), spacing: 4)
]

// Large preview grid
private let largeThumbnailColumns = [
    GridItem(.adaptive(minimum: 250, maximum: 400), spacing: 8)
]
```

## Performance Considerations

1. **Lazy Loading**: Images load only when visible in ScrollView
2. **Background Processing**: Image loading happens off main thread
3. **Cache Efficiency**: Separate caches prevent thumbnail/full image conflicts
4. **Memory Warnings**: Automatic cache clearing prevents crashes
5. **SwiftUI Optimization**: Use of `LazyVGrid` for efficient scrolling
