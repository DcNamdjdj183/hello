import re

with open("ThreeOneOSFive/ContentView.swift", "r", encoding="utf-8") as f:
    text = f.read()

# 2. Add to Picker
text = re.sub(
    r'(Picker\("Category", selection: \$selectedScriptCategory\) \{\n\s*Text\("AIM"\)\.tag\(0\)\n\s*Text\("SKIN"\)\.tag\(1\)\n\s*Text\("CHAMS"\)\.tag\(2\)\n\s*)(\})',
    r'\1Text("ESP").tag(3)\n                              \2',
    text
)

# 3. Add to category switch
esp_code = """                              } else if selectedScriptCategory == 3 {
                                  VStack(spacing: 0) {
                                      PremiumToggleRow(name: "ESP FREE FIRE TH", pkg: "ESP_FREE_FIRE_TH.3105", isOn: $espFFTHEnabled, isBusy: patchOperationBusy) { togglePatch(id: "DE5A2E93-C78A-4A24-B401-9D25F4443505", name: "ESP FREE FIRE TH", state: $espFFTHEnabled) }
                                      Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                      PremiumToggleRow(name: "ESP FREE FIRE MAX", pkg: "ESP_FREE_FIRE_MAX.3105", isOn: $espFFMAXEnabled, isBusy: patchOperationBusy) { togglePatch(id: "C1B4ACD2-2320-45E3-80B4-936B46076140", name: "ESP FREE FIRE MAX", state: $espFFMAXEnabled) }
                                  }
                                  .background(Color.black.opacity(0.3))
                                  .background(.ultraThinMaterial)
                                  .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                  .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                  .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
"""
text = re.sub(
    r'(\}\n\s*\.background\(Color\.black\.opacity\(0\.3\)\)\n\s*\.background\(\.ultraThinMaterial\)\n\s*\.clipShape\(RoundedRectangle\(cornerRadius: 24, style: \.continuous\)\)\n\s*\.overlay\(RoundedRectangle\(cornerRadius: 24, style: \.continuous\)\.stroke\(Color\.white\.opacity\(0\.15\), lineWidth: 1\)\)\n\s*\.shadow\(color: Color\.black\.opacity\(0\.2\), radius: 10, y: 5\)\n\s*)(\})',
    r'\1' + esp_code + r'                              \2',
    text
)

# 4. Add to syncPatchStates
text = re.sub(
    r'(chamsBlueEnabled = isPatchActive\(id: "A677DFE5-1355-4CC8-9137-C54A5E85B882"\)\n\s*)(\})',
    r'\1    espFFTHEnabled = isPatchActive(id: "DE5A2E93-C78A-4A24-B401-9D25F4443505")\n        espFFMAXEnabled = isPatchActive(id: "C1B4ACD2-2320-45E3-80B4-936B46076140")\n    \2',
    text
)

# 5. Add to setPatchState
text = re.sub(
    r'(case "A677DFE5-1355-4CC8-9137-C54A5E85B882": chamsBlueEnabled = enabled\n\s*)(default: break)',
    r'\1case "DE5A2E93-C78A-4A24-B401-9D25F4443505": espFFTHEnabled = enabled\n        case "C1B4ACD2-2320-45E3-80B4-936B46076140": espFFMAXEnabled = enabled\n        \2',
    text
)

with open("ThreeOneOSFive/ContentView.swift", "w", encoding="utf-8") as f:
    f.write(text)
print("Updated ContentView.swift with ESP section using regex")
