import sys

path = 'ThreeOneOSFive/ContentView.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

old_switch = """                switch result {
                case .applied:
                    self.setPatchState(for: id, enabled: true)
                    self.patchMessage = "Script Injected!"
                    PatchAudioFeedback.bypassActivated()
                case .restored:
                    self.setPatchState(for: id, enabled: false)
                    self.patchMessage = "Script Restored!"
                    PatchAudioFeedback.originalRestored()
                case .unavailable(let message):
                    self.patchMessage = message
                }
                self.patchOperationBusy = false"""

new_switch = """                DispatchQueue.main.async {
                    switch result {
                    case .applied:
                        self.setPatchState(for: id, enabled: true)
                        self.patchMessage = "Script Injected!"
                        PatchAudioFeedback.bypassActivated()
                    case .restored:
                        self.setPatchState(for: id, enabled: false)
                        self.patchMessage = "Script Restored!"
                        PatchAudioFeedback.originalRestored()
                    case .unavailable(let message):
                        self.patchMessage = message
                    }
                    self.patchOperationBusy = false
                }"""

text = text.replace(old_switch, new_switch)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Fixed background thread UI updates')
