import sys, re
path = 'ThreeOneOSFive/ContentView.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Replace PremiumToggleRow calls
text = text.replace(
    'PremiumToggleRow(name: "AIM BODY 90%", pkg: "AIMBODY90.3105", isOn: $aimBody90Enabled, isBusy: patchOperationBusy) { togglePatch(pkg: "AIMBODY90.3105", state: $aimBody90Enabled) }',
    'PremiumToggleRow(name: "AIM BODY 90%", pkg: "AIMBODY90.3105", isOn: $aimBody90Enabled, isBusy: patchOperationBusy) { togglePatch(id: "C19CBA7B-C108-4752-9221-4950D1B9E096", name: "AIM BODY 90%", state: $aimBody90Enabled) }'
)
text = text.replace(
    'PremiumToggleRow(name: "AIMLOCK MODE", pkg: "AIMLOCKMODE.3105", isOn: $aimlockModeEnabled, isBusy: patchOperationBusy) { togglePatch(pkg: "AIMLOCKMODE.3105", state: $aimlockModeEnabled) }',
    'PremiumToggleRow(name: "AIMLOCK MODE", pkg: "AIMLOCKMODE.3105", isOn: $aimlockModeEnabled, isBusy: patchOperationBusy) { togglePatch(id: "161B8454-5C89-4BF2-93D9-B60ECDF2E154", name: "AIMLOCK MODE", state: $aimlockModeEnabled) }'
)
text = text.replace(
    'PremiumToggleRow(name: "AIMNECK", pkg: "AIMNECK.3105", isOn: $aimneckEnabled, isBusy: patchOperationBusy) { togglePatch(pkg: "AIMNECK.3105", state: $aimneckEnabled) }',
    'PremiumToggleRow(name: "AIMNECK", pkg: "AIMNECK.3105", isOn: $aimneckEnabled, isBusy: patchOperationBusy) { togglePatch(id: "306FC9CF-433A-4318-9FF3-26C07BFBD0FA", name: "AIMNECK", state: $aimneckEnabled) }'
)

# Replace syncPatchStates
text = text.replace(
    'aimBody90Enabled = isPatchActive("AIMBODY90.3105")',
    'aimBody90Enabled = isPatchActive(id: "C19CBA7B-C108-4752-9221-4950D1B9E096")'
)
text = text.replace(
    'aimlockModeEnabled = isPatchActive("AIMLOCKMODE.3105")',
    'aimlockModeEnabled = isPatchActive(id: "161B8454-5C89-4BF2-93D9-B60ECDF2E154")'
)
text = text.replace(
    'aimneckEnabled = isPatchActive("AIMNECK.3105")',
    'aimneckEnabled = isPatchActive(id: "306FC9CF-433A-4318-9FF3-26C07BFBD0FA")'
)

# Replace isPatchActive signature and logic
old_isPatchActive = '''    private func isPatchActive(_ packageFilename: String) -> Bool {
        patchStore.items.first(where: { $0.packageURL.lastPathComponent.caseInsensitiveCompare(packageFilename) == .orderedSame })
            .flatMap { DevicePatchService.latestReceipt(projectID: $0.id) } != nil
    }'''
new_isPatchActive = '''    private func isPatchActive(id: String) -> Bool {
        patchStore.items.first(where: { $0.id.uuidString.caseInsensitiveCompare(id) == .orderedSame })
            .flatMap { DevicePatchService.latestReceipt(projectID: $0.id) } != nil
    }'''
text = text.replace(old_isPatchActive, new_isPatchActive)

# Replace setPatchState
old_setPatchState = '''    private func setPatchState(for packageFilename: String, enabled: Bool) {
        switch packageFilename {
        case "AIMBODY90.3105": aimBody90Enabled = enabled
        case "AIMLOCKMODE.3105": aimlockModeEnabled = enabled
        case "AIMNECK.3105": aimneckEnabled = enabled
        default: break
        }
    }'''
new_setPatchState = '''    private func setPatchState(for id: String, enabled: Bool) {
        switch id.uppercased() {
        case "C19CBA7B-C108-4752-9221-4950D1B9E096": aimBody90Enabled = enabled
        case "161B8454-5C89-4BF2-93D9-B60ECDF2E154": aimlockModeEnabled = enabled
        case "306FC9CF-433A-4318-9FF3-26C07BFBD0FA": aimneckEnabled = enabled
        default: break
        }
    }'''
text = text.replace(old_setPatchState, new_setPatchState)

# Replace togglePatch signature and logic
old_togglePatch = '''    private func togglePatch(pkg: String, state: Binding<Bool>) {
        guard !patchOperationBusy else { return }
        guard let item = patchStore.items.first(where: { $0.packageURL.lastPathComponent.caseInsensitiveCompare(pkg) == .orderedSame }) else {
            patchMessage = "Error: Module not found"
            log("patch: package not found: \\(pkg)")
            return
        }

        let wasEnabled = state.wrappedValue
        patchOperationBusy = true
        patchMessage = "Injecting \\(pkg.replacingOccurrences(of: ".3105", with: ""))..."'''
new_togglePatch = '''    private func togglePatch(id: String, name: String, state: Binding<Bool>) {
        guard !patchOperationBusy else { return }
        guard let item = patchStore.items.first(where: { $0.id.uuidString.caseInsensitiveCompare(id) == .orderedSame }) else {
            patchMessage = "Error: Module not found"
            log("patch: package not found: \\(name)")
            return
        }

        let wasEnabled = state.wrappedValue
        patchOperationBusy = true
        patchMessage = "Injecting \\(name)..."'''
text = text.replace(old_togglePatch, new_togglePatch)

# Inside togglePatch catch blocks
text = text.replace('self.setPatchState(for: pkg, enabled: false)', 'self.setPatchState(for: id, enabled: false)')
text = text.replace('self.setPatchState(for: pkg, enabled: true)', 'self.setPatchState(for: id, enabled: true)')

# Finally add the logout button as requested: "thêm nút đăng xuất đổi key"
old_header = '''                HStack {
                    VStack(alignment: .leading) {
                        Text("DNXTWEAKS")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.white, Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        Text(patchMessage)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(patchOperationBusy ? .yellow : .gray)
                            .lineLimit(1)
                            .animation(.easeInOut, value: patchMessage)
                    }
                    Spacer()
                    if patchOperationBusy {
                        ProgressView().tint(.purple)
                            .padding(.trailing, 10)
                    }
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }
                }'''
new_header = '''                HStack {
                    VStack(alignment: .leading) {
                        Text("DNXTWEAKS")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.white, Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        Text(patchMessage)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(patchOperationBusy ? .yellow : .gray)
                            .lineLimit(1)
                            .animation(.easeInOut, value: patchMessage)
                    }
                    Spacer()
                    if patchOperationBusy {
                        ProgressView().tint(.purple)
                            .padding(.trailing, 10)
                    }
                    Button(action: {
                        licenseManager.deactivate()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }
                }'''
text = text.replace(old_header, new_header)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print('Patched UUID matching and logout button successfully!')
