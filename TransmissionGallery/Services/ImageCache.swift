import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private let thumbnailCache = NSCache<NSString, UIImage>()
    private let fullImageCache = NSCache<NSString, UIImage>()
    
    private init() {
        setupCaches()
        observeMemoryWarnings()
    }
    
    private func setupCaches() {
        // Thumbnail cache - smaller images, more entries
        thumbnailCache.countLimit = 500
        thumbnailCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Full image cache - larger images, fewer entries
        fullImageCache.countLimit = 50
        fullImageCache.totalCostLimit = 100 * 1024 * 1024 // 100MB
    }
    
    private func observeMemoryWarnings() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearCaches()
        }
    }
    
    func clearCaches() {
        thumbnailCache.removeAllObjects()
        fullImageCache.removeAllObjects()
    }
    
    // MARK: - Thumbnail Cache
    
    func setThumbnail(_ image: UIImage, forKey key: String) {
        let cost = Int(image.size.width * image.size.height * 4) // Rough estimate of memory cost
        thumbnailCache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    func getThumbnail(forKey key: String) -> UIImage? {
        return thumbnailCache.object(forKey: key as NSString)
    }
    
    // MARK: - Full Image Cache
    
    func setFullImage(_ image: UIImage, forKey key: String) {
        let cost = Int(image.size.width * image.size.height * 4) // Rough estimate of memory cost
        fullImageCache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    func getFullImage(forKey key: String) -> UIImage? {
        return fullImageCache.object(forKey: key as NSString)
    }
    
    // MARK: - Cache Statistics
    
    var thumbnailCacheInfo: (count: Int, cost: Int) {
        (thumbnailCache.count, thumbnailCache.totalCost)
    }
    
    var fullImageCacheInfo: (count: Int, cost: Int) {
        (fullImageCache.count, fullImageCache.totalCost)
    }
}
