// Sources/DailyBoxLib/Views/ItemDetailView.swift
import SwiftUI

public struct ItemDetailView: View {
    let item: String
    let section: Section
    @ObservedObject var store: Store
    var onBack: () -> Void

    @State private var isAdding = false
    @State private var newText = ""
    @FocusState private var inputFocused: Bool

    public init(item: String, section: Section, store: Store, onBack: @escaping () -> Void) {
        self.item = item
        self.section = section
        self.store = store
        self.onBack = onBack
    }

    private var subItems: [SubItem] { store.details(for: item) }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .padding(.leading, 6)

                Circle()
                    .fill(section.color.opacity(0.7))
                    .frame(width: 5, height: 5)

                Text(item)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()
            }
            .frame(height: 36)
            .background(Color.white.opacity(0.04))
            .gesture(DragGesture().onChanged { _ in })

            Divider().overlay(Color.white.opacity(0.1))

            // Sub-items
            VStack(alignment: .leading, spacing: 4) {
                Text("NOTES")
                    .font(.system(size: 9, weight: .bold))
                    .kerning(1.0)
                    .foregroundColor(section.color)
                    .padding(.horizontal, 8)

                ForEach(subItems, id: \.text) { sub in
                    SubItemRow(
                        sub: sub,
                        onToggle: { store.toggleDetail(sub.text, forItem: item) },
                        onDelete: { store.removeDetail(sub.text, fromItem: item) }
                    )
                }

                if isAdding {
                    TextField("Add note...", text: $newText)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(5)
                        .padding(.horizontal, 6)
                        .focused($inputFocused)
                        .onSubmit { commitAdd() }
                        .onExitCommand { cancelAdd() }
                } else {
                    Text("+ add note...")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.2))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture { startAdding() }
                }
            }
            .padding(.vertical, 6)
        }
        .frame(width: 280)
    }

    private func startAdding() {
        isAdding = true
        inputFocused = true
    }

    private func commitAdd() {
        store.addDetail(newText, toItem: item)
        newText = ""
        isAdding = false
    }

    private func cancelAdd() {
        newText = ""
        isAdding = false
    }
}

private struct SubItemRow: View {
    let sub: SubItem
    var onToggle: () -> Void
    var onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 6) {
            Button(action: onToggle) {
                Image(systemName: sub.isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 11))
                    .foregroundColor(sub.isChecked ? .white.opacity(0.5) : .white.opacity(0.3))
            }
            .buttonStyle(.plain)

            Text(sub.text)
                .font(.system(size: 11))
                .foregroundColor(sub.isChecked ? .white.opacity(0.35) : .white.opacity(0.8))
                .strikethrough(sub.isChecked, color: .white.opacity(0.3))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.white.opacity(0.25))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color.white.opacity(0.05))
        .cornerRadius(4)
        .padding(.horizontal, 6)
        .onHover { isHovered = $0 }
    }
}
