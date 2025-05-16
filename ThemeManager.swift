import SwiftUI

struct BudgetBirdieTheme {
    // Colors
    static let primaryBlue = Color(red: 0.25, green: 0.65, blue: 0.95)
    static let lightBlue = Color(red: 0.88, green: 0.95, blue: 1.0)
    static let backgroundBlue = Color(red: 0.95, green: 0.98, blue: 1.0)
    static let accentGold = Color(red: 0.95, green: 0.85, blue: 0.45)
    
    // Gradients
    static let blueGradient = LinearGradient(
        gradient: Gradient(colors: [lightBlue, .white]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Text Styles
    static let titleFont = Font.system(.title, design: .rounded).bold()
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .rounded)
    
    // Common Styling
    static func cardStyle<T: View>(content: T) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    static func buttonStyle(text: String) -> some View {
        Text(text)
            .font(headlineFont)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(primaryBlue)
            )
            .padding(.horizontal)
    }
    
    static func tabBackground<T: View>(content: T) -> some View {
        content
            .background(backgroundBlue.edgesIgnoringSafeArea(.all))
    }
    
    static func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(headlineFont)
                .foregroundColor(primaryBlue)
            
            Spacer()
            
            Image(systemName: "bird")
                .foregroundColor(primaryBlue)
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    static func expenseAmount(_ amount: Double) -> some View {
        Text(NumberFormatter.currency.string(from: NSNumber(value: amount)) ?? "$0.00")
            .font(.headline)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(amount > 100 ? Color.red.opacity(0.1) : accentGold.opacity(0.2))
            )
            .foregroundColor(amount > 100 ? .red : .primary)
    }
}
