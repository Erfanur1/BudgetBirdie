// Views/Settings/ExportView.swift
import SwiftUI
import UniformTypeIdentifiers
import CoreData

@available(iOS 16.0, *)
struct ExportView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var exportFormat = ExportFormat.csv
    @State private var exportData: URL?
    @State private var isExporting = false
    
    enum ExportFormat: String, CaseIterable, Identifiable {
        case csv = "CSV"
        case json = "JSON"
        
        var id: String { self.rawValue }
        
        var fileExtension: String {
            switch self {
            case .csv: return "csv"
            case .json: return "json"
            }
        }
        
        var utType: UTType {
            switch self {
            case .csv: return UTType.commaSeparatedText
            case .json: return UTType.json
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Export Format")) {
                    Picker("Format", selection: $exportFormat) {
                        ForEach(ExportFormat.allCases) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button("Generate Export") {
                        generateExport()
                    }
                }
            }
            .navigationTitle("Export Data")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .fileExporter(
                isPresented: $isExporting,
                document: ExportDocument(url: exportData ?? URL(fileURLWithPath: "")),
                contentType: exportFormat.utType,
                defaultFilename: "budgetbirdie_expenses.\(exportFormat.fileExtension)"
            ) { result in
                switch result {
                case .success:
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Export failed: \(error)")
                }
            }
        }
    }
    
    private func generateExport() {
        let fetchRequest = NSFetchRequest<Expense>(entityName: "Expense")
        do {
            let expenses = try viewContext.fetch(fetchRequest)
            
            let fileManager = FileManager.default
            let tempDir = fileManager.temporaryDirectory
            let fileName = "budgetbirdie_expenses.\(exportFormat.fileExtension)"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            switch exportFormat {
            case .csv:
                try generateCSV(expenses: expenses, fileURL: fileURL)
            case .json:
                try generateJSON(expenses: expenses, fileURL: fileURL)
            }
            
            exportData = fileURL
            isExporting = true
        } catch {
            print("Export error: \(error)")
        }
    }
    
    private func generateCSV(expenses: [Expense], fileURL: URL) throws {
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
        
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    private func generateJSON(expenses: [Expense], fileURL: URL) throws {
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
        
        let jsonData = try JSONSerialization.data(withJSONObject: expensesArray, options: [.prettyPrinted])
        try jsonData.write(to: fileURL)
    }
}

struct ExportDocument: FileDocument {
    let url: URL
    
    static var readableContentTypes: [UTType] { [.commaSeparatedText, .json] }
    
    init(url: URL) {
        self.url = url
    }
    
    init(configuration: ReadConfiguration) throws {
        url = URL(fileURLWithPath: "")
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        do {
            let data = try Data(contentsOf: url)
            return .init(regularFileWithContents: data)
        } catch {
            return .init(regularFileWithContents: Data())
        }
    }
}
