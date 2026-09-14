import sys

with open("ThreeOneOSFive/ContentView.swift", "r", encoding="utf-8") as f:
    text = f.read()

old_catch = """            } catch {
                result = .unavailable("Error: \\(error.localizedDescription)")
            }

            DispatchQueue.main.async {"""

new_catch = """            } catch {
                if wasEnabled {
                    // If restore fails while exploit is active, it usually means the game was updated/reinstalled
                    // and the container fingerprint or file hashes changed. Force clear the receipt.
                    if let backupRoot = try? PatchProjectLibrary.backupRootURL(),
                       let receipt = DevicePatchService.latestReceipt(projectID: projectID) {
                        try? FileManager.default.removeItem(at: receipt.journalURL)
                    }
                    result = .restored
                    DispatchQueue.main.async {
                        self.patchMessage = "Forced Off (Target Changed)"
                    }
                } else {
                    result = .unavailable("Error: \\(error.localizedDescription)")
                }
            }

            DispatchQueue.main.async {"""

text = text.replace(old_catch, new_catch)

with open("ThreeOneOSFive/ContentView.swift", "w", encoding="utf-8") as f:
    f.write(text)
print("Updated catch block in togglePatch")
