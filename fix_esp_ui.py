import re

with open("ThreeOneOSFive/ContentView.swift", "r", encoding="utf-8") as f:
    text = f.read()

# Fix Picker
text = re.sub(
    r'(Picker\("Category", selection: \$selectedScriptCategory\) \{\n\s*Text\("Aim"\)\.tag\(0\)\n\s*Text\("Skin"\)\.tag\(1\)\n\s*Text\("Chams"\)\.tag\(2\)\n\s*)(\})',
    r'\1Text("ESP").tag(3)\n                              \2',
    text
)

# Insert ESP block
esp_block = """                            } else if selectedScriptCategory == 3 {
                                VStack(spacing: 0) {
                                    PremiumToggleRow(name: "ESP FREE FIRE TH", pkg: "com.dts.freefireth", isOn: $espFFTHEnabled, isBusy: patchOperationBusy, isDisabled: !appState.exploitStatus.isSuccess) { togglePatch(id: "DE5A2E93-C78A-4A24-B401-9D25F4443505", name: "ESP FREE FIRE TH", state: $espFFTHEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "ESP FREE FIRE MAX", pkg: "com.dts.freefiremax", isOn: $espFFMAXEnabled, isBusy: patchOperationBusy, isDisabled: !appState.exploitStatus.isSuccess) { togglePatch(id: "C1B4ACD2-2320-45E3-80B4-936B46076140", name: "ESP FREE FIRE MAX", state: $espFFMAXEnabled) }
                                }
                                .background(Color.black.opacity(0.3))
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
"""
# find the end of category == 2 block
text = re.sub(
    r'(\} else if selectedScriptCategory == 2 \{[\s\S]*?\.shadow\(color: Color\.black\.opacity\(0\.2\), radius: 10, y: 5\)\n\s*)(\})',
    r'\1' + esp_block + r'                            \2',
    text
)

with open("ThreeOneOSFive/ContentView.swift", "w", encoding="utf-8") as f:
    f.write(text)
print("Updated ContentView.swift with ESP block")
