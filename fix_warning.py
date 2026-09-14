import sys

with open("ThreeOneOSFive/ContentView.swift", "r", encoding="utf-8") as f:
    text = f.read()

old_catch = """                    if let backupRoot = try? PatchProjectLibrary.backupRootURL(),
                       let receipt = DevicePatchService.latestReceipt(projectID: projectID) {
                        try? FileManager.default.removeItem(at: receipt.journalURL)
                    }"""

new_catch = """                    if let receipt = DevicePatchService.latestReceipt(projectID: projectID) {
                        try? FileManager.default.removeItem(at: receipt.journalURL)
                    }"""

text = text.replace(old_catch, new_catch)

with open("ThreeOneOSFive/ContentView.swift", "w", encoding="utf-8") as f:
    f.write(text)
print("Removed backupRoot warning")
