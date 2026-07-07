import SwiftUI

/// Batch Felt - Felting Log's own palette: distinct from every sibling app in the portfolio.
enum BFTheme {
    static let backdrop = Color(red: 0.965, green: 0.949, blue: 0.949)
    static let card = Color.white

    static let ink = Color(red: 0.145, green: 0.106, blue: 0.114)
    static let inkFaded = Color(red: 0.145, green: 0.106, blue: 0.114).opacity(0.56)

    static let accent = Color(red: 0.612, green: 0.353, blue: 0.443)
    static let accentDeep = Color(red: 0.532, green: 0.27299999999999996, blue: 0.363)
    static let accent2 = Color(red: 0.353, green: 0.494, blue: 0.408)

    static let rule = Color.black.opacity(0.06)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let displayFont = Font.system(size: 40, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct BFDismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(BFDismissKeyboardOnTap())
    }
}

enum BFHaptics {
    static var enabled: Bool = true

    static func light() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
