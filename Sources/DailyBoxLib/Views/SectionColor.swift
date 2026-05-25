// Sources/DailyBoxLib/Views/SectionColor.swift
import SwiftUI

extension Section {
    var color: Color {
        switch self {
        case .todo:  return Color(red: 0.7, green: 0.7, blue: 1.0)
        case .doing: return Color(red: 1.0, green: 0.75, blue: 0.3)
        case .done:  return Color(red: 0.4, green: 0.85, blue: 0.55)
        }
    }
}
