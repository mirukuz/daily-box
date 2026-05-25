// Sources/DailyBoxLib/Views/MainView.swift
import SwiftUI

public struct MainView: View {
    @ObservedObject var store: Store
    var onClose: () -> Void
    var onWeeklySummary: () -> Void

    public init(store: Store, onClose: @escaping () -> Void, onWeeklySummary: @escaping () -> Void) {
        self.store = store
        self.onClose = onClose
        self.onWeeklySummary = onWeeklySummary
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(formattedDate)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.leading, 14)
                Spacer()
                Button(action: onClose) {
                    Text("🌙")
                        .font(.system(size: 14))
                        .opacity(0.65)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 12)
            }
            .frame(height: 36)
            .background(Color.white.opacity(0.04))
            // Drag handle: clicking header moves window
            .gesture(
                DragGesture()
                    .onChanged { _ in }  // AppDelegate observes NSPanel's mouseDragged
            )

            Divider()
                .overlay(Color.white.opacity(0.1))

            // Three sections
            ScrollView {
                VStack(spacing: 0) {
                    KanbanSectionView(section: .todo, store: store)
                    Divider().overlay(Color.white.opacity(0.06)).padding(.horizontal, 10)
                    KanbanSectionView(section: .doing, store: store)
                    Divider().overlay(Color.white.opacity(0.06)).padding(.horizontal, 10)
                    KanbanSectionView(section: .done, store: store)
                }
            }

            // Friday button
            if isFriday {
                Divider().overlay(Color.white.opacity(0.06))
                Button(action: onWeeklySummary) {
                    Label("Weekly Summary", systemImage: "sparkles")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 0.78, green: 0.6, blue: 1.0))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.54, green: 0.17, blue: 0.89).opacity(0.15))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 280)
    }

    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE, MMM d"
        return fmt.string(from: Date())
    }

    private var isFriday: Bool {
        Calendar.current.component(.weekday, from: Date()) == 6
    }
}
