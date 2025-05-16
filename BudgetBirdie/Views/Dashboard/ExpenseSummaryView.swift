import SwiftUI
import CoreData

struct ExpenseSummaryView: View {
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
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var averagePerDay: Double {
        let calendar = Calendar.current
        var dayCount = 0
        
        switch timeRange {
        case .week:
            dayCount = 7
        case .month:
            let startOfMonth = selectedDate.startOfMonth
            let endOfMonth = selectedDate.endOfMonth
            dayCount = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day ?? 30
        case .year:
            dayCount = 365
        }
        
        return totalExpenses / Double(dayCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Expense Summary")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                summaryCard(title: "Total Expenses", value: totalExpenses)
                summaryCard(title: "Avg. per Day", value: averagePerDay)
            }
            .padding(.horizontal)
        }
    }
    
    private func summaryCard(title: String, value: Double) -> some View {
        BudgetBirdieTheme.cardStyle(content:
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(NumberFormatter.currency.string(from: NSNumber(value: value)) ?? "$0.00")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        )
    }
}
