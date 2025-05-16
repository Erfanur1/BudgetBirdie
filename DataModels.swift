import SwiftUI

// Category Amount model for pie charts
struct CategoryAmount: Identifiable {
    let category: String
    let amount: Double
    var id: String { category }
}

// Daily Expense model for bar charts
struct DailyExpense: Identifiable {
    let date: String
    let amount: Double
    var id: String { date }
}

// Time Range enum
enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var id: String { self.rawValue }
}

// Helper Extensions
extension TimeRange {
    func getDateRange(for selectedDate: Date) -> (startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        
        switch self {
        case .week:
            let weekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)
            let startDate = calendar.date(from: weekComponents) ?? selectedDate
            let endDate = calendar.date(byAdding: .day, value: 7, to: startDate) ?? selectedDate
            return (startDate, endDate)
            
        case .month:
            let startDate = selectedDate.startOfMonth
            let endDate = selectedDate.endOfMonth
            return (startDate, endDate)
            
        case .year:
            let yearComponents = calendar.dateComponents([.year], from: selectedDate)
            let startDate = calendar.date(from: yearComponents) ?? selectedDate
            let endDate = calendar.date(byAdding: .year, value: 1, to: startDate) ?? selectedDate
            return (startDate, endDate)
        }
    }
}
