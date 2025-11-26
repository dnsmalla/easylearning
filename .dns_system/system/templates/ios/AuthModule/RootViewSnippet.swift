import SwiftUI

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(auth)
        }
    }
}

struct RootView: View {
    @ObservedObject var auth: AuthService = .shared

    var body: some View {
        Group {
            if auth.isAuthenticated {
                Text("Main content here")
            } else {
                LoginView()
            }
        }
    }
}


