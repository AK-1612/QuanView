import SwiftUI

struct ProfileToolbarButton: View {
    @State private var showProfile = false
    
    var body: some View {
        Button {
            showProfile = true
        } label: {
            Image(systemName: "person.crop.circle")
                .font(.title3)
        }
        .accessibilityLabel("Profile")
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
    }
}
