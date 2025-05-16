import SwiftUI
import CoreData

struct DailySpendingView: View {
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
            sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: true)],
            predicate: predicate
        )
    }
    
    var dailyData: [DailyExpense] {
        var dailyTotals: [String: Double] = [:]
        let calendar = Calendar.current
        
        for expense in expenses {
            guard let date = expense.date else { continue }
            let dateString = formatDateForGrouping(date)
            let currentAmount = dailyTotals[dateString] ?? 0
            dailyTotals[dateString] = currentAmount + expense.amount
        }
        
        return dailyTotals.map { DailyExpense(date: $0.key, amount: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    private func formatDateForGrouping(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        switch timeRange {
        case .week, .month:
            formatter.dateFormat = "MM/dd"
        case .year:
            formatter.dateFormat = "MMM"
        }
        
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily Spending")
                .font(.headline)
                .padding(.horizontal)
            
            if dailyData.isEmpty {
                Text("No expenses recorded")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                // Use LegacyBarChartView for showing the spending data
                LegacyBarChartView(data: dailyData)
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
    }
}
