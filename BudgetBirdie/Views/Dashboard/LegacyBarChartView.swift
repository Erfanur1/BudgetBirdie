import SwiftUI

struct LegacyBarChartView: View {
    let data: [DailyExpense]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(data) { item in
                    VStack {
                        Rectangle()
                            .fill(BudgetBirdieTheme.primaryBlue)
                            .frame(width: barWidth(geometry), height: barHeight(geometry, for: item.amount))
                        
                        Text(item.date)
                            .font(.caption2)
                            .frame(width: barWidth(geometry))
                            .fixedSize()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .overlay(alignment: .leading) {
                yAxisLabels(geometry)
            }
        }
    }
    
    private func barWidth(_ geometry: GeometryProxy) -> CGFloat {
        let availableWidth = geometry.size.width * 0.9
        return max(availableWidth / CGFloat(data.count) - 8, 10)
    }
    
    private func barHeight(_ geometry: GeometryProxy, for value: Double) -> CGFloat {
        let availableHeight = geometry.size.height * 0.8
        let maxValue = data.map { $0.amount }.max() ?? 1
        return CGFloat(value / maxValue) * availableHeight
    }
    
    private func yAxisLabels(_ geometry: GeometryProxy) -> some View {
        let maxValue = data.map { $0.amount }.max() ?? 1
        return VStack(alignment: .leading) {
            Text(NumberFormatter.currency.string(from: NSNumber(value: maxValue)) ?? "$0")
                .font(.caption2)
            
            Spacer()
            
            Text(NumberFormatter.currency.string(from: NSNumber(value: maxValue / 2)) ?? "$0")
                .font(.caption2)
            
            Spacer()
            
            Text("$0")
                .font(.caption2)
        }
        .frame(height: geometry.size.height * 0.8)
    }
}
