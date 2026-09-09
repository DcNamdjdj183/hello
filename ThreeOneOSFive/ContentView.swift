import SwiftUI
import UIKit
import AVFoundation

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState
    @State private var showSettings = false
    @State private var showCleaner = false
    @StateObject private var patchStore = PatchProjectStore()
    @State private var patchOperationBusy = false
    @State private var patchMessage = "SYSTEM ONLINE // AWAITING COMMAND"
    
    @State private var aimDragEnabled = false
    @State private var aimNeckEnabled = false
    @State private var hspeitoffEnabled = false
    @State private var hyperBalamagicaEnabled = false
    @State private var aimBodyPackageEnabled = false
    @State private var aimChestPackageEnabled = false
    @State private var magicEnabled = false
    
    @State private var currentTab = 0

    var body: some View {
        ZStack {
            CyberGridBackground()
            
            VStack(spacing: 0) {
                CyberTopBar(showSettings: $showSettings)
                
                TabView(selection: $currentTab) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            SystemStatusPanel(appState: appState)
                            LaunchTerminalPanel(showCleaner: $showCleaner, onLaunch: openGame)
                        }
                        .padding(20)
                        .padding(.bottom, 80)
                    }
                    .tag(0)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            HStack {
                                Text("OVERRIDE MODULES")
                                    .font(.custom("CourierNewPS-BoldMT", size: 18))
                                    .foregroundColor(.cyan)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                CyberPatchRow(name: "AIM DRAG", pkg: "OGIOS File (6).3105", isOn: $aimDragEnabled, isBusy: patchOperationBusy) { togglePatch(pkg: "OGIOS File (6).3105", state: $aimDragEnabled) }
                                CyberPatchRow(name: "AIM NECK", pkg: "OGIOS File (7).3105", isOn: $aimNeckEnabled, isBusy: patchOperationBusy) { togglePatch(pkg: "OGIOS File (7).3105", state: $aimNeckEnabled) }
                                CyberPatchRow(name: "ANTENNA", pkg: "OGIOS File (8).3105", isOn: $hspeitoffEnabled, isBusy: patchOperationBusy) { togglePatch(pkg: "OGIOS File (8).3105", state: $hspeitoffEnabled) }
                                CyberPatchRow(name: "144 FPS", pkg: "OGIOS File (10).3105", isOn: $hyperBalamagicaEnabled, isBusy: patchOperationBusy) { togglePatch(pkg: "OGIOS File (10).3105", state: $hyperBalamagicaEnabled) }
                                CyberPatchRow(name: "AIM BODY", pkg: "OGIOS File (12).3105", isOn: $aimBodyPackageEnabled, isBusy: patchOperationBusy) { togglePatch(pkg: "OGIOS File (12).3105", state: $aimBodyPackageEnabled) }
                                CyberPatchRow(name: "AIM CHEST", pkg: "OGIOS File (2).3105", isOn: $aimChestPackageEnabled, isBusy: patchOperationBusy) { togglePatch(pkg: "OGIOS File (2).3105", state: $aimChestPackageEnabled) }
                                CyberPatchRow(name: "MAGIC", pkg: "OGIOS File (14).3105", isOn: $magicEnabled, isBusy: patchOperationBusy) { togglePatch(pkg: "OGIOS File (14).3105", state: $magicEnabled) }
                            }
                        }
                        .padding(20)
                        .padding(.bottom, 80)
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            VStack {
                Spacer()
                CyberBottomBar(currentTab: $currentTab, message: patchMessage, isBusy: patchOperationBusy)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showCleaner) { CleanerView() }
        .sheet(item: $patchStore.passwordRequest, onDismiss: patchStore.cancelUnlock) { _ in
            PatchUnlockPrompt(store: patchStore)
        }
        .onAppear { syncPatchStates() }
        .onChange(of: scenePhase) { phase in
            guard phase == .active, !patchOperationBusy else { return }
            syncPatchStates()
            patchMessage = "SYSTEM ONLINE // AWAITING COMMAND"
        }
    }

    private func syncPatchStates() {
        aimDragEnabled = isPatchActive("OGIOS File (6).3105")
        aimNeckEnabled = isPatchActive("OGIOS File (7).3105")
        hspeitoffEnabled = isPatchActive("OGIOS File (8).3105")
        hyperBalamagicaEnabled = isPatchActive("OGIOS File (10).3105")
        aimBodyPackageEnabled = isPatchActive("OGIOS File (12).3105")
        aimChestPackageEnabled = isPatchActive("OGIOS File (2).3105")
        magicEnabled = isPatchActive("OGIOS File (14).3105")
    }

    private func isPatchActive(_ packageFilename: String) -> Bool {
        patchStore.items.first(where: { $0.packageURL.lastPathComponent.caseInsensitiveCompare(packageFilename) == .orderedSame })
            .flatMap { DevicePatchService.latestReceipt(projectID: $0.id) } != nil
    }

    private func setPatchState(for packageFilename: String, enabled: Bool) {
        switch packageFilename {
        case "OGIOS File (6).3105": aimDragEnabled = enabled
        case "OGIOS File (7).3105": aimNeckEnabled = enabled
        case "OGIOS File (8).3105": hspeitoffEnabled = enabled
        case "OGIOS File (10).3105": hyperBalamagicaEnabled = enabled
        case "OGIOS File (12).3105": aimBodyPackageEnabled = enabled
        case "OGIOS File (2).3105": aimChestPackageEnabled = enabled
        case "OGIOS File (14).3105": magicEnabled = enabled
        default: break
        }
    }

    private enum PatchActionResult {
        case applied, restored, unavailable(String)
    }

    private func togglePatch(pkg: String, state: Binding<Bool>) {
        guard !patchOperationBusy else { return }
        guard let item = patchStore.items.first(where: { $0.packageURL.lastPathComponent.caseInsensitiveCompare(pkg) == .orderedSame }) else {
            patchMessage = "ERROR // PKG_NOT_FOUND"
            log("patch: package not found: \(pkg)")
            return
        }

        let wasEnabled = state.wrappedValue
        patchOperationBusy = true
        patchMessage = "INJECTING // \(pkg)"
        let project = item.project
        let projectID = item.id

        DispatchQueue.global(qos: .userInitiated).async {
            let result: PatchActionResult
            do {
                if wasEnabled {
                    guard let receipt = DevicePatchService.latestReceipt(projectID: projectID) else {
                        result = .unavailable("ERR // NO_ACTIVE_RECEIPT")
                        DispatchQueue.main.async {
                            self.setPatchState(for: pkg, enabled: false)
                            self.patchMessage = "RESTORED // NO ACTIVE PATCH"
                            self.patchOperationBusy = false
                        }
                        return
                    }
                    try DevicePatchService.restore(receipt: receipt)
                    result = .restored
                } else {
                    guard let project else {
                        result = .unavailable("ERR // UNLOCK_REQUIRED")
                        DispatchQueue.main.async {
                            self.patchStore.requestUnlock(for: item)
                            self.patchMessage = "AUTH REQ // ENTER PKG PIN"
                            self.patchOperationBusy = false
                        }
                        return
                    }
                    _ = try DevicePatchService.apply(project: project)
                    result = .applied
                }
            } catch {
                result = .unavailable("ERR // EXCEPTION: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                switch result {
                case .applied:
                    self.setPatchState(for: pkg, enabled: true)
                    self.patchMessage = "SUCCESS // \(pkg) INJECTED"
                    PatchAudioFeedback.bypassActivated()
                case .restored:
                    self.setPatchState(for: pkg, enabled: false)
                    self.patchMessage = "SUCCESS // \(pkg) RESTORED"
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

// MARK: - UI Components

struct CyberTopBar: View {
    @Binding var showSettings: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: -2) {
                Text("O.G.I.O.S")
                    .font(.custom("CourierNewPS-BoldMT", size: 28))
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan, radius: 5)
                Text("QUANTUM INTERFACE V3")
                    .font(.custom("Courier", size: 10))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: { showSettings = true }) {
                Image(systemName: "hexagon.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.cyan)
                    .overlay(Image(systemName: "slider.horizontal.3").foregroundColor(.black).font(.system(size: 14, weight: .bold)))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(Color.black.opacity(0.8))
        .overlay(Rectangle().frame(height: 1).foregroundColor(.cyan), alignment: .bottom)
    }
}

struct SystemStatusPanel: View {
    @ObservedObject var appState: AppState
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "cpu")
                    .foregroundColor(.cyan)
                Text("SYSTEM DIAGNOSTICS")
                    .font(.custom("CourierNewPS-BoldMT", size: 14))
                    .foregroundColor(.cyan)
            }
            
            Divider().background(Color.cyan.opacity(0.5))
            
            HStack {
                Text("OS VERSION")
                    .font(.custom("Courier", size: 12))
                    .foregroundColor(.gray)
                Spacer()
                Text(AppInfo.osVersion)
                    .font(.custom("CourierNewPS-BoldMT", size: 14))
                    .foregroundColor(.white)
            }
            
            HStack {
                Text("HARDWARE")
                    .font(.custom("Courier", size: 12))
                    .foregroundColor(.gray)
                Spacer()
                Text(AppInfo.displayMachineName)
                    .font(.custom("CourierNewPS-BoldMT", size: 14))
                    .foregroundColor(.white)
            }
            
            HStack {
                Text("KERNEL STATUS")
                    .font(.custom("Courier", size: 12))
                    .foregroundColor(.gray)
                Spacer()
                Text(appState.isSupported ? "SECURE / COMPATIBLE" : "UNSUPPORTED")
                    .font(.custom("CourierNewPS-BoldMT", size: 14))
                    .foregroundColor(appState.isSupported ? .green : .red)
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.6))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.cyan, lineWidth: 1))
    }
}

struct LaunchTerminalPanel: View {
    @Binding var showCleaner: Bool
    var onLaunch: (String) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "terminal")
                    .foregroundColor(.cyan)
                Text("EXECUTION TERMINAL")
                    .font(.custom("CourierNewPS-BoldMT", size: 14))
                    .foregroundColor(.cyan)
            }
            
            Divider().background(Color.cyan.opacity(0.5))
            
            Button(action: { onLaunch("freefireth") }) {
                HStack {
                    Text("> EXECUTE: FREE FIRE NORMAL")
                        .font(.custom("CourierNewPS-BoldMT", size: 14))
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "play.fill").foregroundColor(.black)
                }
                .padding()
                .background(Color.cyan)
                .cornerRadius(4)
            }
            
            Button(action: { showCleaner = true }) {
                HStack {
                    Text("> RUN: CACHE_CLEANER.EXE")
                        .font(.custom("CourierNewPS-BoldMT", size: 14))
                        .foregroundColor(.cyan)
                    Spacer()
                    Image(systemName: "trash").foregroundColor(.cyan)
                }
                .padding()
                .background(Color.clear)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.cyan, lineWidth: 1))
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.6))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.cyan, lineWidth: 1))
    }
}

struct CyberPatchRow: View {
    let name: String
    let pkg: String
    @Binding var isOn: Bool
    let isBusy: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Status Box
                ZStack {
                    Rectangle()
                        .fill(isOn ? Color.cyan.opacity(0.2) : Color.black)
                        .frame(width: 40, height: 40)
                        .border(isOn ? Color.cyan : Color.gray, width: 1)
                    
                    if isOn {
                        Image(systemName: "checkmark")
                            .foregroundColor(.cyan)
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.custom("CourierNewPS-BoldMT", size: 16))
                        .foregroundColor(isOn ? .cyan : .white)
                    Text("PKG: \(pkg)")
                        .font(.custom("Courier", size: 10))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(isOn ? "[ ACTIVE ]" : "[ OFFLINE ]")
                    .font(.custom("Courier", size: 12))
                    .foregroundColor(isOn ? .cyan : .gray)
            }
            .padding(12)
            .background(Color.black.opacity(0.5))
            .border(isOn ? Color.cyan.opacity(0.5) : Color.gray.opacity(0.3), width: 1)
        }
        .disabled(isBusy)
        .opacity(isBusy ? 0.5 : 1.0)
    }
}

struct CyberBottomBar: View {
    @Binding var currentTab: Int
    let message: String
    let isBusy: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Status Ticker
            HStack {
                Text(message)
                    .font(.custom("Courier", size: 11))
                    .foregroundColor(isBusy ? .yellow : .cyan)
                    .lineLimit(1)
                Spacer()
                if isBusy {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        .scaleEffect(0.7)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(Color.black)
            .border(Color.cyan.opacity(0.5), width: 1)
            
            // Tabs
            HStack(spacing: 0) {
                CyberTabButton(title: "DASHBOARD", icon: "square.grid.2x2", isSelected: currentTab == 0) { currentTab = 0 }
                CyberTabButton(title: "MODULES", icon: "cpu", isSelected: currentTab == 1) { currentTab = 1 }
            }
            .background(Color.black.opacity(0.95))
        }
    }
}

struct CyberTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.custom("CourierNewPS-BoldMT", size: 10))
            }
            .foregroundColor(isSelected ? .cyan : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.cyan.opacity(0.1) : Color.clear)
            .overlay(Rectangle().frame(height: 2).foregroundColor(isSelected ? .cyan : .clear), alignment: .top)
        }
    }
}

// MARK: - Handlers

private enum PatchAudioFeedback {
    private static let synthesizer = AVSpeechSynthesizer()
    static func bypassActivated() { speak("Module Injected") }
    static func originalRestored() { speak("Module Offline") }
    private static func speak(_ message: String) {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true, options: [])
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: message)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.90
        synthesizer.speak(utterance)
    }
}

private struct PatchUnlockPrompt: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: PatchProjectStore
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("PKG DECRYPTION KEY", text: $password)
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
            .navigationTitle("DECRYPT MODULE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("CANCEL") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("DECRYPT", action: unlock)
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

struct CyberGridBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08).ignoresSafeArea()
            GeometryReader { proxy in
                Canvas { context, size in
                    var path = Path()
                    let spacing: CGFloat = 30
                    for x in stride(from: CGFloat(0), through: size.width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    for y in stride(from: CGFloat(0), through: size.height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(Color.cyan.opacity(0.08)), lineWidth: 1)
                }
            }
        }
        .ignoresSafeArea()
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
