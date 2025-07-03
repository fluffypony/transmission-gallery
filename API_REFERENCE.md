# API Reference

Technical reference for all public APIs in TransmissionGallery.

## Photo Model

### Photo

```swift
struct Photo: Identifiable, Hashable
```

Wrapper for `PHAsset` with caching support.

#### Properties

```swift
let id: String                    // Unique identifier from PHAsset.localIdentifier
let asset: PHAsset               // PhotoKit asset reference
var thumbnail: UIImage?          // Cached thumbnail image
var fullImage: UIImage?          // Cached full-resolution image
```

#### Computed Properties

```swift
var creationDate: Date?          // Asset creation date
var mediaType: PHAssetMediaType  // Photo/video/audio type
var pixelWidth: Int              // Image width in pixels
var pixelHeight: Int             // Image height in pixels  
var aspectRatio: CGFloat         // Width/height ratio
```

#### Initializers

```swift
init(asset: PHAsset)
```

Creates Photo wrapper from PHAsset.

**Parameters:**
- `asset`: PhotoKit asset to wrap

**Implementation:**
```swift
// SOURCE: TransmissionGallery/Models/Photo.swift:11-16
init(asset: PHAsset) {
    self.id = asset.localIdentifier
    self.asset = asset
    self.thumbnail = nil
    self.fullImage = nil
}
```

## PhotoService

### PhotoService

```swift
@MainActor
class PhotoService: ObservableObject
```

Singleton service for PhotoKit integration and image loading.

#### Static Properties

```swift
static let shared: PhotoService
```

Shared singleton instance.

#### Methods

##### fetchPhotos()

```swift
func fetchPhotos() async -> [Photo]
```

Fetches all photos from device photo library.

**Returns:** Array of Photo objects sorted by creation date (newest first)

**Implementation:**
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

##### loadThumbnail(for:)

```swift
func loadThumbnail(for photo: Photo) async -> UIImage?
```

Loads thumbnail image with caching.

**Parameters:**
- `photo`: Photo to load thumbnail for

**Returns:** Thumbnail UIImage or nil if loading fails

**Cache Key Format:** `"{photo.id}_thumbnail"`

**Target Size:** 300x300 points (from `thumbnailSize` property)

##### loadFullImage(for:)

```swift
func loadFullImage(for photo: Photo) async -> UIImage?
```

Loads full-resolution image with caching.

**Parameters:**
- `photo`: Photo to load full image for

**Returns:** Full-resolution UIImage or nil if loading fails

**Cache Key Format:** `"{photo.id}_full"`

**Target Size:** `PHImageManagerMaximumSize`

##### loadHighQualityImage(for:)

```swift
func loadHighQualityImage(for photo: Photo) async -> UIImage?
```

Loads high-quality image without caching.

**Parameters:**
- `photo`: Photo to load high-quality image for

**Returns:** High-quality UIImage or nil if loading fails

**Target Size:** 1024x1024 points (from `highQualitySize` property)

## PhotoGalleryViewModel

### PhotoGalleryViewModel

```swift
@MainActor
class PhotoGalleryViewModel: ObservableObject
```

Main view model managing photo gallery state.

#### Published Properties

```swift
@Published var photos: [Photo] = []
@Published var isLoading = false
@Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
@Published var errorMessage: String?
```

#### Methods

##### checkAuthorizationStatus()

```swift
func checkAuthorizationStatus()
```

Updates `authorizationStatus` with current PhotoKit permission status.

**Implementation:**
```swift
// SOURCE: TransmissionGallery/ViewModels/PhotoGalleryViewModel.swift:18-20
func checkAuthorizationStatus() {
    authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
}
```

##### requestPhotoAccess()

```swift
func requestPhotoAccess() async
```

Requests photo library access and loads photos if granted.

**Implementation:**
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

##### loadPhotos()

```swift
func loadPhotos() async
```

Loads photos from PhotoService if authorized.

**Behavior:**
- Sets `isLoading = true` during fetch
- Clears `errorMessage` 
- Updates `photos` array
- Sets `isLoading = false` when complete

##### refreshPhotos()

```swift
func refreshPhotos() async
```

Refreshes photo list by calling `loadPhotos()`.

##### loadThumbnail(for:)

```swift
func loadThumbnail(for photo: Photo) async -> UIImage?
```

Delegates to `PhotoService.loadThumbnail(for:)`.

##### loadFullImage(for:)

```swift
func loadFullImage(for photo: Photo) async -> UIImage?
```

Delegates to `PhotoService.loadFullImage(for:)`.

## ImageCache

### ImageCache

```swift
class ImageCache
```

Memory-efficient image caching with automatic eviction.

#### Static Properties

```swift
static let shared: ImageCache
```

Shared singleton instance.

#### Cache Configuration

**Thumbnail Cache:**
- Count limit: 500 images
- Memory limit: 50MB
- Use case: Grid thumbnails

**Full Image Cache:**
- Count limit: 50 images  
- Memory limit: 100MB
- Use case: Fullscreen viewing

#### Methods

##### setThumbnail(_:forKey:)

```swift
func setThumbnail(_ image: UIImage, forKey key: String)
```

Stores thumbnail in cache with memory cost calculation.

**Parameters:**
- `image`: Thumbnail image to cache
- `key`: Cache key (typically `"{photoId}_thumbnail"`)

**Implementation:**
```swift
// SOURCE: TransmissionGallery/Services/ImageCache.swift:42-45
func setThumbnail(_ image: UIImage, forKey key: String) {
    let cost = Int(image.size.width * image.size.height * 4) // Rough estimate of memory cost
    thumbnailCache.setObject(image, forKey: key as NSString, cost: cost)
}
```

##### getThumbnail(forKey:)

```swift
func getThumbnail(forKey key: String) -> UIImage?
```

Retrieves thumbnail from cache.

**Parameters:**
- `key`: Cache key

**Returns:** Cached image or nil if not found

##### setFullImage(_:forKey:)

```swift
func setFullImage(_ image: UIImage, forKey key: String)
```

Stores full image in cache with memory cost calculation.

##### getFullImage(forKey:)

```swift
func getFullImage(forKey key: String) -> UIImage?
```

Retrieves full image from cache.

##### clearCaches()

```swift
func clearCaches()
```

Clears both thumbnail and full image caches. Automatically called on memory warnings.

## PhotoGridView

### PhotoGridView

```swift
struct PhotoGridView: View
```

Main grid interface with permission handling.

#### Grid Configuration

```swift
// SOURCE: TransmissionGallery/Views/PhotoGridView.swift:7-9
private let columns = [
    GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 2),
]
```

Creates adaptive grid with 120-200 point column width.

#### Permission States

View automatically handles different authorization states:

- `.authorized`, `.limited`: Shows photo grid
- `.denied`, `.restricted`: Shows permission denied view
- `.notDetermined`: Shows permission request view

**Implementation:**
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

## Error Handling

The app handles common failure scenarios:

1. **Permission Denied**: Shows `PermissionDeniedView`
2. **No Photos**: Shows `EmptyStateView` 
3. **Loading Failures**: Images return `nil`, UI shows placeholder
4. **Memory Warnings**: Automatic cache clearing

## Threading

All UI operations run on the main actor:

- `PhotoService`: Marked with `@MainActor`
- `PhotoGalleryViewModel`: Marked with `@MainActor`
- Image loading: Background queues with main queue UI updates

## Performance Notes

1. **Lazy Loading**: `LazyVGrid` loads images only when visible
2. **Cost-Based Caching**: Memory usage estimated by pixel count
3. **Separate Caches**: Prevents thumbnail/full image conflicts
4. **Background Processing**: PHImageManager callbacks run off main thread
5. **Automatic Cleanup**: Memory warning observers clear caches
