import sys

with open("ThreeOneOSFive/ContentView.swift", "r", encoding="utf-8") as f:
    text = f.read()

if "@State private var showLog = false" not in text:
    text = text.replace("@State private var showCleaner = false", "@State private var showCleaner = false\n    @State private var showLog = false")
    
if ".sheet(isPresented: $showLog) { LogView() }" not in text:
    text = text.replace(".sheet(isPresented: $showCleaner) { CleanerView() }", ".sheet(isPresented: $showCleaner) { CleanerView() }\n        .sheet(isPresented: $showLog) { LogView() }\n        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(\"ShowLogView\"))) { _ in\n            showLog = true\n        }")

with open("ThreeOneOSFive/ContentView.swift", "w", encoding="utf-8") as f:
    f.write(text)
print("Added state and sheet for LogView")
