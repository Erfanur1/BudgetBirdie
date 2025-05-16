import SwiftUI

struct ExpenseListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddExpense = false
    @State private var searchText = ""
    @State private var showingConfirmation = false
    @State private var expenseToDelete: Expense? = nil
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .default)
    private var expenses: FetchedResults<Expense>
    
    var filteredExpenses: [Expense] {
        if searchText.isEmpty {
            return Array(expenses)
        } else {
            return expenses.filter { expense in
                let categoryMatch = expense.category?.lowercased().contains(searchText.lowercased()) ?? false
                let noteMatch = expense.note?.lowercased().contains(searchText.lowercased()) ?? false
                return categoryMatch || noteMatch
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                BudgetBirdieTheme.backgroundBlue
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Enhanced header
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "bird.fill")
                                .font(.title)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            Text("My Expenses")
                                .font(.title.bold())
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            Spacer()
                            
                            // Add button in header for better visibility
                            Button {
                                showingAddExpense = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add")
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(BudgetBirdieTheme.primaryBlue)
                                )
                                .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        
                        // Search bar with themed styling
                        if #available(iOS 15.0, *) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("Search expenses", text: $searchText)
                            }
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    
                    // Enhanced expense list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredExpenses) { expense in
                                NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                                    EnhancedExpenseRowView(expense: expense)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        expenseToDelete = expense
                                        showingConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            
                            // Add some padding at bottom for comfort
                            Color.clear.frame(height: 20)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddExpense) {
                // Use the new BalancedAddExpenseView instead
                AddExpenseView()
            }
            .alert("Delete Expense", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let expense = expenseToDelete {
                        deleteExpense(expense)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this expense?")
            }
        }
    }
    
    private func deleteExpense(_ expense: Expense) {
        withAnimation {
            viewContext.delete(expense)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting expense: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

