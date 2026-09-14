import UIKit
import SwiftUI
import SystemConfiguration

struct AppTarget: Identifiable {
    let id = UUID()
    let name: String
    let bundleId: String
    let iconName: String
}

let mockApps: [AppTarget] = [
    AppTarget(name: "Free Fire", bundleId: "com.dts.freefireth", iconName: "icon_ffth"),
    AppTarget(name: "Free Fire MAX", bundleId: "com.dts.freefiremax", iconName: "icon_ffmax"),
    AppTarget(name: "PUBG Mobile", bundleId: "com.vng.pubgmobile", iconName: "icon_pubg"),
    AppTarget(name: "Liên Quân Mobile", bundleId: "com.garena.game.kgvn", iconName: "icon_lq"),
    AppTarget(name: "CapCut", bundleId: "com.lemon.lvoverseas", iconName: "icon_capcut"),

]

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var licenseManager: LicenseManager
    @EnvironmentObject private var patchDraftCoordinator: PatchDraftCoordinator
    @EnvironmentObject private var fileOperationCoordinator: FileOperationCoordinator

    @State private var showSettings = false
    
    var body: some View {
        Group {
            if !licenseManager.isActive {
                LicenseActivationView(manager: licenseManager)
            } else {
                mainContent
            }
        }
    }
    
    var mainContent: some View {
        NavigationView {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.1).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    DeviceInfoHeader(showSettings: $showSettings)
                        .padding(.top, 10)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            KeyStatusCard()
                                .padding(.bottom, 8)
                            KernelStatusCard()
                                .padding(.bottom, 8)
                            Text("QUẢN LÝ APP")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            
                            ForEach(mockApps) { app in
                                NavigationLink(destination: AppDetailView(app: app)) {
                                    AppCardView(app: app)
                                }
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showSettings) {
            CustomSettingsView()
        }
        .preferredColorScheme(.dark)
    }
}

struct DeviceInfoHeader: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("DNTWEAKS VN")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text("VIP 19.3")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color.white.opacity(0.05))
                        .clipShape(Circle())
                }
            }
            
            HStack {
                DeviceInfoItem(title: "Thiết Bị", value: UIDevice.current.model)
                Spacer()
                DeviceInfoItem(title: "Hệ Điều Hành", value: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
                Spacer()
                DeviceInfoItem(title: "Dung Lượng Trống", value: freeDiskSpace())
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }
}

struct DeviceInfoItem: View {
    let title: String
    let value: String
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct AppCardView: View {
    let app: AppTarget
    var body: some View {
        HStack(spacing: 16) {
            Image(app.iconName)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(app.bundleId)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("MỞ APP")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.cyan)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

struct AppDetailView: View {
    let app: AppTarget
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: String
    
    let tabs: [String]
    
    init(app: AppTarget) {
        self.app = app
        if app.name.contains("CapCut") {
            self.tabs = ["CapcutPro"]
            self._selectedTab = State(initialValue: "CapcutPro")
        } else if app.name.contains("Free Fire") {
            self.tabs = ["Proxy", "DNS", "MOD", "ESP"]
            self._selectedTab = State(initialValue: "Proxy")
        } else {
            self.tabs = []
            self._selectedTab = State(initialValue: "")
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.1).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                            Text("Back")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.cyan)
                    }
                    Spacer()
                    Text(app.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 70)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Top App Card
                AppCardView(app: app)
                    .padding(.bottom, 24)
                
                // Custom Tab Bar
                if !tabs.isEmpty {
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(action: { selectedTab = tab }) {
                            VStack(spacing: 12) {
                                Image(systemName: iconForTab(tab))
                                    .font(.system(size: 20))
                                Text(tab)
                                    .font(.system(size: 12, weight: .bold))
                                
                                Rectangle()
                                    .fill(selectedTab == tab ? Color.cyan : Color.clear)
                                    .frame(height: 3)
                                    .cornerRadius(1.5)
                            }
                            .foregroundColor(selectedTab == tab ? .cyan : .gray)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                }
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        if tabs.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Đang cập nhật!")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 60)
                        } else if selectedTab == "CapcutPro" {
                            InteractiveSectionView(title: "CAPCUT PRO", items: ["CAPCUTPRO/CapcutPro.3105"], appBundleId: app.bundleId)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Lưu ý: Sử dụng không login acc capcut.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)

                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                        } else if selectedTab == "DNS" {
                            DNSSectionView(title: "CẤU HÌNH DNS")
                        } else if selectedTab == "Proxy" {
                            let folder = app.bundleId == "com.dts.freefiremax" ? "FREEFIREMAX" : "FREEFIRETH"
                                                        InteractiveSectionView(title: "PATCHES (BẬT SẢNH)", items: [
                                "\(folder)/AIM BODY - bật sảnh -.3105",
                                "\(folder)/AIM DỊ TẬT - bật 40- --2.3105",
                                "\(folder)/AIM DRAG CÂN CHECK USP - bật 40- --2.3105",
                                "\(folder)/AIM HEAD - bật 40- --2.3105",
                                "\(folder)/AIM LOCK - bật 40- -.3105",
                                "\(folder)/AIM NECK - bật 40- -.3105",
                                "\(folder)/AIMHEAD CÂN CHECK KÈO TIỀN - BẬT NGOÀI GAME -.3105",
                                "\(folder)/AIMNECK CÂN CHECK KÈO TIỀN - BẬT NGOÀI GAME -.3105",
                                "\(folder)/ESP - AIMHEAD V2 - BẬT NGOÀI GAME -.3105",
                                "\(folder)/ESP - AIMNECK V1 - BẬT NGOÀI GAME -.3105"
                            ], appBundleId: app.bundleId)
                        } else if selectedTab == "MOD" {
                            let folder = app.bundleId == "com.dts.freefiremax" ? "FREEFIREMAX" : "FREEFIRETH"
                            InteractiveSectionView(title: "MOD", items: [
                                "\(folder)/Mod V10 - Alok -.3105",
                                "\(folder)/Mod V11 - Nairi -.3105",
                                "\(folder)/Mod V13 - Santino -.3105",
                                "\(folder)/Mod V14 - Ryden -.3105",
                                "\(folder)/Mod V16 - Ignis -.3105",
                                "\(folder)/Mod V17 - Alok -.3105",
                                "\(folder)/Mod V2 - Live -.3105",
                                "\(folder)/Mod V4 - Alok -.3105",
                                "\(folder)/Mod V5 - Alok -.3105",
                                "\(folder)/Mod V6 - Alok -.3105",
                                "\(folder)/Mod V7 - Alok -.3105",
                                "\(folder)/Mod V8 - Alok -.3105",
                                "\(folder)/Mod V9 - Alok -.3105"
                            ], appBundleId: app.bundleId)
                        } else if selectedTab == "ESP" {
                            VStack(spacing: 20) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Đang cập nhật!")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 60)
                        }
                    }
                    .padding(.vertical, 16)
                }
                
                // Bottom Fixed Section (Not floating over content)
                VStack(spacing: 12) {
                    Text("Bản V1 - HỖ TRỢ TEST \(app.name) Khởi Chạy Sớm")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        _ = openApplicationForBundleID(app.bundleId)
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16))
                            Text("MỞ GAME")
                                .font(.system(size: 16, weight: .black))
                        }
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.cyan.opacity(0.6), lineWidth: 1.5)
                        )
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(red: 0.07, green: 0.07, blue: 0.1).ignoresSafeArea(edges: .bottom))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(.all, edges: .top)
            .padding(.top, 44) // Fix Navigation Bar gap
        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
    }
    
    func iconForTab(_ tab: String) -> String {
        switch tab {
        case "Proxy": return "network"
        case "DNS": return "server.rack"
        case "Chams": return "person.fill.viewfinder"
        case "CapcutPro": return "star.fill"
        case "ESP": return "eye.fill"
        default: return "circle"
        }
    }
}

struct InteractiveSectionView: View {
    let title: String
    let items: [String]
    let appBundleId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Rectangle()
                    .fill(Color.cyan)
                    .frame(width: 3, height: 16)
                    .cornerRadius(1.5)
                
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ForEach(items, id: \.self) { item in
                    InteractiveRow(item: item, appBundleId: appBundleId)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}


func applyPatchFile(filename: String, appBundleId: String) {
    UserDefaults.standard.set(appBundleId, forKey: "TargetGameBundleID")
    guard let resourcePath = Bundle.main.resourcePath else { return }
    let patchesPath = resourcePath + "/Patches"
    let fm = FileManager.default
    if let enumerator = fm.enumerator(atPath: patchesPath) {
        for case let file as String in enumerator {
            if file.hasSuffix(filename) {
                let fullPath = patchesPath + "/" + file
                if let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)) {
                    let passes = ["3105", "Tele@YaPaor", "dntweaks", ""]
                    for pass in passes {
                        if let decoded = try? PatchPackageCodec.decode(data, password: pass.isEmpty ? nil : pass) {
                            _ = try? DevicePatchService.apply(project: decoded.project)
                            return
                        }
                    }
                }
                break
            }
        }
    }
}

struct InteractiveRow: View {
    let item: String
    let appBundleId: String
    @EnvironmentObject private var appState: AppState
    @AppStorage var isEnabled: Bool
    
    init(item: String, appBundleId: String) {
        self.item = item
        self.appBundleId = appBundleId
        self._isEnabled = AppStorage(wrappedValue: false, "Feature_\(appBundleId)_\(item)")
    }
    
    var body: some View {
        Button(action: {
            guard appState.exploitStatus.isSuccess else { return }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            isEnabled.toggle()
            if isEnabled {
                DispatchQueue.global(qos: .userInitiated).async {
                    applyPatchFile(filename: item, appBundleId: appBundleId)
                }
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: "shield.fill")
                    .foregroundColor(.cyan)
                    .font(.system(size: 24))
                    .frame(width: 40)
                
                Text((item.components(separatedBy: "/").last ?? item).replacingOccurrences(of: ".3105", with: ""))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isEnabled ? .green : .gray.opacity(0.5))
                    .font(.system(size: 24))
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isEnabled ? Color.green.opacity(0.3) : Color.cyan.opacity(0.2), lineWidth: 1)
            )
        }
    }
}


struct CustomSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var licenseManager: LicenseManager
    @AppStorage("AppTouchPointerEnabled") private var touchEnabled = true
    @State private var showLanguageAlert = false
    @State private var showUpdateAlert = false
    @State private var showInfoAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.1).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        Button(action: { showLanguageAlert = true }) {
                            SettingsRow(icon: "globe", title: "Ngôn Ngữ", subtitle: "English", hasArrow: true)
                        }
                        
                        Button(action: { showUpdateAlert = true }) {
                            SettingsRow(icon: "arrow.triangle.2.circlepath", title: "Kiểm Tra Cập Nhật", subtitle: "Phiên bản mới nhất", hasArrow: true)
                        }
                        
                        Button(action: { clearCache() }) {
                            SettingsRow(icon: "trash", title: "Xoá Dữ Liệu Đệm", subtitle: "Làm nhẹ app", hasArrow: true)
                        }
                        
                        Button(action: { resetSettings() }) {
                            SettingsRow(icon: "gearshape.2", title: "Khôi Phục Cài Đặt", subtitle: "Khởi động lại app & Xoá tuỳ chỉnh", hasArrow: true)
                        }
                        
                        Button(action: { showInfoAlert = true }) {
                            SettingsRow(icon: "info.circle", title: "Thông Tin Ứng Dụng", subtitle: "Phiên bản: 19.3", hasArrow: true)
                        }
                        
                        Button(action: {
                            licenseManager.deactivate()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Đăng Xuất", subtitle: "Thay đổi Key", hasArrow: false)
                        }
                        
                        
                        HStack {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .foregroundColor(.cyan)
                                .font(.system(size: 20))
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Liên Hệ Admin")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15, weight: .bold))
                                Text("http://zalo.me/0395109314")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                            Spacer()
                            Button(action: {
                                if let url = URL(string: "http://zalo.me/0395109314") { UIApplication.shared.open(url) }
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                        }
                        
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.cyan)
                                .font(.system(size: 20))
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Nhóm Thông Báo")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15, weight: .bold))
                                Text("Cộng đồng cập nhật")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                            Spacer()
                            Button(action: {
                                if let url = URL(string: "https://zalo.me/g/miuatq2xhhh0tarsc3me") { UIApplication.shared.open(url) }
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                        }

                        HStack {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(.cyan)
                                .font(.system(size: 20))
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Chạm Màn Hình")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15, weight: .bold))
                                Text("Hiển thị con trỏ")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $touchEnabled)
                                .labelsHidden()
                                .tint(.cyan)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Cài Đặt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(.cyan)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .alert("Ngôn ngữ (Language)", isPresented: $showLanguageAlert) {
                Button("Mở Cài đặt iOS") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Hủy", role: .cancel) {}
            }
            .alert("Kiểm tra cập nhật", isPresented: $showUpdateAlert) {
                Button("Mở trang chủ") {
                    if let url = URL(string: "https://github.com/DcNamdjdj183/hello") {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Hủy", role: .cancel) {}
            } message: { Text("Bạn đang dùng phiên bản DNTWEAKS VN mới nhất.") }
            .alert("Thông tin", isPresented: $showInfoAlert) {
                Button("Đóng", role: .cancel) {}
            } message: { Text("DNTWEAKS VN\nPhiên bản VIP 19.3\nĐội ngũ phát triển: DNTweaks Team") }
        }
        .preferredColorScheme(.dark)
    }
    
    private func clearCache() {
        let temp = FileManager.default.temporaryDirectory
        if let items = try? FileManager.default.contentsOfDirectory(at: temp, includingPropertiesForKeys: nil) {
            for item in items {
                try? FileManager.default.removeItem(at: item)
            }
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func resetSettings() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
}


struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let hasArrow: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 20))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .bold))
                Text(subtitle)
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
            
            Spacer()
            
            if hasArrow {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
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
                    .frame(width: 3, height: 16)
                    .cornerRadius(1.5)
                
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            // DNS 4.0 Action
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
                        Text(isVPNActive ? "Đang hoạt động (VPN Bật)" : "Bấm để cài & bật")
                            .font(.system(size: 10))
                            .foregroundColor(isVPNActive ? .green : .gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isVPNActive ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isVPNActive ? .green : .gray.opacity(0.5))
                        .font(.system(size: 24))
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isVPNActive ? Color.green.opacity(0.3) : Color.cyan.opacity(0.2), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
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
            checkVPNStatus()
        }
        .onReceive(Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()) { _ in
            checkVPNStatus()
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

struct KeyStatusCard: View {
    @EnvironmentObject private var licenseManager: LicenseManager
    var body: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(.purple)
            Text("Thời gian sử dụng:")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Text(formattedTime)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(licenseManager.remainingSeconds < 3600 ? .red : .green)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
    
    var formattedTime: String {
        let h = licenseManager.remainingSeconds / 3600
        let m = (licenseManager.remainingSeconds % 3600) / 60
        let s = licenseManager.remainingSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

struct KernelStatusCard: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        HStack {
            Image(systemName: "cpu")
                .foregroundColor(appState.exploitStatus.isSuccess ? .green : .red)
            Text("Kernel Exploit:")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            
            if appState.kernelExploitRunning {
                Text("Đang chạy...")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
            } else if appState.exploitStatus.isSuccess {
                Text("Active")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
            } else if appState.exploitStatus.isFailed {
                Text("Thất bại")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
            } else {
                Text("Đang chờ...")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}

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
