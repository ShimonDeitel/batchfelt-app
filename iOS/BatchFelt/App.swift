import SwiftUI

@main
struct BatchFeltApp: App {
    @StateObject private var store = BatchFeltStore()
    @StateObject private var purchases = PurchaseManager()
    @AppStorage("batchfelt_haptics_enabled") private var hapticsEnabled: Bool = true

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.light)
                .onAppear {
                    BFHaptics.enabled = hapticsEnabled
                }
        }
    }
}
