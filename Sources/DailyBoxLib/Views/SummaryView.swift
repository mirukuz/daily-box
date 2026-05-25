// Sources/DailyBoxLib/Views/SummaryView.swift
import SwiftUI

public struct SummaryView: View {
    let text: String
    @State private var copied = false

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Summary")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)

            ScrollView {
                Text(text)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }

            HStack {
                Spacer()
                Button(copied ? "Copied!" : "Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        copied = false
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 500, height: 400)
    }
}
