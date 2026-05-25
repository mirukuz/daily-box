# DailyBox

A minimal macOS floating window app for daily task tracking. Lives on top of all your windows, stays out of the way.

## Features

- **Floating kanban panel** — always-on-top glassmorphism window with three sections: Todo, Doing, Done
- **Drag to move between sections** — drag any item across sections to update its status
- **Adaptive height** — window grows and shrinks to fit content, no wasted space
- **Day navigation** — use `‹` `›` in the header to browse previous days (read-only)
- **End-of-day ritual** — click 🌙 to collapse the panel into a small floating 📦 box; click the box the next morning to reopen
- **Day carryover** — on a new day, todo and doing items carry forward automatically; done is cleared
- **Weekend rest** — Saturday and Sunday show a rest message instead of the kanban board
- **Friday weekly summary** — a plain-text summary of the week appears as a popup every Friday
- **Menu bar icon** — click the tray icon for quick access; "View in Markdown" shows your full history formatted as Markdown (weekends excluded)
- **Persisted data** — everything is saved to `~/Library/Application Support/DailyBox/` as daily JSON files
- **No Dock icon** — runs as a background accessory app; right-click the floating panel to quit

## Requirements

- macOS 13 (Ventura) or later
- Xcode command-line tools (`xcode-select --install`)

## Build

```bash
# Debug build
swift build

# Release .app bundle
make bundle

# Run directly
make run
```

The built app appears at `./DailyBox.app`.

## Project Structure

```
Sources/
  DailyBox/               # Executable target
    main.swift            # App entry point, sets activation policy
    AppDelegate.swift     # Window lifecycle, status bar item, animations

  DailyBoxLib/            # Library target (testable)
    Models/
      DayRecord.swift     # Codable day record (todo/doing/done + positions)
    Store/
      Store.swift         # Persistence, day transition, history loading
    Views/
      MainView.swift      # Root SwiftUI view with header and day navigation
      KanbanSectionView.swift  # One kanban column with inline add and drop target
      KanbanItemView.swift     # Single draggable item
      SectionColor.swift       # Color theme per section
    Windows/
      FloatingPanel.swift      # NSPanel subclass with adaptive height
      BoxPanel.swift           # Collapsed 52×62px box state
      SummaryWindow.swift      # Friday weekly summary popup
      MarkdownHistoryWindow.swift  # Full history markdown viewer
    Animation/
      CloseAnimator.swift      # Collapse and expand animations

Tests/
  DailyBoxTests/
    StoreTests.swift
    DayRecordTests.swift
    WeeklySummaryTests.swift
```

## Data Format

Each day is stored as a JSON file named `YYYY-MM-DD.json`:

```json
{
  "date": "2026-05-26",
  "todo": ["Write tests", "Review PR"],
  "doing": ["Implement feature X"],
  "done": ["Fix bug Y"],
  "windowPosition": [1212.0, 862.0],
  "boxPosition": [1309.0, 900.0],
  "isClosed": false
}
```

## License

MIT
