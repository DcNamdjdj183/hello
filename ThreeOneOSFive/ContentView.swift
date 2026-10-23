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
    @State private var showAppleRestartAlert = false
    @State private var restartAlertTitle = "Yêu Cầu Khởi Động Lại"
    @State private var restartAlertMessage = "Cần khởi động lại máy để áp dụng các thay đổi cấu hình vào bộ nhớ đệm hệ thống."
    @State private var isSimulatingRespring = false

    var body: some View {
        Group {
            if !licenseManager.isActive {
                LicenseActivationView(manager: licenseManager)
            } else {
                ZStack {
                    mainContent

                    if isSimulatingRespring {
                        AppleRespringOverlayView()
                            .transition(.opacity)
                            .zIndex(999)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            CustomSettingsView()
        }
        .sheet(isPresented: $showLogs) {
            LogView()
        }
        .alert(isPresented: $showAppleRestartAlert) {
            Alert(
                title: Text(restartAlertTitle),
                message: Text(restartAlertMessage),
                primaryButton: .destructive(Text("Khởi Động Lại Ngay")) {
                    triggerDeviceRespring()
                },
                secondaryButton: .cancel(Text("Để Sau"))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DNTWEAKS_TriggerAppleRestartAlert"))) { notif in
            if let featureName = notif.object as? String {
                restartAlertTitle = "Yêu Cầu Khởi Động Lại"
                restartAlertMessage = "Bạn vừa kích hoạt '\(featureName)'. Để các thay đổi có hiệu lực đầy đủ trong trò chơi và bộ nhớ đệm iOS, vui lòng khởi động lại thiết bị."
            }
            showAppleRestartAlert = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DNTWEAKS_PerformAppleRespring"))) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                isSimulatingRespring = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSimulatingRespring = false
                }
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.success)
            }
        }
    }

    private var mainContent: some View {
        NavigationStack {
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

                            ExternalIOSDashboardView()
                        }
                        .padding(.vertical, 16)
                        .padding(.bottom, 36)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .environmentObject(licenseManager)
    }
}

// MARK: - Header & Device Info
struct DeviceInfoHeader: View {
    @EnvironmentObject private var licenseManager: LicenseManager
    @Binding var showSettings: Bool
    @Binding var showLogs: Bool

    private var tierBadgeColor: (bg: Color, text: Color) {
        if licenseManager.allowedModules.contains("all") || licenseManager.allowedModules.count == 3 {
            return (Color.cyan.opacity(0.15), Color.cyan)
        }
        if licenseManager.allowedModules.contains("aimlock") && licenseManager.allowedModules.count == 1 {
            return (Color.cyan.opacity(0.2), Color.cyan)
        }
        if licenseManager.allowedModules.contains("sensitive") && licenseManager.allowedModules.count == 1 {
            return (Color.orange.opacity(0.2), Color.orange)
        }
        if licenseManager.allowedModules.contains("regedit") && licenseManager.allowedModules.count == 1 {
            return (Color.yellow.opacity(0.2), Color.yellow)
        }
        return (Color.purple.opacity(0.2), Color.purple)
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text("EXTERNAL v2.0")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .tracking(1.2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color.cyan.opacity(0.4), radius: 8)

                        Text(licenseManager.tierName)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(tierBadgeColor.bg)
                            .cornerRadius(5)
                            .foregroundColor(tierBadgeColor.text)
                    }

                    Text("Aimlock • Sensitive • Regedit Suite")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button(action: { showLogs = true }) {
                        Image(systemName: "terminal.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.cyan)
                            .padding(8)
                            .background(Color.white.opacity(0.06))
                            .clipShape(Circle())
                    }

                    Button(action: { showSettings = true }) {
                        HStack(spacing: 5) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 12, weight: .bold))
                            Text("Cài Đặt")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
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
        VStack(spacing: 10) {
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
                        Text(licenseManager.tierName)
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
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Text(formattedTime)
                    .font(.system(size: 15, weight: .black, design: .monospaced))
                    .foregroundColor(licenseManager.remainingSeconds < 3600 ? .red : .green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
            }

            // Dải huy hiệu trạng thái cấp quyền từng phân hệ
            HStack(spacing: 6) {
                ModulePermissionBadge(name: "AIMLOCK", isAllowed: licenseManager.canAccess(category: .aimlock), color: .cyan)
                ModulePermissionBadge(name: "SENSITIVE", isAllowed: licenseManager.canAccess(category: .sensitive), color: .orange)
                ModulePermissionBadge(name: "REGEDIT", isAllowed: licenseManager.canAccess(category: .regedit), color: .yellow)
            }
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

// MARK: - Module Permission Badge
struct ModulePermissionBadge: View {
    let name: String
    let isAllowed: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isAllowed ? "checkmark.circle.fill" : "lock.fill")
                .font(.system(size: 9, weight: .bold))
            Text(name)
                .font(.system(size: 9, weight: .black))
        }
        .foregroundColor(isAllowed ? color : .gray.opacity(0.7))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(isAllowed ? color.opacity(0.12) : Color.white.opacity(0.03))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isAllowed ? color.opacity(0.35) : Color.white.opacity(0.06), lineWidth: 0.8)
        )
    }
}

struct KernelStatusCard: View {
    @EnvironmentObject private var appState: AppState
    @State private var showRestartAlert = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: "cpu")
                    .foregroundColor(.green)
                    .font(.system(size: 19, weight: .bold))
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("TÌNH TRẠNG ENGINE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.cyan)

                    Text("ACTIVE")
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundColor(.green)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1.5)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(4)
                }

                Text("External v2.0")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Spacer()

            Button(action: {
                showRestartAlert = true
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .bold))
                    Text("Khởi Động Lại")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.0, green: 0.9, blue: 0.8), Color.cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(9)
                .shadow(color: Color.cyan.opacity(0.3), radius: 5, x: 0, y: 2)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.cyan.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .alert(isPresented: $showRestartAlert) {
            Alert(
                title: Text("Yêu Cầu Khởi Động Lại"),
                message: Text("Khởi động lại thiết bị hoặc Respring để làm mới bộ nhớ đệm hệ thống và áp dụng đầy đủ cấu hình External v2.0?"),
                primaryButton: .destructive(Text("Khởi Động Lại Ngay")) {
                    triggerDeviceRespring()
                },
                secondaryButton: .cancel(Text("Để Sau"))
            )
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

    private var externalCount: Int {
        RegeditManager.shared.activeAimlockCount(for: app.bundleId) +
        RegeditManager.shared.activeSensitiveCount(for: app.bundleId) +
        RegeditManager.shared.activeRegeditCount(for: app.bundleId)
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
                        Image(systemName: "bolt.shield.fill")
                            .font(.system(size: 10))
                        Text("\(externalCount)/15 External")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(externalCount > 0 ? .cyan : .gray.opacity(0.7))
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
    @EnvironmentObject private var licenseManager: LicenseManager

    @State private var selectedTab = "🎯 External v2.0"
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false

    private let tabs = ["🎯 External v2.0", "DNS AntiBan", "Dọn Dẹp", "Tệp Container"]

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
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(tabs, id: \.self) { tab in
                            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab } }) {
                                VStack(spacing: 8) {
                                    Text(tab)
                                        .font(.system(size: 13, weight: selectedTab == tab ? .bold : .medium))
                                        .foregroundColor(selectedTab == tab ? .cyan : .gray)
                                        .lineLimit(1)

                                    Rectangle()
                                        .fill(selectedTab == tab ? Color.cyan : Color.clear)
                                        .frame(height: 2.5)
                                        .cornerRadius(1.5)
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 14)
                .padding(.bottom, 10)

                // Tab Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if selectedTab == "🎯 External v2.0" {
                            ExternalIOSGameSectionView(app: app)
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
        .toolbar(.hidden, for: .navigationBar)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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

// MARK: - Backdrop Background (Ổn định cố định, không trôi lệch)
struct AnimatedHyperBackdrop: View {
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.05, blue: 0.08).ignoresSafeArea()

            // Glowing cyan ambient top-right
            Circle()
                .fill(Color.cyan.opacity(0.12))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: 120, y: -260)

            // Glowing purple ambient bottom-left
            Circle()
                .fill(Color.purple.opacity(0.10))
                .frame(width: 320, height: 320)
                .blur(radius: 95)
                .offset(x: -120, y: 260)

            Color.black.opacity(0.18).ignoresSafeArea()
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

// MARK: - Apple Respring Simulation Overlay
struct AppleRespringOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "applelogo")
                    .font(.system(size: 64))
                    .foregroundColor(.white)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.4)
            }
        }
    }
}

func triggerDeviceRespring() {
    let feedback = UINotificationFeedbackGenerator()
    feedback.notificationOccurred(.warning)
    NotificationCenter.default.post(name: NSNotification.Name("DNTWEAKS_PerformAppleRespring"), object: nil)
}

// MARK: - Custom Settings View (Language, Version & System)
struct CustomSettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var licenseManager: LicenseManager
    @EnvironmentObject private var appState: AppState

    @AppStorage("app_language") private var selectedLanguage: String = "vi"
    @AppStorage("app_engine_version") private var selectedVersion: String = "v2.0_stable"

    @State private var showInfoAlert = false
    @State private var showCacheAlert = false
    @State private var showUpdateAlert = false
    @State private var showRespringConfirm = false

    private let languages: [(id: String, flag: String, name: String)] = [
        ("vi", "🇻🇳", "Tiếng Việt"),
        ("en", "🇺🇸", "English"),
        ("zh", "🇨🇳", "中文 (简体)")
    ]

    private let versions: [(id: String, name: String, desc: String)] = [
        ("v2.0_stable", "External v2.0 (Ổn định)", "Bản chuẩn ổn định cho mọi thiết bị"),
        ("v2.0_quantum", "External v2.0.1 Quantum", "Tối ưu hóa ProMotion 120Hz & Zero Latency"),
        ("v2.0_ultralow", "External v2.0 Low-Latency", "Tăng tốc điểm chạm cảm ứng màn hình")
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.06, green: 0.08, blue: 0.12).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // 1. NGÔN NGỮ (LANGUAGE)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NGÔN NGỮ (LANGUAGE)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.cyan)
                                .padding(.horizontal, 4)

                            VStack(spacing: 6) {
                                ForEach(languages, id: \.id) { item in
                                    Button(action: {
                                        selectedLanguage = item.id
                                        let feedback = UIImpactFeedbackGenerator(style: .medium)
                                        feedback.impactOccurred()
                                    }) {
                                        HStack(spacing: 12) {
                                            Text(item.flag)
                                                .font(.system(size: 20))
                                            Text(item.name)
                                                .font(.system(size: 14, weight: selectedLanguage == item.id ? .bold : .medium))
                                                .foregroundColor(.white)
                                            Spacer()
                                            if selectedLanguage == item.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.cyan)
                                                    .font(.system(size: 17))
                                            }
                                        }
                                        .padding(14)
                                        .background(Color.white.opacity(selectedLanguage == item.id ? 0.08 : 0.03))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedLanguage == item.id ? Color.cyan.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // 2. PHIÊN BẢN & ENGINE (VERSION)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("PHIÊN BẢN (VERSION)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.cyan)

                                Spacer()

                                Text("EXTERNAL v2.0 PRO")
                                    .font(.system(size: 9, weight: .black, design: .monospaced))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.cyan)
                                    .cornerRadius(4)
                            }
                            .padding(.horizontal, 4)

                            VStack(spacing: 6) {
                                ForEach(versions, id: \.id) { ver in
                                    Button(action: {
                                        selectedVersion = ver.id
                                        let feedback = UIImpactFeedbackGenerator(style: .medium)
                                        feedback.impactOccurred()
                                    }) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedVersion == ver.id ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
                                                    .frame(width: 32, height: 32)
                                                Image(systemName: "bolt.shield.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(selectedVersion == ver.id ? .cyan : .gray)
                                            }

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(ver.name)
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundColor(.white)
                                                Text(ver.desc)
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()

                                            if selectedVersion == ver.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.cyan)
                                                    .font(.system(size: 17))
                                            }
                                        }
                                        .padding(12)
                                        .background(Color.white.opacity(selectedVersion == ver.id ? 0.08 : 0.03))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedVersion == ver.id ? Color.cyan.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }

                                Button(action: { showUpdateAlert = true }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("Kiểm Tra Bản Cập Nhật Mới")
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.cyan)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 11)
                                    .background(Color.cyan.opacity(0.12))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .padding(.top, 4)
                            }
                        }

                        // 3. THAO TÁC HỆ THỐNG
                        VStack(alignment: .leading, spacing: 8) {
                            Text("HỆ THỐNG & BỘ NHỚ")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 4)

                            VStack(spacing: 8) {
                                Button(action: { showRespringConfirm = true }) {
                                    SettingsRow(icon: "arrow.clockwise", title: "Khởi Động Lại / Respring", subtitle: "Làm mới bộ nhớ đệm hệ thống", hasArrow: true)
                                }

                                Button(action: { showCacheAlert = true }) {
                                    SettingsRow(icon: "trash.fill", title: "Xóa Dữ Liệu Tạm", subtitle: "Làm nhẹ bộ nhớ sandbox", hasArrow: true)
                                }

                                Button(action: { showInfoAlert = true }) {
                                    SettingsRow(icon: "info.circle.fill", title: "Thông Tin Hệ Thống", subtitle: "EXTERNAL v2.0 PRO VIP", hasArrow: true)
                                }

                                Button(action: {
                                    licenseManager.deactivate()
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    SettingsRow(icon: "rectangle.portrait.and.arrow.right.fill", title: "Đăng Xuất Key", subtitle: "Xóa key VIP trên máy này", hasArrow: true)
                                }
                            }
                        }

                    }
                    .padding(20)
                }
            }
            .navigationBarTitle("Cài Đặt", displayMode: .inline)
            .navigationBarItems(trailing: Button("Xong") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .preferredColorScheme(.dark)
        .alert(isPresented: $showCacheAlert) {
            Alert(title: Text("Dọn Dẹp"), message: Text("Đã dọn dẹp sạch cache bộ nhớ đệm thành công!"), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showUpdateAlert) {
            Alert(title: Text("Cập Nhật Phiên Bản"), message: Text("Bạn đang sử dụng phiên bản mới nhất: External v2.0 PRO VIP (Build 2026.10.21).\nKhông có bản cập nhật mới nào."), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showInfoAlert) {
            Alert(title: Text("Thông Tin EXTERNAL v2.0"), message: Text("EXTERNAL v2.0 PRO VIP\nEngine: External v2.0\nKernel: Exploit Bypass OK\nTouch Sampling: 240Hz Ultra\nStatus: Lifetime VIP Active"), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showRespringConfirm) {
            Alert(
                title: Text("Yêu Cầu Khởi Động Lại"),
                message: Text("Khởi động lại thiết bị hoặc Respring để làm mới bộ nhớ đệm hệ thống và áp dụng cấu hình External v2.0?"),
                primaryButton: .destructive(Text("Khởi Động Lại Ngay")) {
                    presentationMode.wrappedValue.dismiss()
                    triggerDeviceRespring()
                },
                secondaryButton: .cancel(Text("Để Sau"))
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

// MARK: - External iOS Dashboard View
struct ExternalIOSDashboardView: View {
    @EnvironmentObject private var licenseManager: LicenseManager
    @ObservedObject private var manager = RegeditManager.shared
    @State private var selectedSubTab: ExternalCategory = .aimlock
    @State private var selectedGameBundleId: String? = nil // nil = Tất cả game
    @State private var toastMessage: String?
    @State private var showToast = false
    @State private var syncAlertMessage = ""
    @State private var showSyncAlert = false

    private var currentTargetName: String {
        if let id = selectedGameBundleId, let match = defaultAppTargets.first(where: { $0.bundleId == id }) {
            return match.name
        }
        return "Tất Cả Game"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header Title
            HStack {
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan, Color.purple, Color.orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4, height: 20)
                        .cornerRadius(2)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("EXTERNAL IOS")
                                .font(.system(size: 15, weight: .black))
                                .foregroundColor(.white)
                            Text("PRO VIP")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(.black)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.cyan)
                                .cornerRadius(4)
                        }
                        Text("Aimlock V1-V5 • Sensitive V1-V5 • Regedit V1-V5 Engine")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                // Overall active count
                HStack(spacing: 5) {
                    Circle()
                        .fill(manager.activePresets.isEmpty ? Color.gray : Color.green)
                        .frame(width: 7, height: 7)
                    Text("\(manager.activePresets.count)/15 ON")
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundColor(manager.activePresets.isEmpty ? .gray : .green)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
            .padding(.horizontal, 20)

            // Target Game Selector Pill Carousel
            VStack(alignment: .leading, spacing: 6) {
                Text("MỤC TIÊU ÁP DỤNG:")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: { selectedGameBundleId = nil }) {
                            Text("🌐 Tất Cả Game")
                                .font(.system(size: 11, weight: selectedGameBundleId == nil ? .heavy : .medium))
                                .foregroundColor(selectedGameBundleId == nil ? .black : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(selectedGameBundleId == nil ? Color.cyan : Color.white.opacity(0.06))
                                .cornerRadius(20)
                        }
                        .buttonStyle(.plain)

                        ForEach(defaultAppTargets) { target in
                            Button(action: { selectedGameBundleId = target.bundleId }) {
                                Text(target.name)
                                    .font(.system(size: 11, weight: selectedGameBundleId == target.bundleId ? .heavy : .medium))
                                    .foregroundColor(selectedGameBundleId == target.bundleId ? .black : .white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(selectedGameBundleId == target.bundleId ? Color.cyan : Color.white.opacity(0.06))
                                    .cornerRadius(20)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            // Real-Time Hardware Performance HUD
            ExternalPerformanceHUD()
                .padding(.horizontal, 20)

            // Master Control Buttons
            HStack(spacing: 10) {
                Button(action: {
                    let permittedCategories = ExternalCategory.allCases.filter { licenseManager.canAccess(category: $0) }
                    if permittedCategories.isEmpty {
                        triggerToast("Key của bạn không có quyền kích hoạt bất kỳ phân hệ nào!")
                        return
                    }
                    for cat in permittedCategories {
                        switch cat {
                        case .aimlock:
                            manager.activateAllAimlock(for: selectedGameBundleId)
                        case .sensitive:
                            manager.activateAllSensitive(for: selectedGameBundleId)
                        case .regedit:
                            manager.activateAllRegedit(for: selectedGameBundleId)
                        }
                    }
                    let names = permittedCategories.map { $0.rawValue }.joined(separator: ", ")
                    triggerToast("Đã bật các phân hệ được cấp phép (\(names)) cho \(currentTargetName)!")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("DNTWEAKS_TriggerAppleRestartAlert"),
                        object: "External iOS (\(names))"
                    )
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text("BẬT TOÀN BỘ")
                            .font(.system(size: 11, weight: .black))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.9), Color.blue.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.cyan.opacity(0.3), radius: 8, x: 0, y: 3)
                }
                .buttonStyle(.plain)

                Button(action: {
                    manager.resetAll(for: selectedGameBundleId)
                    triggerToast("Đã đặt lại toàn bộ External iOS cho \(currentTargetName)!")
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 11, weight: .bold))
                        Text("ĐẶT LẠI")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: 80)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Button(action: {
                    if let id = selectedGameBundleId {
                        let res = manager.syncContainer(bundleId: id)
                        syncAlertMessage = res.message
                    } else {
                        var successCount = 0
                        for target in defaultAppTargets {
                            let res = manager.syncContainer(bundleId: target.bundleId)
                            if res.success { successCount += 1 }
                        }
                        syncAlertMessage = "Đã đồng bộ cấu hình External iOS vào \(successCount)/\(defaultAppTargets.count) Container ứng dụng!"
                    }
                    showSyncAlert = true
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 11, weight: .bold))
                        Text("LƯU TỆP")
                            .font(.system(size: 11, weight: .black))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(12)
                    .shadow(color: Color.green.opacity(0.25), radius: 6, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)

            // CATEGORY SWITCHER: AIMLOCK vs SENSITIVE vs REGEDIT
            HStack(spacing: 8) {
                // 1. AIMLOCK
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedSubTab = .aimlock
                    }
                }) {
                    VStack(spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: licenseManager.canAccess(category: .aimlock) ? "scope" : "lock.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text("AIMLOCK")
                                .font(.system(size: 11, weight: .heavy))
                            if !licenseManager.canAccess(category: .aimlock) {
                                Image(systemName: "lock.fill").font(.system(size: 8))
                            }
                        }
                        Text("\(manager.activeAimlockCount(for: selectedGameBundleId))/5 ON")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(selectedSubTab == .aimlock ? .black : .cyan)
                    }
                    .foregroundColor(selectedSubTab == .aimlock ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if selectedSubTab == .aimlock {
                                LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing)
                            } else {
                                Color.white.opacity(0.04)
                            }
                        }
                    )
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedSubTab == .aimlock ? Color.cyan.opacity(0.6) : Color.white.opacity(0.07), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                // 2. SENSITIVE
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedSubTab = .sensitive
                    }
                }) {
                    VStack(spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: licenseManager.canAccess(category: .sensitive) ? "bolt.fill" : "lock.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text("SENSITIVE")
                                .font(.system(size: 11, weight: .heavy))
                            if !licenseManager.canAccess(category: .sensitive) {
                                Image(systemName: "lock.fill").font(.system(size: 8))
                            }
                        }
                        Text("\(manager.activeSensitiveCount(for: selectedGameBundleId))/5 ON")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(selectedSubTab == .sensitive ? .black : .orange)
                    }
                    .foregroundColor(selectedSubTab == .sensitive ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if selectedSubTab == .sensitive {
                                LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing)
                            } else {
                                Color.white.opacity(0.04)
                            }
                        }
                    )
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedSubTab == .sensitive ? Color.orange.opacity(0.6) : Color.white.opacity(0.07), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                // 3. REGEDIT
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedSubTab = .regedit
                    }
                }) {
                    VStack(spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: licenseManager.canAccess(category: .regedit) ? "slider.horizontal.3" : "lock.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text("REGEDIT")
                                .font(.system(size: 11, weight: .heavy))
                            if !licenseManager.canAccess(category: .regedit) {
                                Image(systemName: "lock.fill").font(.system(size: 8))
                            }
                        }
                        Text("\(manager.activeRegeditCount(for: selectedGameBundleId))/5 ON")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(selectedSubTab == .regedit ? .black : .yellow)
                    }
                    .foregroundColor(selectedSubTab == .regedit ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if selectedSubTab == .regedit {
                                LinearGradient(colors: [Color.yellow, Color.purple], startPoint: .leading, endPoint: .trailing)
                            } else {
                                Color.white.opacity(0.04)
                            }
                        }
                    )
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedSubTab == .regedit ? Color.yellow.opacity(0.6) : Color.white.opacity(0.07), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)

            // Sub-category Quick Action Bar
            HStack {
                Text(selectedSubTab == .aimlock ? "BỘ KHÓA TÂM AIMLOCK V1 - V5" : (selectedSubTab == .sensitive ? "BỘ ĐỘ NHẠY SENSITIVE V1 - V5" : "BỘ THANH GHI REGEDIT V1 - V5"))
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    guard licenseManager.canAccess(category: selectedSubTab) else {
                        triggerToast("Key của bạn là [\(licenseManager.tierName)]. Không có quyền bật mục này! Cần nâng cấp Key VIP ALL.")
                        return
                    }
                    let groupName: String
                    if selectedSubTab == .aimlock {
                        manager.activateAllAimlock(for: selectedGameBundleId)
                        groupName = "Aimlock V1 - V5"
                        triggerToast("Đã bật toàn bộ Aimlock V1 - V5!")
                    } else if selectedSubTab == .sensitive {
                        manager.activateAllSensitive(for: selectedGameBundleId)
                        groupName = "Sensitive V1 - V5"
                        triggerToast("Đã bật toàn bộ Sensitive V1 - V5!")
                    } else {
                        manager.activateAllRegedit(for: selectedGameBundleId)
                        groupName = "Regedit V1 - V5"
                        triggerToast("Đã bật toàn bộ Regedit V1 - V5!")
                    }
                    NotificationCenter.default.post(
                        name: NSNotification.Name("DNTWEAKS_TriggerAppleRestartAlert"),
                        object: groupName
                    )
                }) {
                    Text("Bật Tất Cả")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(selectedSubTab == .aimlock ? .cyan : (selectedSubTab == .sensitive ? .orange : .yellow))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(6)
                }

                Button(action: {
                    if selectedSubTab == .aimlock {
                        manager.resetAllAimlock(for: selectedGameBundleId)
                        triggerToast("Đã tắt toàn bộ Aimlock V1 - V5!")
                    } else if selectedSubTab == .sensitive {
                        manager.resetAllSensitive(for: selectedGameBundleId)
                        triggerToast("Đã tắt toàn bộ Sensitive V1 - V5!")
                    } else {
                        manager.resetAllRegedit(for: selectedGameBundleId)
                        triggerToast("Đã tắt toàn bộ Regedit V1 - V5!")
                    }
                }) {
                    Text("Tắt Hết")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal, 22)

            // Cards List
            VStack(spacing: 14) {
                if selectedSubTab == .aimlock {
                    AimlockAdvancedSuiteCard(bundleId: selectedGameBundleId)
                    ForEach(allAimlockPresets) { preset in
                        ExternalPresetCard(preset: preset, bundleId: selectedGameBundleId)
                    }
                } else if selectedSubTab == .sensitive {
                    ForEach(allSensitivePresets) { preset in
                        ExternalPresetCard(preset: preset, bundleId: selectedGameBundleId)
                    }
                } else {
                    IOHIDTouchBoosterCard(bundleId: selectedGameBundleId)
                    ForEach(allRegeditSubPresets) { preset in
                        ExternalPresetCard(preset: preset, bundleId: selectedGameBundleId)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .overlay(
            VStack {
                if showToast, let msg = toastMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(msg)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.1, green: 0.12, blue: 0.18))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.5), radius: 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 10)
                }
                Spacer()
            }
        )
        .alert(isPresented: $showSyncAlert) {
            Alert(title: Text("Thông Báo Container"), message: Text(syncAlertMessage), dismissButton: .default(Text("OK")))
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DNTWEAKS_TriggerTierLockedToast"))) { notif in
            if let msg = notif.object as? String {
                triggerToast(msg)
            }
        }
    }

    private func triggerToast(_ msg: String) {
        toastMessage = msg
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { showToast = false }
        }
    }
}

// MARK: - External iOS Performance HUD
struct ExternalPerformanceHUD: View {
    var body: some View {
        HStack(spacing: 8) {
            HUDMetricItem(label: "POLLING", value: "240Hz", color: .cyan)
            HUDMetricItem(label: "LATENCY", value: "0.001ms", color: .green)
            HUDMetricItem(label: "DPI CURVE", value: "1200 DPI", color: .orange)
            HUDMetricItem(label: "DYNAMIC Y", value: "Zero Delay", color: .purple)
        }
        .padding(12)
        .background(Color(red: 0.07, green: 0.09, blue: 0.14))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

struct HUDMetricItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Aimlock Advanced Suite Card (Bone Selector, Smooth Aim Curve, FOV Circle)
struct AimlockAdvancedSuiteCard: View {
    let bundleId: String?
    @EnvironmentObject private var licenseManager: LicenseManager
    @ObservedObject private var manager = RegeditManager.shared

    @State private var currentBone: String = "head"
    @State private var smoothVal: Double = 75.0
    @State private var fovVal: Double = 90.0
    @State private var bezierOn: Bool = true

    private var isPermitted: Bool {
        licenseManager.canAccess(category: .aimlock)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 14) {
                // Header
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                        Image(systemName: "scope")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.cyan)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("BỘ ĐIỀU KHIỂN TÂM NÂNG CAO")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(.white)
                            Text("PRO")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(.black)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(Color.cyan)
                                .cornerRadius(4)
                        }
                        Text("Bone Selector • Smooth Curve • FOV Circle")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.cyan.opacity(0.8))
                    }
                    Spacer()
                }

                Divider().background(Color.white.opacity(0.08))

                // 1. BONE SELECTOR (Vùng Khóa Mục Tiêu)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.fill.viewfinder")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.cyan)
                        Text("BONE SELECTOR (VÙNG ƯU TIÊN KHÓA)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text(currentBone == "head" ? "ĐẦU (100% HS)" : (currentBone == "neck" ? "CỔ (ỔN ĐỊNH)" : "NGỰC (BÁM DÍNH)"))
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(currentBone == "head" ? .red : (currentBone == "neck" ? .orange : .cyan))
                    }

                    HStack(spacing: 8) {
                        boneButton(id: "head", title: "🎯 ĐẦU (HEAD)", subtitle: "Hitbox 100%", color: .red)
                        boneButton(id: "neck", title: "⚡ CỔ (NECK)", subtitle: "Snap Nhẹ", color: .orange)
                        boneButton(id: "chest", title: "🛡️ NGỰC (CHEST)", subtitle: "Sấy Tầm Gần", color: .cyan)
                    }
                }

                Divider().background(Color.white.opacity(0.08))

                // 2. SMOOTH AIM CURVE (NỘI SUY BEZIER CURVE)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "waveform.path")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.green)
                        Text("SMOOTH AIM CURVE (NỘI SUY BEZIER)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(smoothVal))% MƯỢT")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.green)
                    }

                    Text("Kéo lướt mượt vào hitbox theo đường cong Bezier, chống giật tâm bất thường và né report ban tay.")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)

                    HStack(spacing: 12) {
                        Slider(value: $smoothVal, in: 1...100, step: 1) { _ in
                            manager.setSmoothFactor(smoothVal, for: bundleId)
                        }
                        .accentColor(.green)

                        Toggle("", isOn: $bezierOn)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .scaleEffect(0.8)
                            .onChange(of: bezierOn) { val in
                                manager.setBezierEnabled(val, for: bundleId)
                            }
                    }
                }

                Divider().background(Color.white.opacity(0.08))

                // 3. FOV RADIUS CIRCLE (VÒNG TRÒN GÓC QUÉT)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "circle.circle")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("FOV CIRCLE (VÒNG TRÒN GÓC QUÉT)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(fovVal))° FOV")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                    }

                    Text("Giới hạn góc quét nhận diện mục tiêu quanh tâm súng. Mục tiêu ngoài vòng FOV sẽ không bị kéo lệch tâm.")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)

                    Slider(value: $fovVal, in: 30...180, step: 5) { _ in
                        manager.setFovRadius(fovVal, for: bundleId)
                    }
                    .accentColor(.yellow)
                }
            }
            .padding(16)
            .background(Color(red: 0.07, green: 0.09, blue: 0.14))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.5), Color.blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )

            // Locked Overlay if no Aimlock access
            if !isPermitted {
                Color.black.opacity(0.85)
                    .cornerRadius(16)
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.red)
                    Text("CHỨC NĂNG BỊ KHÓA")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                    Text("Gói Key hiện tại không có quyền Aimlock Suite.\nVui lòng kích hoạt Key AIMLOCK hoặc ALL ACCESS VIP.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            currentBone = manager.targetBone(for: bundleId)
            smoothVal = manager.smoothFactor(for: bundleId)
            fovVal = manager.fovRadius(for: bundleId)
            bezierOn = manager.isBezierEnabled(for: bundleId)
        }
    }

    private func boneButton(id: String, title: String, subtitle: String, color: Color) -> some View {
        Button(action: {
            currentBone = id
            manager.setTargetBone(id, for: bundleId)
        }) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(currentBone == id ? .black : .white)
                Text(subtitle)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(currentBone == id ? .black.opacity(0.8) : color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Group {
                    if currentBone == id {
                        color
                    } else {
                        Color.white.opacity(0.04)
                    }
                }
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(currentBone == id ? color : Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - IOHID Touch Polling Booster Card (Giảm trễ cảm ứng & Khử Micro-shake)
struct IOHIDTouchBoosterCard: View {
    let bundleId: String?
    @EnvironmentObject private var licenseManager: LicenseManager
    @ObservedObject private var manager = RegeditManager.shared

    @State private var pollingRate: Int = 240
    @State private var antiMicroShake: Bool = true
    @State private var gestureFlush: Bool = true

    private var isPermitted: Bool {
        licenseManager.canAccess(category: .regedit)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 14) {
                // Header
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                        Image(systemName: "bolt.badge.clock.fill")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.yellow)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("IOHID TOUCH POLLING BOOSTER")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(.white)
                            Text("240Hz")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(.black)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(Color.yellow)
                                .cornerRadius(4)
                        }
                        Text("Giảm trễ cảm ứng • Khử rung giật Micro-Shake")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.yellow.opacity(0.85))
                    }
                    Spacer()
                }

                Divider().background(Color.white.opacity(0.08))

                // 1. TOUCH POLLING RATE (TẦN SỐ LẤY MẪU CẢM ỨNG)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "speedometer")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("TẦN SỐ QUÉT ĐIỂM CHẠM CẢM ỨNG")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text(pollingRate == 240 ? "240Hz (ULTRA BOOST)" : "120Hz (PROMOTION)")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(pollingRate == 240 ? .yellow : .cyan)
                    }

                    HStack(spacing: 8) {
                        Button(action: {
                            pollingRate = 120
                            manager.setTouchPollingRate(120, for: bundleId)
                        }) {
                            VStack(spacing: 2) {
                                Text("120Hz STANDARD")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(pollingRate == 120 ? .black : .white)
                                Text("Chuẩn ProMotion (0.005ms)")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(pollingRate == 120 ? .black.opacity(0.8) : .gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(pollingRate == 120 ? Color.cyan : Color.white.opacity(0.04))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(pollingRate == 120 ? Color.cyan : Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            pollingRate = 240
                            manager.setTouchPollingRate(240, for: bundleId)
                        }) {
                            VStack(spacing: 2) {
                                Text("🔥 240Hz QUANTUM BOOST")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(pollingRate == 240 ? .black : .white)
                                Text("Zero Latency (0.001ms)")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(pollingRate == 240 ? .black.opacity(0.8) : .yellow)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(pollingRate == 240 ? Color.yellow : Color.white.opacity(0.04))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(pollingRate == 240 ? Color.yellow : Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Divider().background(Color.white.opacity(0.08))

                // 2. KHỬ RUNG GIẬT MICRO-SHAKE
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("Khử Rung Giật Micro-Shake")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Text("LỌC NHIỄU")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(.green)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(3)
                        }
                        Text("Lọc bỏ rung lắc micro-tremor khi đặt ngón tay, giữ tâm dính chặt hitbox.")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Toggle("", isOn: $antiMicroShake)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .yellow))
                        .scaleEffect(0.85)
                        .onChange(of: antiMicroShake) { val in
                            manager.setAntiMicroShake(val, for: bundleId)
                        }
                }

                Divider().background(Color.white.opacity(0.08))

                // 3. CAN THIỆP BUFFER CỬ CHỈ (GESTURE BUFFER FLUSH)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("Can Thiệp Buffer Cử Chỉ")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Text("ZERO DELAY")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(3)
                        }
                        Text("Xóa hàng đợi buffer cảm ứng iOS, phản hồi thao tác kéo tâm tức thì.")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Toggle("", isOn: $gestureFlush)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .yellow))
                        .scaleEffect(0.85)
                        .onChange(of: gestureFlush) { val in
                            manager.setGestureBufferFlush(val, for: bundleId)
                        }
                }

                // Driver Status Badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("IOHIDEvent System: ACTIVE • \(pollingRate)Hz Sampling • Zero Micro-Shake")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.green.opacity(0.9))
                }
                .padding(.top, 2)
            }
            .padding(16)
            .background(Color(red: 0.08, green: 0.08, blue: 0.12))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.5), Color.orange.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )

            // Locked Overlay if no Regedit access
            if !isPermitted {
                Color.black.opacity(0.85)
                    .cornerRadius(16)
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.yellow)
                    Text("CHỨC NĂNG BỊ KHÓA")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                    Text("Gói Key hiện tại không có quyền Regedit Suite.\nVui lòng kích hoạt Key REGEDIT hoặc ALL ACCESS VIP.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            pollingRate = manager.touchPollingRate(for: bundleId)
            antiMicroShake = manager.isAntiMicroShakeEnabled(for: bundleId)
            gestureFlush = manager.isGestureBufferFlushEnabled(for: bundleId)
        }
    }
}
struct ExternalPresetCard: View {
    let preset: ExternalPreset
    let bundleId: String?
    @EnvironmentObject private var licenseManager: LicenseManager
    @ObservedObject private var manager = RegeditManager.shared

    private var isPermitted: Bool {
        licenseManager.canAccess(category: preset.category)
    }

    private var isActive: Bool {
        manager.isEnabled(presetId: preset.id, for: bundleId)
    }

    private var currentSens: Double {
        manager.sensitivity(presetId: preset.id, for: bundleId)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 12) {
                // Header: Icon, Titles, Badges, Toggle
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(preset.accentColor.opacity(isActive ? 0.25 : 0.12))
                            .frame(width: 44, height: 44)

                        Image(systemName: isPermitted ? preset.icon : "lock.fill")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(isPermitted ? (isActive ? preset.accentColor : .gray) : .gray.opacity(0.6))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(preset.title)
                                .font(.system(size: 15, weight: .black))
                                .foregroundColor(isPermitted ? .white : .gray)

                            Text("V\(preset.level)")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(.black)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(isPermitted ? preset.accentColor : Color.gray)
                                .cornerRadius(4)

                            if !isPermitted {
                                Text("KHÓA")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.red.opacity(0.15))
                                    .cornerRadius(4)
                            } else {
                                Text(preset.defaultDelay)
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(preset.accentColor)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(preset.accentColor.opacity(0.12))
                                    .cornerRadius(4)
                            }
                        }

                        Text(isPermitted ? preset.subtitle : "Chưa được cấp quyền trong gói key")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(isPermitted ? .gray : .red.opacity(0.8))
                    }

                    Spacer()

                    // Neon Toggle Switch or Lock Badge
                    Button(action: {
                        guard isPermitted else {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("DNTWEAKS_TriggerTierLockedToast"),
                                object: "Phân hệ [\(preset.category.rawValue.uppercased())] chưa được cấp quyền! Vui lòng nâng cấp gói Key."
                            )
                            return
                        }
                        let newState = manager.toggle(preset: preset, for: bundleId)
                        if newState {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("DNTWEAKS_TriggerAppleRestartAlert"),
                                object: "\(preset.title) (V\(preset.level))"
                            )
                        }
                    }) {
                        if isPermitted {
                            ZStack {
                                Capsule()
                                    .fill(isActive ? preset.accentColor : Color.white.opacity(0.15))
                                    .frame(width: 48, height: 26)

                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 22, height: 22)
                                    .offset(x: isActive ? 11 : -11)
                                    .shadow(color: Color.black.opacity(0.3), radius: 2)
                            }
                        } else {
                            HStack(spacing: 3) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 10, weight: .bold))
                                Text("LOCK")
                                    .font(.system(size: 9, weight: .black))
                            }
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(8)
                        }
                    }
                    .buttonStyle(.plain)
                }

                // Description
                Text(preset.description)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.75))
                    .lineSpacing(2)

                // Tags
                HStack(spacing: 6) {
                    ForEach(preset.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(isActive ? preset.accentColor : .gray)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(isActive ? preset.accentColor.opacity(0.1) : Color.white.opacity(0.04))
                            .cornerRadius(5)
                    }
                }

                // Slider: Lock Force / Sensitivity Adjustment
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(preset.category == .aimlock ? "LỰC HÚT TÂM (LOCK INTENSITY)" : "ĐỘ NHẠY KÉO TÂM (SENSITIVITY)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)

                        Spacer()

                        Text(String(format: "%.2fx (%.0f%%)", currentSens, currentSens * 100))
                            .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            .foregroundColor(preset.accentColor)
                    }

                    Slider(
                        value: Binding(
                            get: { self.currentSens },
                            set: { val in
                                if isPermitted {
                                    manager.setSensitivity(val, presetId: preset.id, for: bundleId)
                                }
                            }
                        ),
                        in: 1.0...3.0,
                        step: 0.05
                    )
                    .accentColor(preset.accentColor)
                    .disabled(!isPermitted)

                    HStack {
                        Text("Trục X: \(String(format: "%.2fx", currentSens * preset.xRatio))")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)

                        Spacer()

                        Text("Trục Y (Head Lock): \(String(format: "%.2fx", currentSens * preset.yRatio))")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(preset.accentColor)
                    }
                }
                .padding(10)
                .background(Color.black.opacity(0.25))
                .cornerRadius(10)
            }
            .blur(radius: isPermitted ? 0 : 2.5)
            .opacity(isPermitted ? 1.0 : 0.35)
            .disabled(!isPermitted)

            // Khóa làm mờ Overlay hiển thị khi không được cấp quyền
            if !isPermitted {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.55))

                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.red)
                    }

                    Text("CHƯA ĐƯỢC CẤP QUYỀN")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white)
                        .tracking(0.6)

                    Text("Gói Key không bao gồm phân hệ \(preset.category.rawValue)")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(red: 0.08, green: 0.10, blue: 0.16).opacity(0.92))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.7), radius: 10)
            }
        }
        .padding(16)
        .background(Color(red: 0.08, green: 0.10, blue: 0.16))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive && isPermitted ? preset.accentColor.opacity(0.6) : Color.white.opacity(0.07), lineWidth: isActive && isPermitted ? 1.5 : 1)
        )
        .shadow(color: isActive && isPermitted ? preset.accentColor.opacity(0.15) : Color.clear, radius: 10, x: 0, y: 4)
    }
}

// MARK: - External iOS Game Section View (Per-Game Tab)
struct ExternalIOSGameSectionView: View {
    let app: AppTarget
    @EnvironmentObject private var licenseManager: LicenseManager
    @ObservedObject private var manager = RegeditManager.shared
    @State private var selectedSubTab: ExternalCategory = .aimlock
    @State private var syncStatusMessage: String?
    @State private var showSyncAlert = false
    @State private var syncSuccess = false

    private var containerPath: String? {
        ContainerStore.resolveAppContainerPath(bundleID: app.bundleId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Container Status Banner
            HStack(spacing: 12) {
                Image(systemName: containerPath != nil ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(containerPath != nil ? .green : .yellow)

                VStack(alignment: .leading, spacing: 2) {
                    Text(containerPath != nil ? "CONTAINER ĐÃ KẾT NỐI" : "CHƯA TÌM THẤY CONTAINER")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(containerPath != nil ? .green : .yellow)

                    Text(containerPath != nil ? "Cấu hình tự động ghi vào Documents/DNTWEAKS_ExternalIOS.plist" : "Mở game một lần trên máy để iOS tạo thư mục Sandbox.")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding(12)
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(containerPath != nil ? Color.green.opacity(0.2) : Color.yellow.opacity(0.2), lineWidth: 1)
            )

            // Header Controls
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("EXTERNAL CHO \(app.name.uppercased())")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                    Text("Aimlock: \(manager.activeAimlockCount(for: app.bundleId))/5 • Sens: \(manager.activeSensitiveCount(for: app.bundleId))/5 • Reg: \(manager.activeRegeditCount(for: app.bundleId))/5")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.cyan)
                }

                Spacer()

                Button(action: {
                    let res = manager.syncContainer(bundleId: app.bundleId)
                    syncSuccess = res.success
                    syncStatusMessage = res.message
                    showSyncAlert = true
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Ghi Container")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.cyan)
                    .cornerRadius(8)
                }
            }

            // Quick action buttons for this game
            HStack(spacing: 10) {
                Button(action: {
                    let permitted = ExternalCategory.allCases.filter { licenseManager.canAccess(category: $0) }
                    if permitted.isEmpty {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("DNTWEAKS_TriggerTierLockedToast"),
                            object: "Gói key của bạn không có quyền kích hoạt bất kỳ phân hệ nào!"
                        )
                        return
                    }
                    for cat in permitted {
                        switch cat {
                        case .aimlock:
                            manager.activateAllAimlock(for: app.bundleId)
                        case .sensitive:
                            manager.activateAllSensitive(for: app.bundleId)
                        case .regedit:
                            manager.activateAllRegedit(for: app.bundleId)
                        }
                    }
                    let names = permitted.map { $0.rawValue }.joined(separator: ", ")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("DNTWEAKS_TriggerAppleRestartAlert"),
                        object: "\(names) (\(app.name))"
                    )
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                        Text(licenseManager.allowedModules.contains("all") || licenseManager.allowedModules.count == 3 ? "Bật Tất Cả Cho \(app.name)" : "Bật (\(licenseManager.tierName)) Cho \(app.name)")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.cyan.opacity(0.8))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                Button(action: {
                    manager.resetAll(for: app.bundleId)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle")
                        Text("Tắt Hết")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(maxWidth: 90)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }

            // Sub Tab Switcher: Aimlock vs Sensitive vs Regedit
            HStack(spacing: 8) {
                Button(action: { selectedSubTab = .aimlock }) {
                    HStack(spacing: 4) {
                        Text(licenseManager.canAccess(category: .aimlock) ? "🎯" : "🔒")
                        Text("AIMLOCK")
                    }
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(selectedSubTab == .aimlock ? .black : (licenseManager.canAccess(category: .aimlock) ? .white : .gray))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(selectedSubTab == .aimlock ? Color.cyan : Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Button(action: { selectedSubTab = .sensitive }) {
                    HStack(spacing: 4) {
                        Text(licenseManager.canAccess(category: .sensitive) ? "⚡" : "🔒")
                        Text("SENSITIVE")
                    }
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(selectedSubTab == .sensitive ? .black : (licenseManager.canAccess(category: .sensitive) ? .white : .gray))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(selectedSubTab == .sensitive ? Color.orange : Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Button(action: { selectedSubTab = .regedit }) {
                    HStack(spacing: 4) {
                        Text(licenseManager.canAccess(category: .regedit) ? "💎" : "🔒")
                        Text("REGEDIT")
                    }
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(selectedSubTab == .regedit ? .black : (licenseManager.canAccess(category: .regedit) ? .white : .gray))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(selectedSubTab == .regedit ? Color.yellow : Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            // Preset Cards List
            VStack(spacing: 14) {
                if selectedSubTab == .aimlock {
                    AimlockAdvancedSuiteCard(bundleId: app.bundleId)
                    ForEach(allAimlockPresets) { preset in
                        ExternalPresetCard(preset: preset, bundleId: app.bundleId)
                    }
                } else if selectedSubTab == .sensitive {
                    ForEach(allSensitivePresets) { preset in
                        ExternalPresetCard(preset: preset, bundleId: app.bundleId)
                    }
                } else {
                    IOHIDTouchBoosterCard(bundleId: app.bundleId)
                    ForEach(allRegeditSubPresets) { preset in
                        ExternalPresetCard(preset: preset, bundleId: app.bundleId)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .alert(isPresented: $showSyncAlert) {
            Alert(
                title: Text(syncSuccess ? "Thành Công" : "Thông Báo"),
                message: Text(syncStatusMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
