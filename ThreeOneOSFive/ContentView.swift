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
    
    @State private var currentTab = 0

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
                    
                    // TAB 1: MODULES
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Active Modules")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            
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
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                    }
                    .tabItem {
                        Image(systemName: "switch.2")
                        Text("Modules")
                    }
                    .tag(1)
                }
            }
        }
        .preferredColorScheme(.dark)
        .tint(.purple)
        .sheet(isPresented: $showSettings) { SettingsView() }
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
        default: break
        }
    }

    private enum PatchActionResult {
        case applied, restored, unavailable(String)
    }

    private func togglePatch(id: String, name: String, state: Binding<Bool>) {
        guard !patchOperationBusy else { return }
        guard let item = patchStore.items.first(where: { $0.id.uuidString.caseInsensitiveCompare(id) == .orderedSame }) else {
            patchMessage = "Error: Module not found"
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
                switch result {
                case .applied:
                    self.setPatchState(for: id, enabled: true)
                    self.patchMessage = "Module Injected!"
                    PatchAudioFeedback.bypassActivated()
                case .restored:
                    self.setPatchState(for: id, enabled: false)
                    self.patchMessage = "Module Restored!"
                    PatchAudioFeedback.originalRestored()
                case .unavailable(let message):
                    self.patchMessage = message
                }
                self.patchOperationBusy = false
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
                    Text("Enter key to decrypt and inject module.")
                }
            }
            .navigationTitle("Unlock Module")
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
