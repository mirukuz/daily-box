// Sources/DailyBoxLib/Views/KanbanItemView.swift
import SwiftUI

public struct KanbanItemView: View {
    let text: String
    let section: Section

    public init(text: String, section: Section) {
        self.text = text
        self.section = section
    }

    public var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(section.color.opacity(0.6))
                .frame(width: 5, height: 5)
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(section.color.opacity(0.08))
        .cornerRadius(5)
        .draggable("\(section.rawValue):\(text)")
    }

}
