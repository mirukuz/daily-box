// Sources/DailyBox/main.swift
import AppKit
import DailyBoxLib

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
