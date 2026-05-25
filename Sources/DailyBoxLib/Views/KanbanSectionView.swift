// Sources/DailyBoxLib/Views/KanbanSectionView.swift
import SwiftUI

public struct KanbanSectionView: View {
    let section: Section
    @ObservedObject var store: Store
    var isEditable: Bool
    var record: DayRecord?  // non-nil when viewing a past day read-only
    @State private var isAddingItem = false
    @State private var newItemText = ""
    @FocusState private var inputFocused: Bool

    public init(section: Section, store: Store, isEditable: Bool = true, record: DayRecord? = nil) {
        self.section = section
        self.store = store
        self.isEditable = isEditable
        self.record = record
    }

    private var items: [String] {
        let src = record ?? store.record
        switch section {
        case .todo:  return src.todo
        case .doing: return src.doing
        case .done:  return src.done
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Section label
            Text(section.label)
                .font(.system(size: 9, weight: .bold))
                .kerning(1.0)
                .foregroundColor(section.color)
                .padding(.horizontal, 8)

            // Items
            ForEach(items, id: \.self) { item in
                KanbanItemView(text: item, section: section)
                    .padding(.horizontal, 6)
            }

            // Inline add (today only)
            if isEditable {
                if isAddingItem {
                    TextField("Add item...", text: $newItemText)
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
                    Text("+ add item...")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.2))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 2)
                        .onTapGesture { startAdding() }
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.vertical, 6)
        .dropDestination(for: String.self) { droppedItems, _ in
            guard isEditable else { return false }
            for payload in droppedItems { handleDrop(payload) }
            return true
        }
        .contentShape(Rectangle())
        .onTapGesture { if isEditable && !isAddingItem { startAdding() } }
    }

    // MARK: - Private

    private func startAdding() {
        isAddingItem = true
        inputFocused = true
    }

    private func commitAdd() {
        store.addItem(newItemText, to: section)
        newItemText = ""
        isAddingItem = false
    }

    private func cancelAdd() {
        newItemText = ""
        isAddingItem = false
    }

    private func handleDrop(_ payload: String) {
        // Payload format: "sourceSectionRawValue:itemText"
        let parts = payload.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2,
              let fromSection = Section(rawValue: parts[0]) else { return }
        let itemText = parts[1]
        guard fromSection != section else { return }
        store.moveItem(itemText, from: fromSection, to: section)
    }
}
