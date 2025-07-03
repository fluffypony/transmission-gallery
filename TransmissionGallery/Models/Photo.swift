import Foundation
import Photos
import UIKit

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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
}

extension Photo {
    var creationDate: Date? {
        asset.creationDate
    }
    
    var mediaType: PHAssetMediaType {
        asset.mediaType
    }
    
    var pixelWidth: Int {
        asset.pixelWidth
    }
    
    var pixelHeight: Int {
        asset.pixelHeight
    }
    
    var aspectRatio: CGFloat {
        guard pixelHeight > 0 else { return 1.0 }
        return CGFloat(pixelWidth) / CGFloat(pixelHeight)
    }
}
