import AVKit
import SwiftUI
import UIKit
import AVFoundation

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var licenseManager: LicenseManager
    @State private var showSettings = false
    @State private var showCleaner = false
    @StateObject private var patchStore = PatchProjectStore()
    @State private var patchOperationBusy = false
    @State private var patchMessage = "Ready to inject"
    
    @State private var aimBody90Enabled = false
    @State private var aimlockModeEnabled = false
    @State private var aimneckEnabled = false
    @State private var aimDragEnabled = false
    @State private var aimHeadEnabled = false
    @State private var aimMalformationEnabled = false
    @State private var aimNeckAntenaEnabled = false
    @State private var aimBodyLobbyEnabled = false
    @State private var aimChestLobbyEnabled = false
    @State private var aimDragLobbyEnabled = false
    @State private var aimNeckLobbyEnabled = false
    @State private var magicBulletLobbyEnabled = false
    @State private var skin1Enabled = false
    @State private var chamsBlueEnabled = false
    
    @State private var currentTab = 0
    @State private var selectedScriptCategory = 0

    var body: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 0) {
                // Header
                HStack {
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
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                TabView(selection: $currentTab) {
                    // TAB 0: DASHBOARD
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            StatusCard(appState: appState)
                            KeyStatusCard(remainingSeconds: licenseManager.remainingSeconds)
                            VideoCard()
                            DNSCard()
                            CommunityCard()
                            LaunchCard(showCleaner: $showCleaner, onLaunch: openGame)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                    
                    // TAB 1: SCRIPTS
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Active Scripts")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            
                            Picker("Category", selection: $selectedScriptCategory) {
                                Text("Aim").tag(0)
                                Text("Skin").tag(1)
                                Text("Chams").tag(2)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom, 8)

                            if selectedScriptCategory == 0 {
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
                                    PremiumToggleRow(name: "AIM BODY (Bat Sanh)", pkg: "Bat Sanh", isOn: $aimBodyLobbyEnabled, isBusy: patchOperationBusy) { togglePatch(id: "3BD95FBE-B0C3-40B7-88C0-AEB2A9B9D8C8", name: "AIM BODY (Bat Sanh)", state: $aimBodyLobbyEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM CHEST (Bat Sanh)", pkg: "Bat Sanh", isOn: $aimChestLobbyEnabled, isBusy: patchOperationBusy) { togglePatch(id: "5AA0E78E-7AAF-4980-AD85-4780B3C079AE", name: "AIM CHEST (Bat Sanh)", state: $aimChestLobbyEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM DRAG (Bat Sanh)", pkg: "Bat Sanh", isOn: $aimDragLobbyEnabled, isBusy: patchOperationBusy) { togglePatch(id: "97D18C40-6BFB-421B-A434-B3A5E3E83A17", name: "AIM DRAG (Bat Sanh)", state: $aimDragLobbyEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "AIM NECK (Bat Sanh)", pkg: "Bat Sanh", isOn: $aimNeckLobbyEnabled, isBusy: patchOperationBusy) { togglePatch(id: "1AE45A6B-4861-48B2-9647-2B2D5713A9C3", name: "AIM NECK (Bat Sanh)", state: $aimNeckLobbyEnabled) }
                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)
                                    PremiumToggleRow(name: "MAGIC BULLET (Bat Sanh)", pkg: "Bat Sanh", isOn: $magicBulletLobbyEnabled, isBusy: patchOperationBusy) { togglePatch(id: "47AE459A-0707-4A7F-A831-96CE1381859C", name: "MAGIC BULLET (Bat Sanh)", state: $magicBulletLobbyEnabled) }
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
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                    }
                    .tabItem {
                        Image(systemName: "switch.2")
                        Text("Scripts")
                    }
                    .tag(1)
                }
            }
        }
        .preferredColorScheme(.dark)
        .tint(.purple)
        .sheet(isPresented: $showSettings) { SettingsView() }
        .alert(isPresented: $notificationManager.showNotification) {
            Alert(
                title: Text(notificationManager.notificationTitle),
                message: Text(notificationManager.notificationMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            notificationManager.fetchNotification()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            notificationManager.fetchNotification()
        }
        .sheet(isPresented: $showCleaner) { CleanerView() }
        .sheet(item: $patchStore.passwordRequest, onDismiss: patchStore.cancelUnlock) { _ in PatchUnlockPrompt(store: patchStore) }
        .onAppear { syncPatchStates() }
        .onChange(of: scenePhase) { phase in
            guard phase == .active, !patchOperationBusy else { return }
            syncPatchStates()
            patchMessage = "Ready"
        }
    }

    private func syncPatchStates() {
        aimBody90Enabled = isPatchActive(id: "C19CBA7B-C108-4752-9221-4950D1B9E096")
        aimlockModeEnabled = isPatchActive(id: "161B8454-5C89-4BF2-93D9-B60ECDF2E154")
        aimneckEnabled = isPatchActive(id: "306FC9CF-433A-4318-9FF3-26C07BFBD0FA")
        aimDragEnabled = isPatchActive(id: "E6C8911E-AC7F-4078-ABBC-EE57E1F97F3F")
        aimHeadEnabled = isPatchActive(id: "C3770F2A-A799-458F-9AEE-412B31B1CA4A")
        aimMalformationEnabled = isPatchActive(id: "92A3B41B-5B86-45BC-A840-482BAF4BE7E2")
        aimNeckAntenaEnabled = isPatchActive(id: "497EDBD6-FA5C-4015-88CD-6C3DFE4C827F")
        aimBodyLobbyEnabled = isPatchActive(id: "3BD95FBE-B0C3-40B7-88C0-AEB2A9B9D8C8")
        aimChestLobbyEnabled = isPatchActive(id: "5AA0E78E-7AAF-4980-AD85-4780B3C079AE")
        aimDragLobbyEnabled = isPatchActive(id: "97D18C40-6BFB-421B-A434-B3A5E3E83A17")
        aimNeckLobbyEnabled = isPatchActive(id: "1AE45A6B-4861-48B2-9647-2B2D5713A9C3")
        magicBulletLobbyEnabled = isPatchActive(id: "47AE459A-0707-4A7F-A831-96CE1381859C")
        skin1Enabled = isPatchActive(id: "47C88561-C524-4164-9ADA-D5F578F4FDC3")
        chamsBlueEnabled = isPatchActive(id: "A677DFE5-1355-4CC8-9137-C54A5E85B882")
    }

    private func isPatchActive(id: String) -> Bool {
        patchStore.items.first(where: { $0.id.uuidString.caseInsensitiveCompare(id) == .orderedSame })
            .flatMap { DevicePatchService.latestReceipt(projectID: $0.id) } != nil
    }

    private func setPatchState(for id: String, enabled: Bool) {
        switch id.uppercased() {
        case "C19CBA7B-C108-4752-9221-4950D1B9E096": aimBody90Enabled = enabled
        case "161B8454-5C89-4BF2-93D9-B60ECDF2E154": aimlockModeEnabled = enabled
        case "306FC9CF-433A-4318-9FF3-26C07BFBD0FA": aimneckEnabled = enabled
        case "E6C8911E-AC7F-4078-ABBC-EE57E1F97F3F": aimDragEnabled = enabled
        case "C3770F2A-A799-458F-9AEE-412B31B1CA4A": aimHeadEnabled = enabled
        case "92A3B41B-5B86-45BC-A840-482BAF4BE7E2": aimMalformationEnabled = enabled
        case "497EDBD6-FA5C-4015-88CD-6C3DFE4C827F": aimNeckAntenaEnabled = enabled
        case "3BD95FBE-B0C3-40B7-88C0-AEB2A9B9D8C8": aimBodyLobbyEnabled = enabled
        case "5AA0E78E-7AAF-4980-AD85-4780B3C079AE": aimChestLobbyEnabled = enabled
        case "97D18C40-6BFB-421B-A434-B3A5E3E83A17": aimDragLobbyEnabled = enabled
        case "1AE45A6B-4861-48B2-9647-2B2D5713A9C3": aimNeckLobbyEnabled = enabled
        case "47AE459A-0707-4A7F-A831-96CE1381859C": magicBulletLobbyEnabled = enabled
        case "47C88561-C524-4164-9ADA-D5F578F4FDC3": skin1Enabled = enabled
        case "A677DFE5-1355-4CC8-9137-C54A5E85B882": chamsBlueEnabled = enabled
        default: break
        }
    }

    private enum PatchActionResult {
        case applied, restored, unavailable(String)
    }

    private func togglePatch(id: String, name: String, state: Binding<Bool>) {
        guard !patchOperationBusy else { return }
        guard let item = patchStore.items.first(where: { $0.id.uuidString.caseInsensitiveCompare(id) == .orderedSame }) else {
            patchMessage = "Error: Script not found"
            log("patch: package not found: \(name)")
            return
        }

        let wasEnabled = state.wrappedValue
        patchOperationBusy = true
        patchMessage = "Injecting \(name)..."
        let project = item.project
        let projectID = item.id

        DispatchQueue.global(qos: .userInitiated).async {
            let result: PatchActionResult
            do {
                if wasEnabled {
                    guard let receipt = DevicePatchService.latestReceipt(projectID: projectID) else {
                        result = .unavailable("No active receipt")
                        DispatchQueue.main.async {
                            self.setPatchState(for: id, enabled: false)
                            self.patchMessage = "Restored"
                            self.patchOperationBusy = false
                        }
                        return
                    }
                    try DevicePatchService.restore(receipt: receipt)
                    result = .restored
                } else {
                    guard let project else {
                        result = .unavailable("Unlock Required")
                        DispatchQueue.main.async {
                            self.patchStore.requestUnlock(for: item)
                            self.patchMessage = "Enter Decryption Key"
                            self.patchOperationBusy = false
                        }
                        return
                    }
                    _ = try DevicePatchService.apply(project: project)
                    result = .applied
                }
            } catch {
                result = .unavailable("Error: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                DispatchQueue.main.async {
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
                }
            }
        }
    }

    private func openGame(scheme: String) {
        guard let url = URL(string: "\(scheme)://") else { return }
        UIApplication.shared.open(url, options: [:]) { success in log("launch: \(scheme) success=\(success)") }
    }
}

// MARK: - Beautiful UI Components

struct StatusCard: View {
    @ObservedObject var appState: AppState
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "iphone.gen3")
                    .font(.system(size: 22))
                    .foregroundColor(.purple)
                Text("Device Identity")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 14) {
                InfoRow(title: "OS Version", value: AppInfo.osVersion)
                InfoRow(title: "Hardware", value: AppInfo.displayMachineName)
                HStack {
                    Text("Kernel Support")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(appState.isSupported ? "Supported" : "Unsupported")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(appState.isSupported ? .green : .red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(appState.isSupported ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(24)
        .background(Color.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

struct LaunchCard: View {
    @Binding var showCleaner: Bool
    var onLaunch: (String) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.purple)
                Text("Quick Launch")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            Button(action: { onLaunch("freefireth") }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    Text("Launch Free Fire Normal")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding()
                .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .purple.opacity(0.3), radius: 8, y: 4)
            }
            
            Button(action: { showCleaner = true }) {
                HStack {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                    Text("Clean Cache & Logs")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
        }
        .padding(24)
        .background(Color.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
    }
}

struct PremiumToggleRow: View {
    let name: String
    let pkg: String
    @Binding var isOn: Bool
    let isBusy: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isOn ? Color.purple.opacity(0.2) : Color.white.opacity(0.08))
                    .frame(width: 36, height: 36)
                Image(systemName: isOn ? "checkmark.seal.fill" : "puzzlepiece.fill")
                    .foregroundColor(isOn ? .purple : .gray)
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(isOn ? .white : .gray.opacity(0.9))
                Text(pkg.replacingOccurrences(of: ".3105", with: ""))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { _ in action() }
            ))
            .labelsHidden()
            .tint(.purple)
            .disabled(isBusy)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isBusy { action() }
        }
        .opacity(isBusy ? 0.6 : 1.0)
    }
}

// MARK: - Handlers

private enum PatchAudioFeedback {
    static func bypassActivated() { AudioServicesPlaySystemSound(1057) }
    static func originalRestored() { AudioServicesPlaySystemSound(1057) }
}

private struct PatchUnlockPrompt: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: PatchProjectStore
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Decryption Key", text: $password)
                        .textContentType(.password)
                        .submitLabel(.done)
                        .onSubmit(unlock)
                        .onChange(of: password) { _ in store.clearUnlockError() }
                    if let errorKey = store.unlockErrorKey {
                        Text(AppLanguage.english.text(errorKey))
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                } footer: {
                    Text("Enter key to decrypt and inject script.")
                }
            }
            .navigationTitle("Unlock Script")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Unlock", action: unlock)
                        .disabled(password.isEmpty || store.isBusy)
                }
            }
        }
    }
    private func unlock() {
        guard !password.isEmpty else { return }
        store.unlock(password: password)
    }
}

struct PremiumBackground: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08).ignoresSafeArea()
            
            Circle()
                .fill(Color.purple.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: animate ? 100 : -100, y: animate ? -100 : 100)
            
            Circle()
                .fill(Color.indigo.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: animate ? -100 : 100, y: animate ? 100 : -100)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

struct AnimatedHyperBackdrop: View {
    @State private var animate = false
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.ignoresSafeArea()
                Circle()
                    .fill(Color.cyan.opacity(0.12))
                    .frame(width: 280, height: 280)
                    .blur(radius: 70)
                    .offset(x: animate ? 120 : -120, y: -proxy.size.height * 0.23)
                Circle()
                    .fill(Color.purple.opacity(0.08))
                    .frame(width: 260, height: 260)
                    .blur(radius: 80)
                    .offset(x: animate ? -100 : 100, y: proxy.size.height * 0.22)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) { animate = true }
            }
        }
        .ignoresSafeArea()
    }
}

struct KeyStatusCard: View {
    let remainingSeconds: Int
    var body: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(.purple)
            Text("License Time Remaining:")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            Text(formattedTime)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(remainingSeconds < 3600 ? .red : .green)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
    }
    
    var formattedTime: String {
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

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

struct CommunityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Community & Support")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Link(destination: URL(string: "https://zalo.me/g/miuatq2xhhh0tarsc3me")!) {
                HStack {
                    Image(systemName: "bell.badge.fill")
                    Text("Cong dong thong bao cap nhat")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            Link(destination: URL(string: "http://zalo.me/0395109314")!) {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Zalo Admin")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.purple)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
    }
}
