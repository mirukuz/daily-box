// Sources/DailyBoxLib/Views/KanbanItemView.swift
import SwiftUI

public struct KanbanItemView: View {
    let text: String
    let section: Section
    var onDoubleTap: (() -> Void)?
    var onRename: ((String) -> Void)?
    var onDelete: (() -> Void)?
    var onMove: ((Section) -> Void)?

    @State private var isEditing = false
    @State private var editText = ""
    @State private var isHovered = false
    @FocusState private var focused: Bool

    public init(
        text: String,
        section: Section,
        onDoubleTap: (() -> Void)? = nil,
        onRename: ((String) -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onMove: ((Section) -> Void)? = nil
    ) {
        self.text = text
        self.section = section
        self.onDoubleTap = onDoubleTap
        self.onRename = onRename
        self.onDelete = onDelete
        self.onMove = onMove
    }

    public var body: some View {
        Group {
            if isEditing {
                TextField("", text: $editText)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.9))
                    .textFieldStyle(.plain)
                    .focused($focused)
                    .onSubmit { commit() }
                    .onExitCommand { cancel() }
                    .onChange(of: focused) { if !$0 { commit() } }
            } else {
                HStack(spacing: 4) {
                    Circle()
                        .fill(section.color.opacity(0.6))
                        .frame(width: 5, height: 5)
                    Text(text)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if isHovered && onDelete != nil {
                        Button(action: { onDelete?() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isEditing ? section.color.opacity(0.15) : section.color.opacity(0.08))
        .cornerRadius(5)
        .onHover { isHovered = $0 }
        .contextMenu {
            if let onMove {
                ForEach(Section.allCases.filter { $0 != section }, id: \.self) { target in
                    Button("Move to \(target.label)") { onMove(target) }
                }
                Divider()
            }
            if let onDelete {
                Button("Delete", role: .destructive) { onDelete() }
            }
        }
        .draggable("\(section.rawValue):\(text)")
        .onTapGesture(count: 2) {
            onDoubleTap?()
        }
        .onTapGesture(count: 1) {
            guard onRename != nil else { return }
            editText = text
            isEditing = true
            focused = true
        }
    }

    private func commit() {
        let trimmed = editText.trimmingCharacters(in: .whitespaces)
        isEditing = false
        if !trimmed.isEmpty && trimmed != text {
            onRename?(trimmed)
        }
    }

    private func cancel() {
        isEditing = false
        editText = text
    }
}
