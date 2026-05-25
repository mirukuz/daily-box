// Sources/DailyBoxLib/Views/MainView.swift
import SwiftUI

public struct MainView: View {
    @ObservedObject var store: Store
    var onClose: () -> Void
    var onWeeklySummary: () -> Void

    @State private var dayOffset: Int = 0  // 0 = today, -1 = yesterday, etc.

    public init(store: Store, onClose: @escaping () -> Void, onWeeklySummary: @escaping () -> Void) {
        self.store = store
        self.onClose = onClose
        self.onWeeklySummary = onWeeklySummary
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 4) {
                Button(action: { dayOffset -= 1 }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .padding(.leading, 6)

                Spacer()

                Text(formattedViewingDate)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))

                Spacer()

                Button(action: { dayOffset += 1 }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(dayOffset < 0 ? .white.opacity(0.4) : .white.opacity(0.15))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .disabled(dayOffset >= 0)

                Button(action: onClose) {
                    Text("🌙")
                        .font(.system(size: 14))
                        .opacity(0.65)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 10)
            }
            .frame(height: 36)
            .background(Color.white.opacity(0.04))
            .gesture(DragGesture().onChanged { _ in })

            Divider()
                .overlay(Color.white.opacity(0.1))

            if isViewingWeekend {
                Text("Take a break 🌿")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.35))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                let isToday = dayOffset == 0
                let pastRecord = isToday ? nil : store.record(daysAgo: -dayOffset)

                VStack(spacing: 0) {
                    KanbanSectionView(section: .todo, store: store, isEditable: isToday, record: pastRecord)
                    Divider().overlay(Color.white.opacity(0.06)).padding(.horizontal, 10)
                    KanbanSectionView(section: .doing, store: store, isEditable: isToday, record: pastRecord)
                    Divider().overlay(Color.white.opacity(0.06)).padding(.horizontal, 10)
                    KanbanSectionView(section: .done, store: store, isEditable: isToday, record: pastRecord)
                }

                if isToday && isFriday {
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
        }
        .frame(width: 280)
    }

    // MARK: - Helpers

    private static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE, MMM d"
        return fmt
    }()

    private var viewingDate: Date {
        Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
    }

    private var formattedViewingDate: String {
        Self.dateFormatter.string(from: viewingDate)
    }

    private var isFriday: Bool {
        Calendar.current.component(.weekday, from: Date()) == 6
    }

    private var isViewingWeekend: Bool {
        let w = Calendar.current.component(.weekday, from: viewingDate)
        return w == 1 || w == 7
    }
}
