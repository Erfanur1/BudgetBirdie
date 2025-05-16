import SwiftUI

struct ShareLink<Label>: View where Label: View {
    var item: Any
    var subject: String?
    var message: String?
    var preview: SharePreview?
    let label: Label
    
    init(item: Any, subject: String? = nil, message: String? = nil, preview: SharePreview? = nil, @ViewBuilder label: () -> Label) {
        self.item = item
        self.subject = subject
        self.message = message
        self.preview = preview
        self.label = label()
    }
    
    var body: some View {
        Button {
            let activityVC = UIActivityViewController(
                activityItems: [item],
                applicationActivities: nil
            )
            
            if let subject = subject {
                activityVC.setValue(subject, forKey: "subject")
            }
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityVC, animated: true, completion: nil)
            }
        } label: {
            label
        }
    }
}

extension ShareLink where Label == Text {
    init(item: Any, subject: String? = nil, message: String? = nil, preview: SharePreview? = nil) {
        self.init(item: item, subject: subject, message: message, preview: preview) {
            Text("Share")
        }
    }
}

struct SharePreview {
    var title: String
    var image: Image?
    
    init(_ title: String, image: Image? = nil) {
        self.title = title
        self.image = image
    }
}
