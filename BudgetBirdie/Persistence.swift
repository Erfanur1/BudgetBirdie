import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BudgetBirdie")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let ctx = result.container.viewContext

        // Sample data for canvas previews
        for i in 1...5 {
            let exp = Expense(context: ctx)
            exp.id = UUID()
            exp.amount = NSDecimalNumber(value: Double(i) * 10.0)
            exp.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            exp.category = "Sample"
            exp.note = "Preview #\(i)"
        }

        do {
            try ctx.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
