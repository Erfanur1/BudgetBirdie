import SwiftUI

@main
struct BudgetBirdieApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ExpenseListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
