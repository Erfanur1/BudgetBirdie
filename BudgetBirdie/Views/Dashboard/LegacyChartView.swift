import SwiftUI

// Pie chart for category breakdown
struct LegacyChartView: View {
    let data: [CategoryAmount]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<data.count, id: \.self) { index in
                    PieSliceView(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        color: colorForCategory(data[index].category)
                    )
                }
                
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                
                VStack {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(NumberFormatter.currency.string(from: NSNumber(value: totalAmount)) ?? "$0.00")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    var totalAmount: Double {
        data.reduce(0) { $0 + $1.amount }
    }
    
    func startAngle(for index: Int) -> Double {
        if index == 0 { return 0 }
        
        let prevTotal = data[0..<index].reduce(0) { $0 + $1.amount }
        return prevTotal / totalAmount * 360
    }
    
    func endAngle(for index: Int) -> Double {
        let prevTotal = data[0...index].reduce(0) { $0 + $1.amount }
        return prevTotal / totalAmount * 360
    }
    
    func colorForCategory(_ category: String) -> Color {
        if let categoryEnum = ExpenseCategory(rawValue: category) {
            return categoryEnum.color
        }
        return .gray
    }
}

struct PieSliceView: View {
    let startAngle: Double
    let endAngle: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(startAngle - 90),
                    endAngle: .degrees(endAngle - 90),
                    clockwise: false
                )
            }
            .fill(color)
        }
    }
}
