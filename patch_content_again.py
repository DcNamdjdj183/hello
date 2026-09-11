import sys

path = 'ThreeOneOSFive/ContentView.swift'
lines = open(path, encoding='utf-8').read().split('\n')

# 1. Add AVKit import
if not any('import AVKit' in line for line in lines):
    lines.insert(0, 'import AVKit')

text = '\n'.join(lines)

# 2. Add state variable
if '@State private var selectedScriptCategory = 0' not in text:
    text = text.replace('@State private var currentTab = 0', '@State private var currentTab = 0\n    @State private var selectedScriptCategory = 0')

# 3. Add VideoCard and DNSCard to Home Tab
old_home_tab = """                            StatusCard(appState: appState)
                            KeyStatusCard(remainingSeconds: licenseManager.remainingSeconds)
                            LaunchCard(showCleaner: $showCleaner, onLaunch: openGame)"""
new_home_tab = """                            StatusCard(appState: appState)
                            KeyStatusCard(remainingSeconds: licenseManager.remainingSeconds)
                            VideoCard()
                            DNSCard()
                            LaunchCard(showCleaner: $showCleaner, onLaunch: openGame)"""
text = text.replace(old_home_tab, new_home_tab)

# 4. Replace Modules tab UI
old_modules_ui = """                            Text("AIMS")
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
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)

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
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)

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
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)"""

new_modules_ui = """                            Picker("Category", selection: $selectedScriptCategory) {
                                Text("Aim").tag(0)
                                Text("Skin").tag(1)
                                Text("Chams").tag(2)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom, 8)

                            if selectedScriptCategory == 0 {
                                VStack(spacing: 0) {
                                    PremiumToggleRow(name: "AIM BODY 90%", pkg: "AIMBODY90.3105", isOn: $aimBody90Enabled, isBusy: patchOperationBusy) { togglePatch(id: "C19CBA7B-C108-4752-9221-4950D1B9E096", name: "AIM BODY 90%", state: $aimBody90Enabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIMLOCK MODE", pkg: "AIMLOCKMODE.3105", isOn: $aimlockModeEnabled, isBusy: patchOperationBusy) { togglePatch(id: "161B8454-5C89-4BF2-93D9-B60ECDF2E154", name: "AIMLOCK MODE", state: $aimlockModeEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIMNECK", pkg: "AIMNECK.3105", isOn: $aimneckEnabled, isBusy: patchOperationBusy) { togglePatch(id: "306FC9CF-433A-4318-9FF3-26C07BFBD0FA", name: "AIMNECK", state: $aimneckEnabled) }
                                }
                                .background(Color.black.opacity(0.3))
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
                            } else if selectedScriptCategory == 1 {
                                VStack(spacing: 0) {
                                    PremiumToggleRow(name: "SKIN 1", pkg: "SKIN-1.3105", isOn: $skin1Enabled, isBusy: patchOperationBusy) { togglePatch(id: "47C88561-C524-4164-9ADA-D5F578F4FDC3", name: "SKIN 1", state: $skin1Enabled) }
                                }
                                .background(Color.black.opacity(0.3))
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
                            } else if selectedScriptCategory == 2 {
                                VStack(spacing: 0) {
                                    PremiumToggleRow(name: "CHAMS BLUE", pkg: "CHAMS-BLUE.3105", isOn: $chamsBlueEnabled, isBusy: patchOperationBusy) { togglePatch(id: "A677DFE5-1355-4CC8-9137-C54A5E85B882", name: "CHAMS BLUE", state: $chamsBlueEnabled) }
                                }
                                .background(Color.black.opacity(0.3))
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
                            }"""
text = text.replace(old_modules_ui, new_modules_ui)

# 5. Rename Module to Script
text = text.replace('Active Modules', 'Active Scripts')
text = text.replace('Text("Modules")', 'Text("Scripts")')
text = text.replace('Error: Module not found', 'Error: Script not found')
text = text.replace('Module Injected!', 'Script Injected!')
text = text.replace('Module Restored!', 'Script Restored!')
text = text.replace('Unlock Module', 'Unlock Script')
text = text.replace('inject module', 'inject script')
text = text.replace('TAB 1: MODULES', 'TAB 1: SCRIPTS')

# 6. Append VideoCard and DNSCard
components = """
struct VideoCard: View {
    @State private var player: AVPlayer?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tutorial Video")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 200)
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(Text("No video found").foregroundColor(.gray))
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
        .onAppear {
            if let url = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: "video")?.first ?? Bundle.main.urls(forResourcesWithExtension: "mov", subdirectory: "video")?.first {
                player = AVPlayer(url: url)
            }
        }
    }
}

struct DNSCard: View {
    @State private var dnsURL: URL?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DNS Profile")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Button(action: {
                if let url = dnsURL {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "network")
                    Text("Install DNS Profile")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(dnsURL == nil)
            .opacity(dnsURL == nil ? 0.5 : 1)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
        .onAppear {
            dnsURL = Bundle.main.urls(forResourcesWithExtension: "mobileconfig", subdirectory: "dns")?.first
        }
    }
}
"""

if 'struct VideoCard' not in text:
    text += components

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print('Updated ContentView.swift')
