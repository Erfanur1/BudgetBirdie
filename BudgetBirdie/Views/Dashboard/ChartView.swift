import SwiftUI
import Charts



@available(iOS 16.0, *)
struct ChartView: View {
    let data: [CategoryAmount]
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Category", item.category))
                .annotation(position: .overlay) {
                    Text(item.category)
                        .font(.caption)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
        }
    }
}
