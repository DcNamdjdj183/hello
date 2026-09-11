import sys
path = 'ThreeOneOSFive/ContentView.swift'
lines = open(path, encoding='utf-8').read().split('\n')
start_idx = -1
end_idx = -1
for i, line in enumerate(lines):
    if 'VStack(spacing: 0) {' in line and start_idx == -1:
        # Check if the next line has PremiumToggleRow
        if 'PremiumToggleRow(name: "AIM BODY 90%' in lines[i+1]:
            start_idx = i
    if '.overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))' in line and start_idx != -1 and end_idx == -1:
        end_idx = i

if start_idx != -1 and end_idx != -1:
    new_ui = """                            Text("AIMS")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)

                            VStack(spacing: 0) {
                                PremiumToggleRow(name: "AIM BODY 90%", pkg: "AIMBODY90.3105", isOn: $aimBody90Enabled, isBusy: patchOperationBusy) { togglePatch(id: "C19CBA7B-C108-4752-9221-4950D1B9E096", name: "AIM BODY 90%", state: $aimBody90Enabled) }
                                Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                PremiumToggleRow(name: "AIMLOCK MODE", pkg: "AIMLOCKMODE.3105", isOn: $aimlockModeEnabled, isBusy: patchOperationBusy) { togglePatch(id: "161B8454-5C89-4BF2-93D9-B60ECDF2E154", name: "AIMLOCK MODE", state: $aimlockModeEnabled) }
                                Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                PremiumToggleRow(name: "AIMNECK", pkg: "AIMNECK.3105", isOn: $aimneckEnabled, isBusy: patchOperationBusy) { togglePatch(id: "306FC9CF-433A-4318-9FF3-26C07BFBD0FA", name: "AIMNECK", state: $aimneckEnabled) }
                            }
                            .background(Color.black.opacity(0.3))
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))

                            Text("SKIN")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                                .padding(.top, 10)

                            VStack(spacing: 0) {
                                PremiumToggleRow(name: "SKIN 1", pkg: "SKIN-1.3105", isOn: $skin1Enabled, isBusy: patchOperationBusy) { togglePatch(id: "47C88561-C524-4164-9ADA-D5F578F4FDC3", name: "SKIN 1", state: $skin1Enabled) }
                            }
                            .background(Color.black.opacity(0.3))
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))

                            Text("CHAMS")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                                .padding(.top, 10)

                            VStack(spacing: 0) {
                                PremiumToggleRow(name: "CHAMS BLUE", pkg: "CHAMS-BLUE.3105", isOn: $chamsBlueEnabled, isBusy: patchOperationBusy) { togglePatch(id: "A677DFE5-1355-4CC8-9137-C54A5E85B882", name: "CHAMS BLUE", state: $chamsBlueEnabled) }
                            }
                            .background(Color.black.opacity(0.3))
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))"""
    
    new_lines = lines[:start_idx] + new_ui.split('\n') + lines[end_idx+1:]
    with open(path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(new_lines))
    print('Updated UI layout')
else:
    print('Could not find target range')
