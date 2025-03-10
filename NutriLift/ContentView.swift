import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false // Track login state

    var body: some View {
        if isLoggedIn {
            TaskBarView() // Show main app after login
        } else {
            loginView() // Now works correctly
        }
    }
}

#Preview {
    ContentView()
}
