// Sources/DailyBox/main.swift
import AppKit
import DailyBoxLib

var appDelegate = AppDelegate()
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
app.delegate = appDelegate
app.run()
