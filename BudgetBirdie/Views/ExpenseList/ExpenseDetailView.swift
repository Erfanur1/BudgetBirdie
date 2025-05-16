import SwiftUI

struct ExpenseDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let expense: Expense
    @State private var isEditing = false
    @State private var editedAmount = ""
    @State private var editedCategory = ""
    @State private var editedNote = ""
    @State private var editedDate = Date()
    
    var body: some View {
        ZStack {
            // Background
            BudgetBirdieTheme.backgroundBlue
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.title)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                        }
                        
                        Spacer()
                        
                        Text(isEditing ? "Edit Expense" : "Expense Details")
                            .font(BudgetBirdieTheme.titleFont)
                            .foregroundColor(BudgetBirdieTheme.primaryBlue)
                        
                        Spacer()
                        
                        Button {
                            if isEditing {
                                saveChanges()
                            }
                            isEditing.toggle()
                        } label: {
                            Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .font(.title)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                        }
                    }
                    .padding()
                    
                    if isEditing {
                        editModeView
                    } else {
                        detailView
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            editedAmount = String(format: "%.2f", expense.amount)
            editedCategory = expense.category ?? ""
            editedNote = expense.note ?? ""
            editedDate = expense.date ?? Date()
        }
    }
    
    private var detailView: some View {
        BudgetBirdieTheme.cardStyle(content:
            VStack(spacing: 25) {
                // Category and amount
                HStack(alignment: .top) {
                    if let category = expense.category,
                       let categoryEnum = ExpenseCategory(rawValue: category) {
                        ZStack {
                            Circle()
                                .fill(categoryEnum.color.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: categoryEnum.icon)
                                .font(.system(size: 40))
                                .foregroundColor(categoryEnum.color)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(NumberFormatter.currency.string(from: NSNumber(value: expense.amount)) ?? "$0.00")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(expense.amount > 100 ? .red : .primary)
                        
                        Text(expense.date?.formattedString() ?? "Unknown Date")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                    .background(BudgetBirdieTheme.primaryBlue.opacity(0.3))
                
                // Category description
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(expense.category ?? "Unknown Category")
                            .font(.title3.bold())
                    }
                    
                    Spacer()
                }
                
                if let note = expense.note, !note.isEmpty {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(note)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray6))
                                )
                        }
                    }
                }
                
                // Delete button
                Button {
                    deleteExpense()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Expense")
                    }
                    .foregroundColor(.red)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 1)
                    )
                }
                .padding(.top, 10)
            }
            .padding()
        )
    }
    
    private var editModeView: some View {
        BudgetBirdieTheme.cardStyle(content:
            VStack(spacing: 20) {
                // Amount field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(BudgetBirdieTheme.headlineFont)
                        .foregroundColor(BudgetBirdieTheme.primaryBlue)
                    
                    HStack {
                        Text("$")
                            .font(.headline)
                        
                        TextField("0.00", text: $editedAmount)
                            .keyboardType(.decimalPad)
                            .font(.title3)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    )
                }
                
                // Category picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(BudgetBirdieTheme.headlineFont)
                        .foregroundColor(BudgetBirdieTheme.primaryBlue)
                    
                    Picker("Category", selection: $editedCategory) {
                        ForEach(ExpenseCategory.allCases) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }.tag(category.rawValue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    )
                }
                
                // Date picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(BudgetBirdieTheme.headlineFont)
                        .foregroundColor(BudgetBirdieTheme.primaryBlue)
                    
                    DatePicker("", selection: $editedDate, displayedComponents: .date)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                        )
                }
                
                // Notes field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(BudgetBirdieTheme.headlineFont)
                        .foregroundColor(BudgetBirdieTheme.primaryBlue)
                    
                    TextField("Optional", text: $editedNote)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                        )
                }
            }
            .padding()
        )
    }
    
    private func saveChanges() {
        guard let amount = Double(editedAmount) else { return }
        
        expense.amount = amount
        expense.category = editedCategory
        expense.note = editedNote
        expense.date = editedDate
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving changes: \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteExpense() {
        withAnimation {
            viewContext.delete(expense)
            
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                print("Error deleting expense: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
