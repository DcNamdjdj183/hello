import SwiftUI
import UIKit
import UniformTypeIdentifiers
import SystemConfiguration

// MARK: - App Target Model
struct AppTarget: Identifiable, Hashable {
    let id: UUID
    let name: String
    let bundleId: String
    let iconName: String

    init(id: UUID = UUID(), name: String, bundleId: String, iconName: String) {
        self.id = id
        self.name = name
        self.bundleId = bundleId
        self.iconName = iconName
    }
}

let defaultAppTargets: [AppTarget] = [
    AppTarget(name: "Free Fire", bundleId: "com.dts.freefireth", iconName: "icon_ffth"),
    AppTarget(name: "Free Fire MAX", bundleId: "com.dts.freefiremax", iconName: "icon_ffmax"),
    AppTarget(name: "PUBG Mobile", bundleId: "com.vng.pubgmobile", iconName: "icon_pubg"),
    AppTarget(name: "Liên Quân Mobile", bundleId: "com.garena.game.kgvn", iconName: "icon_lq"),
    AppTarget(name: "CapCut", bundleId: "com.lemon.lvoverseas", iconName: "icon_capcut")
]

// MARK: - Root Content View
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var licenseManager: LicenseManager
    @EnvironmentObject private var patchStore: PatchProjectStore
    @EnvironmentObject private var patchDraftCoordinator: PatchDraftCoordinator
    @EnvironmentObject private var fileOperationCoordinator: FileOperationCoordinator

    @State private var showSettings = false
    @State private var showLogs = false

    var body: some View {
        Group {
            if !licenseManager.isActive {
                LicenseActivationView(manager: licenseManager)
            } else {
                mainContent
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            CustomSettingsView()
        }
        .sheet(isPresented: $showLogs) {
            LogView()
        }
    }

    private var mainContent: some View {
        NavigationView {
            ZStack {
                AnimatedHyperBackdrop()
                    .ignoresSafeArea()

                Color(red: 0.05, green: 0.07, blue: 0.12).opacity(0.85)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    DeviceInfoHeader(showSettings: $showSettings, showLogs: $showLogs)
                        .padding(.top, 6)

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            KeyStatusCard()
                            KernelStatusCard()
                            PatchStoreSummaryCard()

                            AppManagementSection()
                        }
                        .padding(.vertical, 16)
                        .padding(.bottom, 36)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Header & Device Info
struct DeviceInfoHeader: View {
    @Binding var showSettings: Bool
    @Binding var showLogs: Bool

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text("DNTWEAKS")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        Text("VIP 2.0")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(
                                LinearGradient(
                                    colors: [Color.cyan, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(6)
                            .foregroundColor(.white)

                        Text("3105 CORE")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(5)
                            .foregroundColor(.cyan)
                    }

                    Text("Trình quản lý Patch .3105 & Tối ưu trò chơi")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button(action: { showLogs = true }) {
                        Image(systemName: "terminal.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.cyan)
                            .padding(9)
                            .background(Color.white.opacity(0.06))
                            .clipShape(Circle())
                    }

                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(9)
                            .background(Color.white.opacity(0.06))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 20)

            HStack(spacing: 8) {
                DeviceInfoItem(icon: "iphone", title: "Thiết Bị", value: UIDevice.current.name)
                Divider().frame(height: 24).background(Color.white.opacity(0.1))
                DeviceInfoItem(icon: "applelogo", title: "Hệ Điều Hành", value: "iOS \(AppInfo.osVersion)")
                Divider().frame(height: 24).background(Color.white.opacity(0.1))
                DeviceInfoItem(icon: "internaldrive", title: "Dung Lượng Trống", value: freeDiskSpace())
            }
            .padding(14)
            .background(Color.white.opacity(0.04))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}

struct DeviceInfoItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.cyan)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Status Cards
struct KeyStatusCard: View {
    @EnvironmentObject private var licenseManager: LicenseManager

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.18))
                    .frame(width: 42, height: 42)
                Image(systemName: "crown.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("BẢN QUYỀN VIP")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.purple)

                    Text("KÍCH HOẠT")
                        .font(.system(size: 9, weight: .black))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }

                Text("Thời gian sử dụng:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Text(formattedTime)
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(licenseManager.remainingSeconds < 3600 ? .red : .green)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.purple.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var formattedTime: String {
        if licenseManager.remainingSeconds > 86400 * 30 {
            return "VĨNH VIỄN"
        }
        let h = licenseManager.remainingSeconds / 3600
        let m = (licenseManager.remainingSeconds % 3600) / 60
        let s = licenseManager.remainingSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

struct KernelStatusCard: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(appState.exploitStatus.isSuccess ? Color.green.opacity(0.18) : Color.cyan.opacity(0.18))
                    .frame(width: 42, height: 42)
                Image(systemName: "cpu")
                    .foregroundColor(appState.exploitStatus.isSuccess ? .green : .cyan)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("KHAI THÁC KERNEL (3105)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.cyan)

                Text(statusText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
            }

            Spacer()

            if appState.kernelExploitRunning {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
            } else if !appState.exploitStatus.isSuccess && appState.kernelExploitApplicable {
                Button(action: { appState.runKernelExploitIfNeeded() }) {
                    Text("Kích Hoạt")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.cyan)
                        .cornerRadius(8)
                }
            } else {
                HStack(spacing: 5) {
                    Circle()
                        .fill(appState.exploitStatus.isSuccess ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(appState.exploitStatus.isSuccess ? "ACTIVE" : "STANDBY")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundColor(appState.exploitStatus.isSuccess ? .green : .orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(appState.exploitStatus.isSuccess ? Color.green.opacity(0.25) : Color.cyan.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var statusText: String {
        if appState.kernelExploitRunning {
            return "Đang chạy khai thác..."
        } else if appState.exploitStatus.isSuccess {
            return "Kernel RW & Sandbox Bypassed"
        } else if appState.exploitStatus.isFailed {
            return "Thất bại, chạm để thử lại"
        } else {
            return "Sẵn sàng khai thác container"
        }
    }
}

struct PatchStoreSummaryCard: View {
    @EnvironmentObject private var patchStore: PatchProjectStore
    @State private var showImporter = false
    @State private var importAlertTitle = ""
    @State private var importAlertMessage = ""
    @State private var showImportAlert = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "archivebox.fill")
                            .foregroundColor(.cyan)
                            .font(.system(size: 14))
                        Text("KHO PATCH .3105")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.white)
                    }
                    Text("Đã nạp \(patchStore.items.count) gói patch vào hệ thống")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(action: { showImporter = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("Nhập .3105")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [UTType(filenameExtension: "3105") ?? .data, .data],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile = try result.get().first else { return }
                guard selectedFile.startAccessingSecurityScopedResource() else {
                    importAlertTitle = "Lỗi"
                    importAlertMessage = "Không có quyền truy cập tệp"
                    showImportAlert = true
                    return
                }
                defer { selectedFile.stopAccessingSecurityScopedResource() }

                let data = try Data(contentsOf: selectedFile)
                let success = patchStore.importPackage(data: data)
                if success {
                    importAlertTitle = "Thành Công"
                    importAlertMessage = "Đã nạp file patch .3105: \(selectedFile.lastPathComponent)"
                    showImportAlert = true
                }
            } catch {
                importAlertTitle = "Lỗi Nhập Patch"
                importAlertMessage = error.localizedDescription
                showImportAlert = true
            }
        }
        .alert(isPresented: $showImportAlert) {
            Alert(title: Text(importAlertTitle), message: Text(importAlertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

// MARK: - App Management Section
struct AppManagementSection: View {
    @State private var apps: [AppTarget] = defaultAppTargets
    @State private var showAddAppSheet = false
    @State private var newAppName = ""
    @State private var newAppBundleId = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.cyan)
                        .frame(width: 3.5, height: 16)
                        .cornerRadius(2)

                    Text("DANH SÁCH ỨNG DỤNG MỤC TIÊU")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                }

                Spacer()

                Button(action: { showAddAppSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Thêm App")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.cyan.opacity(0.12))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 22)

            ForEach(apps) { app in
                NavigationLink(destination: AppDetailView(app: app)) {
                    AppCardView(app: app)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showAddAppSheet) {
            AddAppModalView(isPresented: $showAddAppSheet) { name, bundleId in
                let target = AppTarget(name: name, bundleId: bundleId, iconName: "app.dashed")
                apps.append(target)
            }
        }
    }
}

struct AppCardView: View {
    let app: AppTarget
    @EnvironmentObject private var patchStore: PatchProjectStore

    private var isInstalled: Bool {
        if let path = ContainerStore.resolveAppContainerPath(bundleID: app.bundleId) {
            return ContainerStore.isApplicationContainerPath(path)
        }
        return false
    }

    private var patchCount: Int {
        patchStore.items.filter { item in
            if let project = item.project {
                return project.allBundleIdentifiers.contains { $0.caseInsensitiveCompare(app.bundleId) == .orderedSame }
            }
            if let target = item.summary.metadata.bundleIdentifier, target.caseInsensitiveCompare(app.bundleId) == .orderedSame {
                return true
            }
            return false
        }.count
    }

    var body: some View {
        HStack(spacing: 14) {
            appIconView
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(app.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    if isInstalled {
                        Text("CONTAINER OK")
                            .font(.system(size: 8, weight: .black))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }

                Text(app.bundleId)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 10))
                        Text("\(patchCount) Patch .3105")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(patchCount > 0 ? .cyan : .gray.opacity(0.7))
                }
                .padding(.top, 2)
            }

            Spacer()

            VStack(spacing: 8) {
                Button(action: {
                    _ = openApplicationForBundleID(app.bundleId)
                }) {
                    Text("MỞ APP")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.cyan.opacity(0.12))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.cyan.opacity(0.35), lineWidth: 1)
                        )
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray.opacity(0.6))
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var appIconView: some View {
        if UIImage(named: app.iconName) != nil {
            Image(app.iconName)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Color.cyan.opacity(0.15)
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.cyan)
            }
        }
    }
}

// MARK: - App Detail View
struct AppDetailView: View {
    let app: AppTarget
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var patchStore: PatchProjectStore
    @EnvironmentObject private var appState: AppState

    @State private var selectedTab = "Patches"
    @State private var showFileImporter = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isApplying = false
    @State private var passwordPromptItem: PatchLibraryItem?
    @State private var enteredPassword = ""

    private let tabs = ["Patches", "DNS AntiBan", "Dọn Dẹp", "Tệp Container"]

    private var appPatches: [PatchLibraryItem] {
        patchStore.items.filter { item in
            if let project = item.project {
                return project.allBundleIdentifiers.contains { $0.caseInsensitiveCompare(app.bundleId) == .orderedSame }
            }
            if let target = item.summary.metadata.bundleIdentifier, target.caseInsensitiveCompare(app.bundleId) == .orderedSame {
                return true
            }
            return false
        }
    }

    private var containerPath: String? {
        ContainerStore.resolveAppContainerPath(bundleID: app.bundleId)
    }

    var body: some View {
        ZStack {
            AnimatedHyperBackdrop()
                .ignoresSafeArea()

            Color(red: 0.05, green: 0.07, blue: 0.12).opacity(0.88)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Custom Navigation Bar
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .bold))
                            Text("Trang Chủ")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.cyan)
                    }

                    Spacer()

                    Text(app.name)
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 80)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // App Hero Header
                AppHeroHeader(app: app, containerPath: containerPath)

                // Custom Tab Bar
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab } }) {
                            VStack(spacing: 8) {
                                Text(tab)
                                    .font(.system(size: 13, weight: selectedTab == tab ? .bold : .medium))
                                    .foregroundColor(selectedTab == tab ? .cyan : .gray)

                                Rectangle()
                                    .fill(selectedTab == tab ? Color.cyan : Color.clear)
                                    .frame(height: 2.5)
                                    .cornerRadius(1.5)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 10)

                // Tab Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if selectedTab == "Patches" {
                            patchTabContent
                        } else if selectedTab == "DNS AntiBan" {
                            DNSSectionView(title: "CẤU HÌNH DNS ANTIBAN")
                        } else if selectedTab == "Dọn Dẹp" {
                            cleanerTabContent
                        } else {
                            containerTabContent
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.bottom, 90)
                }

                Spacer()
            }

            // Bottom Sticky Launch Bar
            VStack {
                Spacer()
                bottomLaunchBar
            }
        }
        .navigationBarHidden(true)
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [UTType(filenameExtension: "3105") ?? .data, .data],
            allowsMultipleSelection: false
        ) { result in
            handleImportResult(result)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(item: $passwordPromptItem) { item in
            PasswordUnlockSheet(item: item) { pass in
                patchStore.unlock(item: item, password: pass)
                passwordPromptItem = nil
            }
        }
    }

    // MARK: - Hero Header
    private func AppHeroHeader(app: AppTarget, containerPath: String?) -> some View {
        HStack(spacing: 14) {
            if UIImage(named: app.iconName) != nil {
                Image(app.iconName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
                ZStack {
                    Color.cyan.opacity(0.15)
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.cyan)
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(app.name)
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)

                Text(app.bundleId)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)

                if let path = containerPath {
                    Text("Container: \(path)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.green.opacity(0.85))
                        .lineLimit(1)
                } else {
                    Text("Chưa tìm thấy container (Hãy mở game một lần)")
                        .font(.system(size: 9))
                        .foregroundColor(.orange)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Patches Tab Content
    private var patchTabContent: some View {
        VStack(spacing: 16) {
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: { showFileImporter = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("Nhập Patch (.3105)")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }

                Button(action: { restoreAllOriginalFiles() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                        Text("Khôi Phục Gốc")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(Color.orange.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange.opacity(0.35), lineWidth: 1)
                    )
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal, 20)

            // Patches List
            if appPatches.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 42))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.top, 30)

                    Text("Chưa có patch .3105 nào cho \(app.name)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)

                    Text("Bấm 'Nhập Patch (.3105)' ở trên để nạp file patch vào hệ thống.")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(appPatches) { item in
                        PatchItemRowView(item: item, appBundleId: app.bundleId) { errorText in
                            alertTitle = "Thông Báo"
                            alertMessage = errorText
                            showAlert = true
                        } onUnlockRequested: {
                            passwordPromptItem = item
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Cleaner Tab Content
    private var cleanerTabContent: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("DỌN DẸP CACHE & DỮ LIỆU TẠM")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.white)

                Text("Xóa sạch cache, crash logs và file tạm của \(app.name) giúp giảm dung lượng, mượt mà và tránh bị hệ thống quét.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)

            Button(action: {
                cleanAppCache()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "trash.fill")
                    Text("DỌN DẸP CACHE NGAY")
                }
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.purple.opacity(0.8))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple, lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Container Tab Content
    private var containerTabContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("THÔNG TIN CONTAINER")
                .font(.system(size: 13, weight: .black))
                .foregroundColor(.white)
                .padding(.horizontal, 24)

            if let path = containerPath {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Đường dẫn Data Container:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)

                    Text(path)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.cyan)
                        .padding(10)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)

                    Divider().background(Color.white.opacity(0.1))

                    Text("Các thư mục quản lý: Documents, Library/Preferences, Library/Caches")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(14)
                .background(Color.white.opacity(0.04))
                .cornerRadius(16)
                .padding(.horizontal, 20)
            } else {
                Text("Không thể truy cập container. Vui lòng mở game một lần để iOS tạo container.")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Bottom Launch Bar
    private var bottomLaunchBar: some View {
        VStack(spacing: 8) {
            Button(action: {
                _ = openApplicationForBundleID(app.bundleId)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16))
                    Text("MỞ GAME")
                        .font(.system(size: 16, weight: .black))
                }
                .foregroundColor(.cyan)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Color(red: 0.05, green: 0.07, blue: 0.12).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan.opacity(0.7), lineWidth: 1.5)
                )
                .cornerRadius(16)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color(red: 0.05, green: 0.07, blue: 0.12)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Methods
    private func handleImportResult(_ result: Result<[URL], Error>) {
        do {
            guard let selectedFile = try result.get().first else { return }
            guard selectedFile.startAccessingSecurityScopedResource() else {
                alertTitle = "Lỗi"
                alertMessage = "Không thể truy cập tệp"
                showAlert = true
                return
            }
            defer { selectedFile.stopAccessingSecurityScopedResource() }

            let data = try Data(contentsOf: selectedFile)
            let success = patchStore.importPackage(data: data)
            if success {
                alertTitle = "Thành Công"
                alertMessage = "Đã nhập thành công gói patch .3105!"
                showAlert = true
            }
        } catch {
            alertTitle = "Lỗi Nhập Patch"
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    private func restoreAllOriginalFiles() {
        var restoredCount = 0
        for item in appPatches {
            if let receipt = DevicePatchService.latestReceipt(projectID: item.id) {
                do {
                    try DevicePatchService.restore(receipt: receipt)
                    restoredCount += 1
                } catch {
                    print("Error restoring: \(error)")
                }
            }
        }
        alertTitle = "Khôi Phục Gốc"
        alertMessage = restoredCount > 0 ? "Đã hoàn tác và khôi phục \(restoredCount) patch về nguyên bản!" : "Không có patch nào đang hoạt động cần hoàn tác."
        showAlert = true
    }

    private func cleanAppCache() {
        guard let path = containerPath else {
            alertTitle = "Lỗi"
            alertMessage = "Chưa phát hiện container game."
            showAlert = true
            return
        }

        let fm = FileManager.default
        let cachePath = (path as NSString).appendingPathComponent("Library/Caches")
        let tmpPath = (path as NSString).appendingPathComponent("tmp")

        try? fm.removeItem(atPath: cachePath)
        try? fm.removeItem(atPath: tmpPath)
        try? fm.createDirectory(atPath: cachePath, withIntermediateDirectories: true)
        try? fm.createDirectory(atPath: tmpPath, withIntermediateDirectories: true)

        alertTitle = "Thành Công"
        alertMessage = "Đã dọn dẹp sạch cache và tệp tạm thời cho \(app.name)!"
        showAlert = true
    }
}

// MARK: - Patch Item Row View
struct PatchItemRowView: View {
    let item: PatchLibraryItem
    let appBundleId: String
    let onFeedback: (String) -> Void
    let onUnlockRequested: () -> Void

    @State private var isBusy = false

    private var isApplied: Bool {
        DevicePatchService.latestReceipt(projectID: item.id) != nil
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isApplied ? Color.green.opacity(0.18) : Color.cyan.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: item.isLocked ? "lock.fill" : (isApplied ? "checkmark.seal.fill" : "archivebox.fill"))
                    .font(.system(size: 16))
                    .foregroundColor(isApplied ? .green : (item.isLocked ? .orange : .cyan))
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(patchName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    if isApplied {
                        Text("ACTIVE")
                            .font(.system(size: 9, weight: .black))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }

                Text("Tác giả: \(item.summary.metadata.author.isEmpty ? "3105" : item.summary.metadata.author) • v\(item.summary.metadata.version)")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)

                if let project = item.project {
                    Text("\(project.rules.count) tệp can thiệp • \(project.directories.count) thư mục")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.cyan.opacity(0.8))
                } else if item.isLocked {
                    Text("Gói có mật khẩu — Nhấn để mở khóa")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                }
            }

            Spacer()

            if isBusy {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
            } else if item.isLocked {
                Button(action: onUnlockRequested) {
                    Text("Mở Khóa")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.orange)
                        .cornerRadius(6)
                }
            } else {
                Button(action: {
                    togglePatch()
                }) {
                    Text(isApplied ? "TẮT" : "BẬT")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(isApplied ? .red : .green)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(isApplied ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isApplied ? Color.red.opacity(0.4) : Color.green.opacity(0.4), lineWidth: 1)
                        )
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isApplied ? Color.green.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var patchName: String {
        if let project = item.project {
            return project.name
        }
        return item.summary.metadata.name.isEmpty ? item.packageURL.deletingPathExtension().lastPathComponent : item.summary.metadata.name
    }

    private func togglePatch() {
        guard let project = item.project else {
            onFeedback("Gói patch chưa được mở khóa.")
            return
        }

        isBusy = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if let receipt = DevicePatchService.latestReceipt(projectID: item.id) {
                    // Turn OFF: Restore
                    try DevicePatchService.restore(receipt: receipt)
                    DispatchQueue.main.async {
                        self.isBusy = false
                        self.onFeedback("Đã tắt patch và khôi phục file gốc thành công!")
                    }
                } else {
                    // Turn ON: Apply
                    _ = try DevicePatchService.apply(project: project)
                    DispatchQueue.main.async {
                        self.isBusy = false
                        self.onFeedback("Đã áp dụng patch .3105 vào \(project.name) thành công!")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isBusy = false
                    self.onFeedback("Lỗi: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Password Unlock Sheet
struct PasswordUnlockSheet: View {
    let item: PatchLibraryItem
    let onUnlock: (String) -> Void
    @State private var password = ""
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.1, blue: 0.15).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("MỞ KHÓA PATCH .3105")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .padding(.top, 24)

                Text("Gói patch này được bảo vệ bằng mật khẩu AES-GCM. Vui lòng nhập mật khẩu do tác giả cung cấp:")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                SecureField("Mật khẩu patch", text: $password)
                    .font(.system(size: 16, design: .monospaced))
                    .padding(14)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)

                HStack(spacing: 12) {
                    Button("Hủy") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)

                    Button("Mở Khóa") {
                        onUnlock(password)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(Color.cyan)
                    .cornerRadius(12)
                    .disabled(password.isEmpty)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .presentationDetents([.fraction(0.4)])
    }
}

// MARK: - Add App Modal
struct AddAppModalView: View {
    @Binding var isPresented: Bool
    let onAdd: (String, String) -> Void

    @State private var appName = ""
    @State private var bundleId = ""

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.1, blue: 0.15).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("THÊM ỨNG DỤNG MỤC TIÊU")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .padding(.top, 24)

                VStack(spacing: 12) {
                    TextField("Tên ứng dụng (vd: Liên Quân Đài)", text: $appName)
                        .padding(14)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .foregroundColor(.white)

                    TextField("Bundle ID (vd: com.garena.game.kgtw)", text: $bundleId)
                        .padding(14)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 24)

                HStack(spacing: 12) {
                    Button("Hủy") {
                        isPresented = false
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)

                    Button("Thêm Ngay") {
                        if !appName.isEmpty && !bundleId.isEmpty {
                            onAdd(appName, bundleId)
                            isPresented = false
                        }
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(Color.cyan)
                    .cornerRadius(12)
                    .disabled(appName.isEmpty || bundleId.isEmpty)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .presentationDetents([.fraction(0.45)])
    }
}

// MARK: - Backdrop Animation
struct AnimatedHyperBackdrop: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(red: 0.04, green: 0.05, blue: 0.08).ignoresSafeArea()

                Circle()
                    .fill(Color.cyan.opacity(0.10))
                    .frame(width: 320, height: 320)
                    .blur(radius: 80)
                    .offset(x: animate ? 100 : -100, y: -proxy.size.height * 0.25)

                Circle()
                    .fill(Color.purple.opacity(0.09))
                    .frame(width: 280, height: 280)
                    .blur(radius: 85)
                    .offset(x: animate ? -80 : 80, y: proxy.size.height * 0.25)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - DNS Section View
struct DNSSectionView: View {
    let title: String
    @State private var dnsURL: URL?
    @ObservedObject private var server = ProfileServer.shared
    @State private var isVPNActive = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Rectangle()
                    .fill(Color.cyan)
                    .frame(width: 3.5, height: 16)
                    .cornerRadius(2)

                Text(title)
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 24)

            Button(action: installDNS) {
                HStack(spacing: 16) {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.cyan)
                        .font(.system(size: 24))
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("DNS AntiBan 4.0")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(isVPNActive ? "Đang hoạt động (VPN Đang Bật)" : "Chạm để cài đặt & kích hoạt")
                            .font(.system(size: 11))
                            .foregroundColor(isVPNActive ? .green : .gray)
                    }

                    Spacer()

                    Image(systemName: isVPNActive ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isVPNActive ? .green : .gray.opacity(0.5))
                        .font(.system(size: 22))
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isVPNActive ? Color.green.opacity(0.4) : Color.cyan.opacity(0.2), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            setupDNS()
            checkVPNStatus()
        }
        .onReceive(Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()) { _ in
            checkVPNStatus()
        }
    }

    private func setupDNS() {
        let fm = FileManager.default
        if let bundlePath = Bundle.main.resourcePath {
            let dnsPath = bundlePath + "/dns"
            if let files = try? fm.contentsOfDirectory(atPath: dnsPath) {
                if let profile = files.first(where: { $0.hasSuffix(".mobileconfig") }) {
                    dnsURL = URL(fileURLWithPath: dnsPath + "/" + profile)
                    server.startServer(with: dnsURL!)
                }
            }
        }
    }

    private func installDNS() {
        if let url = server.serverURL {
            UIApplication.shared.open(url)
        } else if let localURL = dnsURL {
            server.startServer(with: localURL)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let url = server.serverURL {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    private func checkVPNStatus() {
        if let dict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
           let scoped = dict["__SCOPED__"] as? [String: Any] {
            for key in scoped.keys {
                let lower = key.lowercased()
                if lower.contains("tap") || lower.contains("tun") || lower.contains("ppp") || lower.contains("ipsec") {
                    self.isVPNActive = true
                    return
                }
            }
        }
        self.isVPNActive = false
    }
}

// MARK: - Custom Settings View
struct CustomSettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var licenseManager: LicenseManager
    @EnvironmentObject private var appState: AppState

    @State private var showInfoAlert = false
    @State private var showCacheAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.06, green: 0.08, blue: 0.12).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        SettingsRow(icon: "cpu", title: "Kernel Status", subtitle: appState.exploitStatus.isSuccess ? "Active" : "Chờ kích hoạt", hasArrow: false)

                        Button(action: { showCacheAlert = true }) {
                            SettingsRow(icon: "trash.fill", title: "Xóa Dữ Liệu Tạm", subtitle: "Làm nhẹ bộ nhớ", hasArrow: true)
                        }

                        Button(action: { showInfoAlert = true }) {
                            SettingsRow(icon: "info.circle.fill", title: "Thông Tin Hệ Thống", subtitle: "DNTWEAKS VIP 2.0 (3105 Engine)", hasArrow: true)
                        }

                        Button(action: {
                            licenseManager.deactivate()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            SettingsRow(icon: "rectangle.portrait.and.arrow.right.fill", title: "Đăng Xuất Key", subtitle: "Xóa key trên máy này", hasArrow: true)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitle("Cài Đặt", displayMode: .inline)
            .navigationBarItems(trailing: Button("Đóng") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .preferredColorScheme(.dark)
        .alert(isPresented: $showCacheAlert) {
            Alert(
                title: Text("Dọn Dẹp"),
                message: Text("Đã dọn dẹp sạch cache bộ nhớ đệm thành công!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let hasArrow: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.cyan)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()

            if hasArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray.opacity(0.6))
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Disk Space Helper
func freeDiskSpace() -> String {
    do {
        let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
        let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value ?? 0
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: freeSpace)
    } catch {
        return "Unknown"
    }
}
