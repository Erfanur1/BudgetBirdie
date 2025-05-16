import SwiftUI

@main
struct BudgetBirdieApp: App {
    let persistenceController = PersistenceController.shared
    
    // State to track if user has completed onboarding
    // Set to false to ensure welcome page shows on next run
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // For testing/development - uncomment this init to reset the onboarding state each time
     init() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
     }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                //  go straight to ContentView
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tint(BudgetBirdieTheme.primaryBlue)
            } else {
                // First launch - show welcome screen
                WelcomeView(onContinue: {
                    // Mark onboarding as completed when i click continue                    hasCompletedOnboarding = true
                })
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .tint(BudgetBirdieTheme.primaryBlue)
            }
        }
    }
}
