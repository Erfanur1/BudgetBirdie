import SwiftUI
import CoreData

struct CategoryBreakdownView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let timeRange: TimeRange
    let selectedDate: Date
    
    @FetchRequest var expenses: FetchedResults<Expense>
    
    init(timeRange: TimeRange, selectedDate: Date) {
        self.timeRange = timeRange
        self.selectedDate = selectedDate
        
        let dateRange = timeRange.getDateRange(for: selectedDate)
        let startDate = dateRange.startDate
        let endDate = dateRange.endDate
        
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        
        _expenses = FetchRequest<Expense>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
            predicate: predicate
        )
    }
    
    var categoryData: [CategoryAmount] {
        var data: [String: Double] = [:]
        
        for expense in expenses {
            guard let category = expense.category else { continue }
            let currentAmount = data[category] ?? 0
            data[category] = currentAmount + expense.amount
        }
        
        return data.map { CategoryAmount(category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Category Breakdown")
                .font(.headline)
                .padding(.horizontal)
            
            if categoryData.isEmpty {
                Text("No expenses recorded")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack {
                    // Use only LegacyChartView for now to avoid Chart framework issues
                    LegacyChartView(data: categoryData)
                        .frame(height: 250)
                    
                    categoryBreakdownList
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
    
    private var categoryBreakdownList: some View {
        VStack(spacing: 10) {
            ForEach(categoryData.prefix(5)) { item in
                HStack {
                    if let category = ExpenseCategory(rawValue: item.category) {
                        Circle()
                            .fill(category.color)
                            .frame(width: 12, height: 12)
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 12, height: 12)
                    }
                    
                    Text(item.category)
                    
                    Spacer()
                    
                    Text(NumberFormatter.currency.string(from: NSNumber(value: item.amount)) ?? "$0.00")
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

    
   
