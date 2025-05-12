import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false// Track login state

    var body: some View {
        if isLoggedIn {
            TaskBarView() // Show main app after login
        } else {
            loginView(onLoginSuccess: {
                isLoggedIn = true // Update login state
            })
        }
    }
}

#Preview {
    ContentView()
}
