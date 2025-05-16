import SwiftUI

extension View {
    @ViewBuilder
    func onValueChange<T: Equatable>(of value: T, perform action: @escaping (T) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            self.onChange(of: value) { newValue in
                action(newValue)
            }
        }
    }
}
