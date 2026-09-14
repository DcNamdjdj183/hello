import sys

path = 'ThreeOneOSFive/ContentView.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. State Variables Update
state_vars_old = """    @State private var aimneckEnabled = false
    @State private var aimDragEnabled = false
    @State private var aimHeadEnabled = false
    @State private var aimMalformationEnabled = false"""
state_vars_new = """    @State private var aimneckEnabled = false
    @State private var aimDragEnabled = false
    @State private var aimHeadEnabled = false
    @State private var aimMalformationEnabled = false
    @State private var aimNeckAntenaEnabled = false
    @State private var aimBodyLobbyEnabled = false
    @State private var aimChestLobbyEnabled = false
    @State private var aimDragLobbyEnabled = false
    @State private var aimNeckLobbyEnabled = false
    @State private var magicBulletLobbyEnabled = false"""

if '@State private var aimNeckAntenaEnabled' not in text:
    text = text.replace(state_vars_old, state_vars_new)

# 2. View Update
old_aim_ui = """                            if selectedScriptCategory == 0 {
                                VStack(spacing: 0) {
                                    PremiumToggleRow(name: "AIM BODY 90%", pkg: "AIMBODY90.3105", isOn: $aimBody90Enabled, isBusy: patchOperationBusy) { togglePatch(id: "C19CBA7B-C108-4752-9221-4950D1B9E096", name: "AIM BODY 90%", state: $aimBody90Enabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIMLOCK MODE", pkg: "AIMLOCKMODE.3105", isOn: $aimlockModeEnabled, isBusy: patchOperationBusy) { togglePatch(id: "161B8454-5C89-4BF2-93D9-B60ECDF2E154", name: "AIMLOCK MODE", state: $aimlockModeEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIMNECK", pkg: "AIMNECK.3105", isOn: $aimneckEnabled, isBusy: patchOperationBusy) { togglePatch(id: "306FC9CF-433A-4318-9FF3-26C07BFBD0FA", name: "AIMNECK", state: $aimneckEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM DRAG", pkg: "AIMDRAG.3105", isOn: $aimDragEnabled, isBusy: patchOperationBusy) { togglePatch(id: "E6C8911E-AC7F-4078-ABBC-EE57E1F97F3F", name: "AIM DRAG", state: $aimDragEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM HEAD", pkg: "AIMHEAD.3105", isOn: $aimHeadEnabled, isBusy: patchOperationBusy) { togglePatch(id: "C3770F2A-A799-458F-9AEE-412B31B1CA4A", name: "AIM HEAD", state: $aimHeadEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM MALFORMATION", pkg: "AIMMALFORMATION.3105", isOn: $aimMalformationEnabled, isBusy: patchOperationBusy) { togglePatch(id: "92A3B41B-5B86-45BC-A840-482BAF4BE7E2", name: "AIM MALFORMATION", state: $aimMalformationEnabled) }
                                }
                                .background(Color.black.opacity(0.3))
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
                            }"""

new_aim_ui = """                            if selectedScriptCategory == 0 {
                                Text("ASSETINDERXER")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                    .padding(.top, 4)

                                VStack(spacing: 0) {
                                    PremiumToggleRow(name: "AIM BODY 90%", pkg: "Log 40%", isOn: $aimBody90Enabled, isBusy: patchOperationBusy) { togglePatch(id: "C19CBA7B-C108-4752-9221-4950D1B9E096", name: "AIM BODY 90%", state: $aimBody90Enabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIMLOCK MODE", pkg: "Log 40%", isOn: $aimlockModeEnabled, isBusy: patchOperationBusy) { togglePatch(id: "161B8454-5C89-4BF2-93D9-B60ECDF2E154", name: "AIMLOCK MODE", state: $aimlockModeEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIMNECK", pkg: "Log 40%", isOn: $aimneckEnabled, isBusy: patchOperationBusy) { togglePatch(id: "306FC9CF-433A-4318-9FF3-26C07BFBD0FA", name: "AIMNECK", state: $aimneckEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM DRAG", pkg: "Log 40%", isOn: $aimDragEnabled, isBusy: patchOperationBusy) { togglePatch(id: "E6C8911E-AC7F-4078-ABBC-EE57E1F97F3F", name: "AIM DRAG", state: $aimDragEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM HEAD", pkg: "Log 40%", isOn: $aimHeadEnabled, isBusy: patchOperationBusy) { togglePatch(id: "C3770F2A-A799-458F-9AEE-412B31B1CA4A", name: "AIM HEAD", state: $aimHeadEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM MALFORMATION", pkg: "Log 40%", isOn: $aimMalformationEnabled, isBusy: patchOperationBusy) { togglePatch(id: "92A3B41B-5B86-45BC-A840-482BAF4BE7E2", name: "AIM MALFORMATION", state: $aimMalformationEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM NECK ANTENA", pkg: "Log 40%", isOn: $aimNeckAntenaEnabled, isBusy: patchOperationBusy) { togglePatch(id: "497EDBD6-FA5C-4015-88CD-6C3DFE4C827F", name: "AIM NECK ANTENA", state: $aimNeckAntenaEnabled) }
                                }
                                .background(Color.black.opacity(0.3))
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)

                                Text("CACHE RES")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                    .padding(.top, 16)

                                VStack(spacing: 0) {
                                    PremiumToggleRow(name: "AIM BODY (Bật Sảnh)", pkg: "Bật Sảnh", isOn: $aimBodyLobbyEnabled, isBusy: patchOperationBusy) { togglePatch(id: "3BD95FBE-B0C3-40B7-88C0-AEB2A9B9D8C8", name: "AIM BODY (Bật Sảnh)", state: $aimBodyLobbyEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM CHEST (Bật Sảnh)", pkg: "Bật Sảnh", isOn: $aimChestLobbyEnabled, isBusy: patchOperationBusy) { togglePatch(id: "5AA0E78E-7AAF-4980-AD85-4780B3C079AE", name: "AIM CHEST (Bật Sảnh)", state: $aimChestLobbyEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM DRAG (Bật Sảnh)", pkg: "Bật Sảnh", isOn: $aimDragLobbyEnabled, isBusy: patchOperationBusy) { togglePatch(id: "97D18C40-6BFB-421B-A434-B3A5E3E83A17", name: "AIM DRAG (Bật Sảnh)", state: $aimDragLobbyEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM NECK (Bật Sảnh)", pkg: "Bật Sảnh", isOn: $aimNeckLobbyEnabled, isBusy: patchOperationBusy) { togglePatch(id: "1AE45A6B-4861-48B2-9647-2B2D5713A9C3", name: "AIM NECK (Bật Sảnh)", state: $aimNeckLobbyEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "MAGIC BULLET (Bật Sảnh)", pkg: "Bật Sảnh", isOn: $magicBulletLobbyEnabled, isBusy: patchOperationBusy) { togglePatch(id: "47AE459A-0707-4A7F-A831-96CE1381859C", name: "MAGIC BULLET (Bật Sảnh)", state: $magicBulletLobbyEnabled) }
                                }
                                .background(Color.black.opacity(0.3))
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
                            }"""

text = text.replace(old_aim_ui, new_aim_ui)

# 3. isPatchActive mapping
sync_old = """        aimMalformationEnabled = isPatchActive(id: "92A3B41B-5B86-45BC-A840-482BAF4BE7E2")"""
sync_new = """        aimMalformationEnabled = isPatchActive(id: "92A3B41B-5B86-45BC-A840-482BAF4BE7E2")
        aimNeckAntenaEnabled = isPatchActive(id: "497EDBD6-FA5C-4015-88CD-6C3DFE4C827F")
        aimBodyLobbyEnabled = isPatchActive(id: "3BD95FBE-B0C3-40B7-88C0-AEB2A9B9D8C8")
        aimChestLobbyEnabled = isPatchActive(id: "5AA0E78E-7AAF-4980-AD85-4780B3C079AE")
        aimDragLobbyEnabled = isPatchActive(id: "97D18C40-6BFB-421B-A434-B3A5E3E83A17")
        aimNeckLobbyEnabled = isPatchActive(id: "1AE45A6B-4861-48B2-9647-2B2D5713A9C3")
        magicBulletLobbyEnabled = isPatchActive(id: "47AE459A-0707-4A7F-A831-96CE1381859C")"""
if 'aimNeckAntenaEnabled = isPatchActive' not in text:
    text = text.replace(sync_old, sync_new)

# 4. setPatchState mapping
set_old = """        case "92A3B41B-5B86-45BC-A840-482BAF4BE7E2": aimMalformationEnabled = enabled"""
set_new = """        case "92A3B41B-5B86-45BC-A840-482BAF4BE7E2": aimMalformationEnabled = enabled
        case "497EDBD6-FA5C-4015-88CD-6C3DFE4C827F": aimNeckAntenaEnabled = enabled
        case "3BD95FBE-B0C3-40B7-88C0-AEB2A9B9D8C8": aimBodyLobbyEnabled = enabled
        case "5AA0E78E-7AAF-4980-AD85-4780B3C079AE": aimChestLobbyEnabled = enabled
        case "97D18C40-6BFB-421B-A434-B3A5E3E83A17": aimDragLobbyEnabled = enabled
        case "1AE45A6B-4861-48B2-9647-2B2D5713A9C3": aimNeckLobbyEnabled = enabled
        case "47AE459A-0707-4A7F-A831-96CE1381859C": magicBulletLobbyEnabled = enabled"""
if 'case "497EDBD6-FA5C-4015-88CD-6C3DFE4C827F": aimNeckAntenaEnabled' not in text:
    text = text.replace(set_old, set_new)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated ContentView.swift sections')
