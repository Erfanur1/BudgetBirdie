import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.category ?? "Unknown Category")
                    .font(.headline)
                if let note = expense.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(NumberFormatter.currency.string(from: NSNumber(value: expense.amount)) ?? "$0.00")
                    .font(.headline)
                    .foregroundColor(expense.amount > 100 ? .red : .primary)
                
                Text(expense.date?.formattedString() ?? "Unknown Date")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
