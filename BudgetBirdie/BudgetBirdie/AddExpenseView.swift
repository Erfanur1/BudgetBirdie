import SwiftUI

struct AddExpenseView: View {
    @Environment(\ .managedObjectContext) private var viewContext
    @Environment(\ .presentationMode) private var presentationMode

    @State private var amountText = ""
    @State private var date = Date()
    @State private var category = ""
    @State private var note = ""

    private var isValid: Bool {
        guard let amt = Decimal(string: amountText), amt > 0 else { return false }
        return !category.isEmpty && date <= Date()
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount")) {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section(header: Text("Category")) {
                    TextField("e.g. Groceries", text: $category)
                }
                Section(header: Text("Note (optional)")) {
                    TextField("e.g. Coffee with friends", text: $note)
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(!isValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func saveExpense() {
        let newExpense = Expense(context: viewContext)
        newExpense.id = UUID()
        newExpense.amount = NSDecimalNumber(string: amountText)
        newExpense.date = date
        newExpense.category = category
        newExpense.note = note.isEmpty ? nil : note

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
}

