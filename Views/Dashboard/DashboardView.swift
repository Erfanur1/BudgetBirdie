import SwiftUI

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var timeRange: TimeRange = .month
    @State private var selectedDate = Date()
    
    // Fetch all expenses for calculations
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .default)
    private var allExpenses: FetchedResults<Expense>
    
    var body: some View {
        NavigationView {
            ZStack {
                // Themed background
                BudgetBirdieTheme.backgroundBlue
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header with logo
                        HStack {
                            Image(systemName: "bird.fill")
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                                .font(.largeTitle)
                            
                            Text("Budget Overview")
                                .font(.title.bold())
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        
                        // Time range selector with improved styling
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Select Time Range")
                                .font(.headline)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            HStack {
                                Picker("Time Range", selection: $timeRange) {
                                    ForEach(TimeRange.allCases) { range in
                                        Text(range.rawValue).tag(range)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(BudgetBirdieTheme.primaryBlue.opacity(0.2), lineWidth: 1)
                                )
                            }
                            
                            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .accentColor(BudgetBirdieTheme.primaryBlue)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        
                        // Enhanced Expense Summary
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Expense Summary")
                                    .font(.headline)
                                    .foregroundColor(BudgetBirdieTheme.primaryBlue)
                                
                                Spacer()
                                
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(BudgetBirdieTheme.accentGold)
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 15) {
                                // Total expenses card
                                SimpleExpenseSummaryCard(
                                    title: "Total",
                                    amount: totalExpenses(for: timeRange, date: selectedDate),
                                    icon: "dollarsign.circle.fill",
                                    iconColor: BudgetBirdieTheme.accentGold
                                )
                                
                                // Average per day card
                                SimpleExpenseSummaryCard(
                                    title: "Daily Avg",
                                    amount: averagePerDay(for: timeRange, date: selectedDate),
                                    icon: "calendar.badge.clock",
                                    iconColor: BudgetBirdieTheme.primaryBlue
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Enhanced Category Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Category Breakdown")
                                    .font(.headline)
                                    .foregroundColor(BudgetBirdieTheme.primaryBlue)
                                
                                Spacer()
                                
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 15) {
                                // Simple category bars instead of pie chart
                                ForEach(topCategories(for: timeRange, date: selectedDate).prefix(3)) { item in
                                    CategoryBar(
                                        category: item.category,
                                        amount: item.amount,
                                        maxAmount: topCategories(for: timeRange, date: selectedDate).first?.amount ?? 1
                                    )
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Enhanced Daily Spending
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Daily Spending")
                                    .font(.headline)
                                    .foregroundColor(BudgetBirdieTheme.primaryBlue)
                                
                                Spacer()
                                
                                Image(systemName: "calendar")
                                    .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 15) {
                                SimpleDailyExpenseView(
                                    expenses: dailyData(for: timeRange, date: selectedDate)
                                )
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Footer space for comfort
                        Spacer(minLength: 40)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // Helper functions to calculate values based on timeRange and date
    func totalExpenses(for timeRange: TimeRange, date: Date) -> Double {
        let (startDate, endDate) = timeRange.getDateRange(for: date)
        
        return allExpenses
            .filter { expense in
                guard let expenseDate = expense.date else { return false }
                return expenseDate >= startDate && expenseDate <= endDate
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    func averagePerDay(for timeRange: TimeRange, date: Date) -> Double {
        let total = totalExpenses(for: timeRange, date: date)
        let dayCount: Double
        
        switch timeRange {
        case .week:
            dayCount = 7
        case .month:
            let (startDate, endDate) = timeRange.getDateRange(for: date)
            dayCount = Double(Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 30)
        case .year:
            dayCount = 365
        }
        
        return dayCount > 0 ? total / dayCount : 0
    }
    
    func topCategories(for timeRange: TimeRange, date: Date) -> [CategoryAmount] {
        let (startDate, endDate) = timeRange.getDateRange(for: date)
        
        var categoryTotals: [String: Double] = [:]
        
        for expense in allExpenses {
            guard let expenseDate = expense.date, let category = expense.category else { continue }
            if expenseDate >= startDate && expenseDate <= endDate {
                let currentTotal = categoryTotals[category] ?? 0
                categoryTotals[category] = currentTotal + expense.amount
            }
        }
        
        return categoryTotals
            .map { CategoryAmount(category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    func dailyData(for timeRange: TimeRange, date: Date) -> [DailyExpense] {
        let (startDate, endDate) = timeRange.getDateRange(for: date)
        let calendar = Calendar.current
        
        var dailyTotals: [String: Double] = [:]
        
        for expense in allExpenses {
            guard let expenseDate = expense.date else { continue }
            if expenseDate >= startDate && expenseDate <= endDate {
                let dateFormatter = DateFormatter()
                
                switch timeRange {
                case .week, .month:
                    dateFormatter.dateFormat = "MM/dd"
                case .year:
                    dateFormatter.dateFormat = "MMM"
                }
                
                let dateString = dateFormatter.string(from: expenseDate)
                let currentAmount = dailyTotals[dateString] ?? 0
                dailyTotals[dateString] = currentAmount + expense.amount
            }
        }
        
        return dailyTotals
            .map { DailyExpense(date: $0.key, amount: $0.value) }
            .sorted { $0.date < $1.date }
    }
}

// Simple components that don't rely on complex charts

struct SimpleExpenseSummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(NumberFormatter.currency.string(from: NSNumber(value: amount)) ?? "$0.00")
                .font(.system(.title2, design: .rounded).bold())
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct CategoryBar: View {
    let category: String
    let amount: Double
    let maxAmount: Double
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                if let categoryEnum = ExpenseCategory(rawValue: category) {
                    Circle()
                        .fill(categoryEnum.color)
                        .frame(width: 12, height: 12)
                    
                    Text(category)
                        .font(.subheadline)
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 12, height: 12)
                    
                    Text(category)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Text(NumberFormatter.currency.string(from: NSNumber(value: amount)) ?? "$0.00")
                    .font(.subheadline.bold())
            }
            
            // Simple bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)
                        .cornerRadius(5)
                    
                    // Progress
                    Rectangle()
                        .fill(getColor(for: category))
                        .frame(width: calculateWidth(geometry), height: 10)
                        .cornerRadius(5)
                }
            }
            .frame(height: 10)
        }
    }
    
    private func calculateWidth(_ geometry: GeometryProxy) -> CGFloat {
        let percentage = amount / maxAmount
        return max(min(CGFloat(percentage) * geometry.size.width, geometry.size.width), 10)
    }
    
    private func getColor(for category: String) -> Color {
        if let categoryEnum = ExpenseCategory(rawValue: category) {
            return categoryEnum.color
        }
        return .gray
    }
}

struct SimpleDailyExpenseView: View {
    let expenses: [DailyExpense]
    
    var body: some View {
        if expenses.isEmpty {
            Text("No expenses recorded for this period")
                .foregroundColor(.secondary)
                .padding()
        } else {
            VStack(spacing: 10) {
                ForEach(expenses) { expense in
                    HStack {
                        Text(expense.date)
                            .font(.caption)
                            .frame(width: 50, alignment: .leading)
                        
                        // Simple bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 20)
                                    .cornerRadius(5)
                                
                                // Bar
                                Rectangle()
                                    .fill(BudgetBirdieTheme.primaryBlue)
                                    .frame(width: calculateWidth(geometry, for: expense), height: 20)
                                    .cornerRadius(5)
                                
                                // Amount text
                                Text(NumberFormatter.currency.string(from: NSNumber(value: expense.amount)) ?? "$0.00")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.leading, 5)
                            }
                        }
                        .frame(height: 20)
                    }
                }
            }
        }
    }
    
    private func calculateWidth(_ geometry: GeometryProxy, for expense: DailyExpense) -> CGFloat {
        let maxAmount = expenses.map { $0.amount }.max() ?? 1
        let percentage = expense.amount / maxAmount
        return max(min(CGFloat(percentage) * geometry.size.width, geometry.size.width), 50)
    }
}
