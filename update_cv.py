import sys
path = 'ThreeOneOSFive/ContentView.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# UUID mappings
# AIMDRAG.3105 UUID: E6C8911E-AC7F-4078-ABBC-EE57E1F97F3F
# AIMHEAD.3105 UUID: C3770F2A-A799-458F-9AEE-412B31B1CA4A
# AIMMALFORMATION.3105 UUID: 92A3B41B-5B86-45BC-A840-482BAF4BE7E2

# 1. Add States
if '@State private var aimDragEnabled = false' not in text:
    text = text.replace('@State private var aimneckEnabled = false',
                        '@State private var aimneckEnabled = false\n    @State private var aimDragEnabled = false\n    @State private var aimHeadEnabled = false\n    @State private var aimMalformationEnabled = false')

# 2. Add UI rows in category 0
old_aim_ui = """                                    PremiumToggleRow(name: "AIMNECK", pkg: "AIMNECK.3105", isOn: $aimneckEnabled, isBusy: patchOperationBusy) { togglePatch(id: "306FC9CF-433A-4318-9FF3-26C07BFBD0FA", name: "AIMNECK", state: $aimneckEnabled) }"""
new_aim_ui = """                                    PremiumToggleRow(name: "AIMNECK", pkg: "AIMNECK.3105", isOn: $aimneckEnabled, isBusy: patchOperationBusy) { togglePatch(id: "306FC9CF-433A-4318-9FF3-26C07BFBD0FA", name: "AIMNECK", state: $aimneckEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM DRAG", pkg: "AIMDRAG.3105", isOn: $aimDragEnabled, isBusy: patchOperationBusy) { togglePatch(id: "E6C8911E-AC7F-4078-ABBC-EE57E1F97F3F", name: "AIM DRAG", state: $aimDragEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM HEAD", pkg: "AIMHEAD.3105", isOn: $aimHeadEnabled, isBusy: patchOperationBusy) { togglePatch(id: "C3770F2A-A799-458F-9AEE-412B31B1CA4A", name: "AIM HEAD", state: $aimHeadEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM MALFORMATION", pkg: "AIMMALFORMATION.3105", isOn: $aimMalformationEnabled, isBusy: patchOperationBusy) { togglePatch(id: "92A3B41B-5B86-45BC-A840-482BAF4BE7E2", name: "AIM MALFORMATION", state: $aimMalformationEnabled) }"""
text = text.replace(old_aim_ui, new_aim_ui)

# 3. Add to syncPatchStates
if 'aimDragEnabled = isPatchActive' not in text:
    text = text.replace('aimneckEnabled = isPatchActive(id: "306FC9CF-433A-4318-9FF3-26C07BFBD0FA")',
                        'aimneckEnabled = isPatchActive(id: "306FC9CF-433A-4318-9FF3-26C07BFBD0FA")\n        aimDragEnabled = isPatchActive(id: "E6C8911E-AC7F-4078-ABBC-EE57E1F97F3F")\n        aimHeadEnabled = isPatchActive(id: "C3770F2A-A799-458F-9AEE-412B31B1CA4A")\n        aimMalformationEnabled = isPatchActive(id: "92A3B41B-5B86-45BC-A840-482BAF4BE7E2")')

# 4. Add to setPatchState
if 'case "E6C8911E-AC7F-4078-ABBC-EE57E1F97F3F"' not in text:
    text = text.replace('case "306FC9CF-433A-4318-9FF3-26C07BFBD0FA": aimneckEnabled = enabled',
                        'case "306FC9CF-433A-4318-9FF3-26C07BFBD0FA": aimneckEnabled = enabled\n        case "E6C8911E-AC7F-4078-ABBC-EE57E1F97F3F": aimDragEnabled = enabled\n        case "C3770F2A-A799-458F-9AEE-412B31B1CA4A": aimHeadEnabled = enabled\n        case "92A3B41B-5B86-45BC-A840-482BAF4BE7E2": aimMalformationEnabled = enabled')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated ContentView.swift with new Aim patches')
