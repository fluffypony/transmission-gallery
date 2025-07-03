# Transmission Gallery

A beautiful iOS photo gallery app built with SwiftUI, featuring smooth animations and intuitive photo browsing.

## Features

- 📸 **Photo Library Integration**: Access and display photos from your device's photo library
- 🔒 **Permission Management**: Graceful photo access permission handling with user-friendly prompts
- 📱 **Responsive Grid Layout**: Adaptive grid that works on iPhone and iPad
- 🔍 **Fullscreen Viewer**: Tap any photo to view fullscreen with zoom, pan, and swipe navigation
- 🎨 **Modern UI**: Clean, minimal interface with dark mode support in fullscreen
- ⚡ **Performance Optimized**: Image caching and lazy loading for smooth scrolling
- 🖐️ **Gesture Support**: Double-tap to zoom, pinch to zoom, drag to pan in fullscreen view

## Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

## Getting Started

### Option 1: Open in Xcode (Recommended)

1. Open Xcode
2. Select "File" → "Open..." 
3. Navigate to this folder and select `Package.swift`
4. Xcode will automatically load the project as a Swift Package
5. Select the "TransmissionGallery" scheme
6. Choose your target device (iPhone Simulator recommended)
7. Press ⌘+R to build and run

### Option 2: Using Xcode Command Line

```bash
# Navigate to the project directory
cd transmission-gallery

# Open the Package.swift in Xcode
open Package.swift

# Or build from command line (iOS Simulator)
xcodebuild -scheme TransmissionGallery -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Project Structure

```
TransmissionGallery/
├── Models/
│   └── Photo.swift              # Photo data model wrapping PHAsset
├── Services/
│   ├── PhotoService.swift       # PhotoKit integration and image loading
│   └── ImageCache.swift         # Memory-efficient image caching
├── ViewModels/
│   └── PhotoGalleryViewModel.swift # Observable state management
├── Views/
│   ├── ContentView.swift        # Root view container
│   ├── PhotoGridView.swift      # Main grid interface
│   ├── PhotoThumbnailView.swift # Individual thumbnail component
│   ├── FullscreenPhotoView.swift # Fullscreen photo viewer
│   ├── TransitionPhotoView.swift # Wrapper for smooth transitions
│   └── PermissionRequestView.swift # Permission handling UI
├── TransmissionGalleryApp.swift # App entry point
└── Info.plist                  # App configuration and permissions
```

## Architecture

- **MVVM Pattern**: Clean separation between UI and business logic
- **SwiftUI**: Modern declarative UI framework
- **PhotoKit**: Native iOS photo library integration
- **Async/Await**: Modern Swift concurrency for smooth performance
- **Combine**: Reactive state management with ObservableObject

## Permissions

The app requires photo library access to function. The following permission is declared in `Info.plist`:

- `NSPhotoLibraryUsageDescription`: "This app needs access to your photo library to display and browse your photos in a beautiful gallery interface."

## Performance Features

- **Lazy Loading**: Only loads images as they become visible
- **Memory Management**: Automatic cache eviction on memory warnings
- **Background Loading**: Non-blocking image loading on background queues
- **Thumbnail Optimization**: Separate caching for thumbnails vs full images

## Customization

The app is designed to be easily customizable:

- **Grid Layout**: Modify `columns` in `PhotoGridView.swift`
- **Cache Limits**: Adjust memory limits in `ImageCache.swift`
- **Image Sizes**: Configure thumbnail/full image sizes in `PhotoService.swift`
- **UI Colors**: Customize colors and styling throughout the SwiftUI views

## Future Enhancements

- [ ] Transmission library integration for advanced animations (hero transitions)
- [ ] Photo editing capabilities
- [ ] Album organization
- [ ] Search and filtering
- [ ] Photo sharing functionality
- [ ] iCloud photo synchronization

## Troubleshooting

### Common Issues

1. **"No such module 'UIKit'" error**: Make sure you're building for iOS target, not macOS
2. **Permission denied**: Check that photo access permissions are properly granted in Settings
3. **Build failures**: Ensure Xcode 15+ and iOS 17+ deployment target

### Debug Tips

- Use Xcode's Simulator to test photo library access
- Check Console app for detailed logging during development
- Use Instruments to monitor memory usage and performance

## Contributing

This is a demonstration iOS photo gallery app. Feel free to fork and modify for your own projects!

## License

See LICENSE file for details.