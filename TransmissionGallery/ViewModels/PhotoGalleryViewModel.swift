import Foundation
import Photos
import SwiftUI

@MainActor
class PhotoGalleryViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isLoading = false
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
    private let photoService = PhotoService.shared
    
    init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestPhotoAccess() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        authorizationStatus = status
        
        if status == .authorized || status == .limited {
            await loadPhotos()
        }
    }
    
    func loadPhotos() async {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedPhotos = await photoService.fetchPhotos()
            photos = fetchedPhotos
        } catch {
            errorMessage = "Failed to load photos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refreshPhotos() async {
        await loadPhotos()
    }
    
    func loadThumbnail(for photo: Photo) async -> UIImage? {
        return await photoService.loadThumbnail(for: photo)
    }
    
    func loadFullImage(for photo: Photo) async -> UIImage? {
        return await photoService.loadFullImage(for: photo)
    }
}
