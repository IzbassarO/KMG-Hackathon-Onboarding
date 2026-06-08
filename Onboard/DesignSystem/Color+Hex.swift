import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

extension Color {
    /// Builds a color from a 0xRRGGBB integer.
    init(rgb: UInt, alpha: Double = 1) {
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    /// Resolves a named asset color, falling back to appearance-aware hex values
    /// when the asset is not present in the catalog yet. This lets the app look
    /// fully designed out of the box, while still letting designers override the
    /// palette by adding color sets with the same name to Assets.xcassets.
    init(asset name: String, light: UInt, dark: UInt) {
        #if canImport(UIKit)
        if UIColor(named: name) != nil {
            self = Color(name, bundle: .main)
            return
        }
        let dynamic = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(rgb: dark)
                : UIColor(rgb: light)
        }
        self = Color(dynamic)
        #else
        self = Color(rgb: light)
        #endif
    }
}

#if canImport(UIKit)
extension UIColor {
    convenience init(rgb: UInt, alpha: CGFloat = 1) {
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
#endif
