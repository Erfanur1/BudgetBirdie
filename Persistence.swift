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
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // For previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data
        let sampleExpenses = [
            ("Groceries", "Whole Foods", 85.42, Date().addingTimeInterval(-86400)),
            ("Utilities", "Electricity Bill", 65.00, Date().addingTimeInterval(-172800)),
            ("Transportation", "Bus Pass", 45.00, Date().addingTimeInterval(-259200)),
            ("Entertainment", "Movie Tickets", 30.50, Date().addingTimeInterval(-345600)),
            ("Food", "Dinner Out", 42.85, Date().addingTimeInterval(-432000)),
            ("Shopping", "New Shoes", 95.75, Date().addingTimeInterval(-518400)),
            ("Education", "Textbooks", 120.00, Date().addingTimeInterval(-604800)),
            ("Healthcare", "Prescription", 15.99, Date().addingTimeInterval(-691200)),
            ("Rent", "Monthly Rent", 850.00, Date().addingTimeInterval(-777600)),
            ("Miscellaneous", "Gift for Friend", 35.00, Date().addingTimeInterval(-864000))
        ]
        
        for (category, note, amount, date) in sampleExpenses {
            let expense = Expense(context: viewContext)
            expense.id = UUID()
            expense.category = category
            expense.amount = amount
            expense.date = date
            expense.note = note
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
}
