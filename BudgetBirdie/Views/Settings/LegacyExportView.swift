import SwiftUI
import CoreData

struct LegacyExportView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var exportFormat = "CSV"
    @State private var exportMessage = "Generate an export to share your expense data"
    @State private var isExporting = false
    @State private var exportData: Data?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Export Format")) {
                    Picker("Format", selection: $exportFormat) {
                        Text("CSV").tag("CSV")
                        Text("JSON").tag("JSON")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button("Generate Export") {
                        generateExport()
                    }
                    
                    if isExporting {
                        ShareLink(item: exportData ?? Data(), preview: SharePreview("BudgetBirdie Expenses", image: Image(systemName: "doc.text")))
                    }
                    
                    Text(exportMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Export Data")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func generateExport() {
        let fetchRequest = NSFetchRequest<Expense>(entityName: "Expense")
        do {
            let expenses = try viewContext.fetch(fetchRequest)
            
            switch exportFormat {
            case "CSV":
                if let data = generateCSV(expenses: expenses) {
                    exportData = data
                    isExporting = true
                    exportMessage = "CSV file generated successfully"
                }
            case "JSON":
                if let data = generateJSON(expenses: expenses) {
                    exportData = data
                    isExporting = true
                    exportMessage = "JSON file generated successfully"
                }
            default:
                exportMessage = "Unknown format selected"
            }
        } catch {
            exportMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    private func generateCSV(expenses: [Expense]) -> Data? {
        var csvString = "ID,Amount,Category,Date,Note\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for expense in expenses {
            let id = expense.id?.uuidString ?? "Unknown"
            let amount = String(format: "%.2f", expense.amount)
            let category = expense.category ?? "Unknown"
            let date = expense.date != nil ? dateFormatter.string(from: expense.date!) : "Unknown"
            let note = expense.note?.replacingOccurrences(of: ",", with: ";") ?? ""
            
            csvString += "\(id),\(amount),\(category),\(date),\(note)\n"
        }
        
        return csvString.data(using: .utf8)
    }
    
    private func generateJSON(expenses: [Expense]) -> Data? {
        var expensesArray: [[String: Any]] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for expense in expenses {
            var expenseDict: [String: Any] = [:]
            
            expenseDict["id"] = expense.id?.uuidString ?? "Unknown"
            expenseDict["amount"] = expense.amount
            expenseDict["category"] = expense.category ?? "Unknown"
            if let date = expense.date {
                expenseDict["date"] = dateFormatter.string(from: date)
            }
            expenseDict["note"] = expense.note ?? ""
            
            expensesArray.append(expenseDict)
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: expensesArray, options: [.prettyPrinted])
        } catch {
            return nil
        }
    }
}
