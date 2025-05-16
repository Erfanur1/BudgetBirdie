import SwiftUI

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case transportation = "Transportation"
    case entertainment = "Entertainment"
    case utilities = "Utilities"
    case rent = "Rent"
    case education = "Education"
    case healthcare = "Healthcare"
    case shopping = "Shopping"
    case groceries = "Groceries"
    case miscellaneous = "Miscellaneous"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "bus"
        case .entertainment: return "tv"
        case .utilities: return "bolt"
        case .rent: return "house"
        case .education: return "book"
        case .healthcare: return "heart"
        case .shopping: return "bag"
        case .groceries: return "cart"
        case .miscellaneous: return "ellipsis"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .red
        case .transportation: return .blue
        case .entertainment: return .purple
        case .utilities: return .yellow
        case .rent: return .green
        case .education: return .orange
        case .healthcare: return .pink
        case .shopping: return .indigo
        case .groceries: return .teal
        case .miscellaneous: return .gray
        }
    }
}
