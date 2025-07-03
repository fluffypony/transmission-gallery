import Foundation
import Photos
import UIKit

@MainActor
class PhotoService: ObservableObject {
    static let shared = PhotoService()
    
    private let imageManager = PHImageManager.default()
    private let thumbnailSize = CGSize(width: 300, height: 300)
    private let highQualitySize = CGSize(width: 1024, height: 1024)
    
    private init() {}
    
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
    
    func loadThumbnail(for photo: Photo) async -> UIImage? {
        let cacheKey = "\(photo.id)_thumbnail"
        
        // Check cache first
        if let cachedImage = ImageCache.shared.getThumbnail(forKey: cacheKey) {
            return cachedImage
        }
        
        // Load from PhotoKit
        let image = await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            imageManager.requestImage(
                for: photo.asset,
                targetSize: thumbnailSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
        
        // Cache the loaded image
        if let image = image {
            ImageCache.shared.setThumbnail(image, forKey: cacheKey)
        }
        
        return image
    }
    
    func loadFullImage(for photo: Photo) async -> UIImage? {
        let cacheKey = "\(photo.id)_full"
        
        // Check cache first
        if let cachedImage = ImageCache.shared.getFullImage(forKey: cacheKey) {
            return cachedImage
        }
        
        // Load from PhotoKit
        let image = await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            imageManager.requestImage(
                for: photo.asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
        
        // Cache the loaded image
        if let image = image {
            ImageCache.shared.setFullImage(image, forKey: cacheKey)
        }
        
        return image
    }
    
    func loadHighQualityImage(for photo: Photo) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            imageManager.requestImage(
                for: photo.asset,
                targetSize: highQualitySize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
