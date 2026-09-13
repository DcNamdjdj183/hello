import SwiftUI

struct AppTarget: Identifiable {
    let id = UUID()
    let name: String
    let bundleId: String
    let iconName: String
}

let mockApps: [AppTarget] = [
    AppTarget(name: "Free Fire", bundleId: "com.dts.freefireth", iconName: "gamecontroller.fill"),
    AppTarget(name: "Free Fire MAX", bundleId: "com.dts.freefiremax", iconName: "gamecontroller.fill"),
    AppTarget(name: "PUBG Mobile", bundleId: "com.vng.pubgmobile", iconName: "gamecontroller.fill"),
    AppTarget(name: "Liên Quân Mobile", bundleId: "com.garena.game.kgvn", iconName: "gamecontroller.fill"),
    AppTarget(name: "CapCut", bundleId: "com.lemon.lvoverseas", iconName: "video.fill"),
    AppTarget(name: "Locket", bundleId: "com.locket.Locket", iconName: "camera.fill")
]

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var licenseManager: LicenseManager
    @EnvironmentObject private var patchDraftCoordinator: PatchDraftCoordinator
    @EnvironmentObject private var fileOperationCoordinator: FileOperationCoordinator

    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.1).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    DeviceInfoHeader(showSettings: $showSettings)
                        .padding(.top, 10)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
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
                Text("DELTA HACK VN")
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
                DeviceInfoItem(title: "Thiết Bị", value: "iPhone 11")
                Spacer()
                DeviceInfoItem(title: "Hệ Điều Hành", value: "iOS 18.0")
                Spacer()
                DeviceInfoItem(title: "RAM Trống", value: "871 MB / 4 GB")
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
            Image(systemName: app.iconName)
                .font(.system(size: 24))
                .foregroundColor(.cyan)
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            
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
    @State private var selectedTab = "Aimbot"
    
    let tabs = ["Proxy", "DNS", "Aimbot", "ESP"]
    
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
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTab == "DNS" {
                            MockSectionView(title: "CẤU HÌNH DNS", items: ["DNS AntiBan 4.0", "DNS AntiBan 5.0"])
                        } else if selectedTab == "Proxy" {
                            MockSectionView(title: "PROXY DELTA VIP", items: ["Proxy Rank", "Proxy Cày K/D", "Proxy Magic"])
                            MockSectionView(title: "PROXY DELTA VIP M2", items: ["Proxy An Toàn", "Proxy Bypass"])
                        } else if selectedTab == "Aimbot" {
                            MockSectionView(title: "AIMBOT & TỰ ĐỘNG", items: ["Aimbot VIP Mới Nhất", "Magic Bullet", "Headshot 100%"])
                        } else if selectedTab == "ESP" {
                            MockSectionView(title: "ESP (HIỂN THỊ)", items: ["ESP Box / Khung", "ESP Line / Tia", "ESP Name / Tên"])
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.bottom, 100) // Space for floating button
                }
            }
            
            // Bottom Floating Button
            VStack(spacing: 12) {
                Spacer()
                
                Text("Bản V1 - HỖ TRỢ TEST \(app.name) Khởi Chạy Sớm")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                
                Button(action: {
                    // MỞ GAME
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
            .padding(24)
        }
        .navigationBarHidden(true)
    }
    
    func iconForTab(_ tab: String) -> String {
        switch tab {
        case "Proxy": return "network"
        case "DNS": return "server.rack"
        case "Aimbot": return "scope"
        case "ESP": return "eye.fill"
        default: return "circle"
        }
    }
}

struct MockSectionView: View {
    let title: String
    let items: [String]
    
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
                    HStack(spacing: 16) {
                        Image(systemName: "shield.fill")
                            .foregroundColor(.cyan)
                            .font(.system(size: 24))
                            .frame(width: 40)
                        
                        Text(item)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 24))
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CustomSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var touchEnabled = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.1).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        SettingsRow(icon: "globe", title: "Ngôn Ngữ", subtitle: "English", hasArrow: true)
                        SettingsRow(icon: "arrow.triangle.2.circlepath", title: "Kiểm Tra Cập Nhật", subtitle: "Phiên bản mới nhất", hasArrow: true)
                        SettingsRow(icon: "trash", title: "Xoá Dữ Liệu Đệm", subtitle: "Làm nhẹ app", hasArrow: true)
                        SettingsRow(icon: "gearshape.2", title: "Khôi Phục Cài Đặt", subtitle: "Xoá mọi tuỳ chỉnh", hasArrow: true)
                        SettingsRow(icon: "info.circle", title: "Thông Tin Ứng Dụng", subtitle: "Phiên bản: 19.3", hasArrow: true)
                        
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
        }
        .preferredColorScheme(.dark)
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
