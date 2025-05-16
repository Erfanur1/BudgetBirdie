import SwiftUI

struct AddExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount = ""
    @State private var category = ExpenseCategory.food.rawValue
    @State private var date = Date()
    @State private var note = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var keyboardHeight: CGFloat = 0
    
    // Animation property
    @State private var animateCard = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            Text("Add Expense")
                                .font(.title2.bold())
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            Spacer()
                            
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                        
                        // Amount field with larger input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.headline)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            HStack(alignment: .center) {
                                Text("$")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(BudgetBirdieTheme.primaryBlue)
                                
                                TextField("0.00", text: $amount)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                        }
                        
                        // Category - Balanced grid approach
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            let columns = [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ]
                            
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(ExpenseCategory.allCases.prefix(8)) { cat in
                                    CategoryButton(
                                        category: cat,
                                        isSelected: category == cat.rawValue,
                                        action: { category = cat.rawValue }
                                    )
                                }
                            }
                            
                            // Second row if needed
                            if ExpenseCategory.allCases.count > 8 {
                                LazyVGrid(columns: columns, spacing: 15) {
                                    ForEach(ExpenseCategory.allCases.dropFirst(8)) { cat in
                                        CategoryButton(
                                            category: cat,
                                            isSelected: category == cat.rawValue,
                                            action: { category = cat.rawValue }
                                        )
                                    }
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                        )
                        .padding(.vertical, 5)
                        
                        // Date picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.headline)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .frame(height: min(300, geo.size.height * 0.35))
                                .clipped()
                                .padding(5)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                        }
                        
                        // Notes field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            TextField("Optional", text: $note)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                        }
                        
                        // Save button
                        Button {
                            saveExpense()
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                Text("Save Expense")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(BudgetBirdieTheme.primaryBlue)
                                    .shadow(color: BudgetBirdieTheme.primaryBlue.opacity(0.4), radius: 5, x: 0, y: 3)
                            )
                        }
                        .padding(.top, 10)
                        
                        // Space at bottom to ensure nothing is cut off
                        Spacer().frame(height: max(20, keyboardHeight * 0.1))
                    }
                    .padding()
                    .frame(minHeight: geo.size.height)
                }
            }
            .background(BudgetBirdieTheme.backgroundBlue.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                // Add keyboard notification observers
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        self.keyboardHeight = keyboardFrame.height
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    self.keyboardHeight = 0
                }
            }
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount."
            showingAlert = true
            return
        }
        
        let newExpense = Expense(context: viewContext)
        newExpense.id = UUID()
        newExpense.amount = amountValue
        newExpense.category = category
        newExpense.date = date
        newExpense.note = note
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            alertMessage = "Failed to save expense: \(nsError.localizedDescription)"
            showingAlert = true
        }
    }
}

// Balanced category button - good size for a grid
struct CategoryButton: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? category.color : category.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: isSelected ? 28 : 24))
                        .foregroundColor(isSelected ? .white : category.color)
                }
                
                Text(category.rawValue)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(isSelected ? category.color : .secondary)
                    .frame(maxWidth: 70)
            }
            .padding(.vertical, 5)
        }
    }
}

// Preview for development
struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
     AddExpenseView()
    }
}
