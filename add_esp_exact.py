import re

with open("ThreeOneOSFive/ContentView.swift", "r", encoding="utf-8") as f:
    text = f.read()

# 1. Add state variables
if "@State private var espFFTHEnabled = false" not in text:
    text = text.replace("@State private var chamsBlueEnabled = false", "@State private var chamsBlueEnabled = false\n    @State private var espFFTHEnabled = false\n    @State private var espFFMAXEnabled = false")

# 2. Add to Picker
old_picker = """                              Picker("Category", selection: $selectedScriptCategory) {
                                  Text("AIM").tag(0)
                                  Text("SKIN").tag(1)
                                  Text("CHAMS").tag(2)
                              }"""
new_picker = """                              Picker("Category", selection: $selectedScriptCategory) {
                                  Text("AIM").tag(0)
                                  Text("SKIN").tag(1)
                                  Text("CHAMS").tag(2)
                                  Text("ESP").tag(3)
                              }"""
text = text.replace(old_picker, new_picker)

# 3. Add to category switch
old_chams_block = """                              } else if selectedScriptCategory == 2 {
                                  VStack(spacing: 0) {
                                      PremiumToggleRow(name: "CHAMS BLUE", pkg: "CHAMS-BLUE.3105", isOn: $chamsBlueEnabled, isBusy: patchOperationBusy) { togglePatch(id: "A677DFE5-1355-4CC8-9137-C54A5E85B882", name: "CHAMS BLUE", state: $chamsBlueEnabled) }
                                  }
                                  .background(Color.black.opacity(0.3))
                                  .background(.ultraThinMaterial)
                                  .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                  .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                  .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
                              }"""
new_chams_and_esp = old_chams_block + """ else if selectedScriptCategory == 3 {
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
                              }"""
text = text.replace(old_chams_block, new_chams_and_esp)

# 4. Add to syncPatchStates
old_sync = """        chamsBlueEnabled = isPatchActive(id: "A677DFE5-1355-4CC8-9137-C54A5E85B882")
    }"""
new_sync = """        chamsBlueEnabled = isPatchActive(id: "A677DFE5-1355-4CC8-9137-C54A5E85B882")
        espFFTHEnabled = isPatchActive(id: "DE5A2E93-C78A-4A24-B401-9D25F4443505")
        espFFMAXEnabled = isPatchActive(id: "C1B4ACD2-2320-45E3-80B4-936B46076140")
    }"""
text = text.replace(old_sync, new_sync)

# 5. Add to setPatchState
old_set = """        case "A677DFE5-1355-4CC8-9137-C54A5E85B882": chamsBlueEnabled = enabled
        default: break"""
new_set = """        case "A677DFE5-1355-4CC8-9137-C54A5E85B882": chamsBlueEnabled = enabled
        case "DE5A2E93-C78A-4A24-B401-9D25F4443505": espFFTHEnabled = enabled
        case "C1B4ACD2-2320-45E3-80B4-936B46076140": espFFMAXEnabled = enabled
        default: break"""
text = text.replace(old_set, new_set)

with open("ThreeOneOSFive/ContentView.swift", "w", encoding="utf-8") as f:
    f.write(text)
print("Updated ContentView.swift exactly")
