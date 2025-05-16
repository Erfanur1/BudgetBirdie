import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            EnhancedExpenseListView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet")
                }
                .tag(0)
            
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie")
                }
                .tag(1)
            
            EnhancedSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(BudgetBirdieTheme.primaryBlue)
        .onAppear {
            // Changing the toolbar aesthetics
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor(BudgetBirdieTheme.backgroundBlue)
            appearance.shadowColor = UIColor.clear
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

// the UI for expense lists to fit with the bird theme
struct EnhancedExpenseListView: View {
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
                                .font(BudgetBirdieTheme.titleFont)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            Spacer()
                            
                            Button {
                                showingAddExpense = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        
                        // Search bar
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
                    
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredExpenses) { expense in
                                NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                                    ExpenseRowView(expense: expense)
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
                        }
                        .padding()
                    }
                }
                
                // Floating action button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingAddExpense = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(BudgetBirdieTheme.primaryBlue)
                                .clipShape(Circle())
                                .shadow(color: BudgetBirdieTheme.primaryBlue.opacity(0.4), radius: 5, x: 0, y: 3)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddExpense) {
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

// Enhanced ExpenseRowView with BudgetBirdie theme
struct EnhancedExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        BudgetBirdieTheme.cardStyle(content:
            HStack {
                // Category circle with icon
                if let category = expense.category,
                   let categoryEnum = ExpenseCategory(rawValue: category) {
                    ZStack {
                        Circle()
                            .fill(categoryEnum.color.opacity(0.2))
                            .frame(width: 45, height: 45)
                        
                        Image(systemName: categoryEnum.icon)
                            .font(.system(size: 20))
                            .foregroundColor(categoryEnum.color)
                    }
                    .padding(.trailing, 8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.category ?? "Unknown Category")
                        .font(BudgetBirdieTheme.headlineFont)
                    
                    if let note = expense.note, !note.isEmpty {
                        Text(note)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Text(expense.date?.formattedString() ?? "Unknown Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Amount display with card-like styling
                BudgetBirdieTheme.expenseAmount(expense.amount)
            }
            .padding(.vertical, 4)
        )
    }
}
