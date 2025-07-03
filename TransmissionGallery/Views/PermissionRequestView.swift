import SwiftUI

struct PermissionRequestView: View {
    let onRequestAccess: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Access Your Photos")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("To display your beautiful photos in this gallery, we need permission to access your photo library.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Grant Access") {
                onRequestAccess()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

struct PermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Photo Access Denied")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("To use this photo gallery, please grant photo library access in Settings.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.stack")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Photos Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your photo library appears to be empty or no photos are available.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Permission Request") {
    PermissionRequestView {
        print("Request access tapped")
    }
}

#Preview("Permission Denied") {
    PermissionDeniedView()
}

#Preview("Empty State") {
    EmptyStateView()
}
