import sys
import re
path = 'ThreeOneOSFive/ContentView.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Replace states
text = re.sub(r'@State private var aimDragEnabled = false.*?\n\s*@State private var magicEnabled = false', 
    '''@State private var aimBody90Enabled = false
    @State private var aimlockModeEnabled = false
    @State private var aimneckEnabled = false''', text, flags=re.DOTALL)

# Replace toggles
text = re.sub(r'PremiumToggleRow\(name: "Aim Drag".*?togglePatch\(pkg: "OGIOS File \(14\).3105", state: \$magicEnabled\) }',
    '''PremiumToggleRow(name: "AIM BODY 90%", pkg: "AIM BODY 90%.3105", isOn: $aimBody90Enabled, isBusy: patchOperationBusy) { togglePatch(pkg: "AIM BODY 90%.3105", state: $aimBody90Enabled) }
                                Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                PremiumToggleRow(name: "AIMLOCK MODE", pkg: "AIMLOCK MODE.3105", isOn: $aimlockModeEnabled, isBusy: patchOperationBusy) { togglePatch(pkg: "AIMLOCK MODE.3105", state: $aimlockModeEnabled) }
                                Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                PremiumToggleRow(name: "AIMNECK", pkg: "AIMNECK.3105", isOn: $aimneckEnabled, isBusy: patchOperationBusy) { togglePatch(pkg: "AIMNECK.3105", state: $aimneckEnabled) }''', text, flags=re.DOTALL)

# Replace syncPatchStates
text = re.sub(r'private func syncPatchStates\(\) \{.*?\}',
    '''private func syncPatchStates() {
        aimBody90Enabled = isPatchActive("AIM BODY 90%.3105")
        aimlockModeEnabled = isPatchActive("AIMLOCK MODE.3105")
        aimneckEnabled = isPatchActive("AIMNECK.3105")
    }''', text, flags=re.DOTALL)

# Replace setPatchState
text = re.sub(r'private func setPatchState\(for packageFilename: String, enabled: Bool\) \{.*?\}',
    '''private func setPatchState(for packageFilename: String, enabled: Bool) {
        switch packageFilename {
        case "AIM BODY 90%.3105": aimBody90Enabled = enabled
        case "AIMLOCK MODE.3105": aimlockModeEnabled = enabled
        case "AIMNECK.3105": aimneckEnabled = enabled
        default: break
        }
    }''', text, flags=re.DOTALL)

# Replace pkg display
text = text.replace('Text(pkg)', 'Text(pkg.replacingOccurrences(of: ".3105", with: ""))')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Patched ContentView.swift successfully.')
