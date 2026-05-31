import SwiftUI

extension Color {
    init(hex: String) {
        let sanitized = hex
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            .uppercased()

        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let alpha: UInt64
        let red: UInt64
        let green: UInt64
        let blue: UInt64

        switch sanitized.count {
        case 8:
            alpha = (value & 0xFF000000) >> 24
            red = (value & 0x00FF0000) >> 16
            green = (value & 0x0000FF00) >> 8
            blue = value & 0x000000FF
        case 6:
            alpha = 255
            red = (value & 0xFF0000) >> 16
            green = (value & 0x00FF00) >> 8
            blue = value & 0x0000FF
        default:
            alpha = 255
            red = 17
            green = 24
            blue = 39
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

enum BrandPalette {
    static let backgrounds = [
        "#F6F7FB",
        "#EEF2FF",
        "#ECFEFF",
        "#FFF7ED",
        "#111827",
        "#0F172A"
    ]

    static let accents = [
        "#246BFE",
        "#635BFF",
        "#0EA5E9",
        "#10B981",
        "#F97316",
        "#EF4444",
        "#111827",
        "#FFFFFF"
    ]
}
