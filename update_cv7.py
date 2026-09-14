import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()


# 1. Update KernelStatusCard and inject it below KeyStatusCard
kernel_status_card = """
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
            
            if appState.exploitStatus.isSuccess {
                Text("Active")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
            } else {
                Button(action: {
                    appState.runKernelExploit()
                }) {
                    Text("Kích Hoạt")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.cyan.opacity(0.2))
                        .foregroundColor(.cyan)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}
"""
text = text + kernel_status_card

# Add KernelStatusCard below KeyStatusCard
old_list = """                            KeyStatusCard()
                                .padding(.bottom, 8)
                            Text("QUẢN LÝ APP")"""
new_list = """                            KeyStatusCard()
                                .padding(.bottom, 8)
                            KernelStatusCard()
                                .padding(.bottom, 8)
                            Text("QUẢN LÝ APP")"""
text = text.replace(old_list, new_list)

# Make sure appState is available in ContentView
old_cv_env = """struct ContentView: View {
    @Environment(\\.scenePhase) private var scenePhase
    @EnvironmentObject private var licenseManager: LicenseManager
    @EnvironmentObject private var patchDraftCoordinator: PatchDraftCoordinator"""
new_cv_env = """struct ContentView: View {
    @Environment(\\.scenePhase) private var scenePhase
    @EnvironmentObject private var licenseManager: LicenseManager
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var patchDraftCoordinator: PatchDraftCoordinator"""
text = re.sub(r'struct ContentView: View \{\s*@Environment\(\\\.scenePhase\) private var scenePhase\s*@EnvironmentObject private var licenseManager: LicenseManager\s*@EnvironmentObject private var patchDraftCoordinator: PatchDraftCoordinator', new_cv_env, text)


# 2. Add Contact Info to CustomSettingsView
contact_info = """                        
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
"""
old_settings_list = """                        HStack {
                            Image(systemName: "hand.tap.fill")"""
new_settings_list = contact_info + "\n" + old_settings_list
text = text.replace(old_settings_list, new_settings_list)


# 3. Fix DeviceInfoHeader (OS and Free Storage)
old_device_info = """            HStack {
                DeviceInfoItem(title: "Thiết Bị", value: "iPhone 11")
                Spacer()
                DeviceInfoItem(title: "Hệ Điều Hành", value: "iOS 18.0")
                Spacer()
                DeviceInfoItem(title: "RAM Trống", value: "871 MB / 4 GB")
            }"""
new_device_info = """            HStack {
                DeviceInfoItem(title: "Thiết Bị", value: UIDevice.current.model)
                Spacer()
                DeviceInfoItem(title: "Hệ Điều Hành", value: "\\(UIDevice.current.systemName) \\(UIDevice.current.systemVersion)")
                Spacer()
                DeviceInfoItem(title: "Dung Lượng Trống", value: freeDiskSpace())
            }"""
text = text.replace(old_device_info, new_device_info)

free_disk_space_func = """
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
"""
text = text + free_disk_space_func


# 4. Open Game Button
old_open_btn = """                    Button(action: {
                        // MỞ GAME
                    }) {"""
new_open_btn = """                    Button(action: {
                        _ = openApplicationForBundleID(app.bundleId)
                    }) {"""
text = text.replace(old_open_btn, new_open_btn)


# 5. applyPatchFile and InteractiveRow changes
# Fix applyPatchFile signature and set TargetGameBundleID
old_apply = "func applyPatchFile(filename: String) {"
new_apply = """func applyPatchFile(filename: String, appBundleId: String) {
    UserDefaults.standard.set(appBundleId, forKey: "TargetGameBundleID")"""
text = text.replace(old_apply, new_apply)

# InteractiveRow
old_row = """struct InteractiveRow: View {
    let item: String
    @AppStorage var isEnabled: Bool
    
    init(item: String) {
        self.item = item
        self._isEnabled = AppStorage(wrappedValue: false, "Feature_\\(item)")
    }
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            isEnabled.toggle()
            if isEnabled {
                DispatchQueue.global(qos: .userInitiated).async {
                    applyPatchFile(filename: item)
                }
            }
        }) {"""
new_row = """struct InteractiveRow: View {
    let item: String
    let appBundleId: String
    @EnvironmentObject private var appState: AppState
    @AppStorage var isEnabled: Bool
    
    init(item: String, appBundleId: String) {
        self.item = item
        self.appBundleId = appBundleId
        self._isEnabled = AppStorage(wrappedValue: false, "Feature_\\(appBundleId)_\\(item)")
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
        }) {"""
text = text.replace(old_row, new_row)

# Append disabled modifier to InteractiveRow
old_row_end = """                Text((item.components(separatedBy: "/").last ?? item).replacingOccurrences(of: ".3105", with: ""))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isEnabled ? .green : .gray.opacity(0.5))
                    .font(.system(size: 22))
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
}"""
new_row_end = """                Text((item.components(separatedBy: "/").last ?? item).replacingOccurrences(of: ".3105", with: ""))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isEnabled ? .green : .gray.opacity(0.5))
                    .font(.system(size: 22))
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isEnabled ? Color.green.opacity(0.3) : Color.cyan.opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(!appState.exploitStatus.isSuccess)
        .opacity(appState.exploitStatus.isSuccess ? 1.0 : 0.5)
    }
}"""
text = text.replace(old_row_end, new_row_end)

# InteractiveSectionView
old_section = """struct InteractiveSectionView: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.cyan)
                .tracking(1)
            
            ForEach(items, id: \\.self) { item in
                InteractiveRow(item: item)
            }
        }
        .padding(.horizontal, 20)
    }
}"""
new_section = """struct InteractiveSectionView: View {
    let title: String
    let items: [String]
    let appBundleId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.cyan)
                .tracking(1)
            
            ForEach(items, id: \\.self) { item in
                InteractiveRow(item: item, appBundleId: appBundleId)
            }
        }
        .padding(.horizontal, 20)
    }
}"""
text = text.replace(old_section, new_section)

# Update AppDetailView calls
old_capcut_call = 'InteractiveSectionView(title: "CAPCUT PRO", items: ["CAPCUTPRO/CapcutPro.3105"])'
new_capcut_call = 'InteractiveSectionView(title: "CAPCUT PRO", items: ["CAPCUTPRO/CapcutPro.3105"], appBundleId: app.bundleId)'
text = text.replace(old_capcut_call, new_capcut_call)

old_proxy_call = """                            InteractiveSectionView(title: "PATCHES (BẬT SẢNH)", items: [
                                "\\(folder)/AIM BODY (BẬT SẢNH).3105",
                                "\\(folder)/AIM CHEST (BẬT SẢNH).3105",
                                "\\(folder)/AIM DRAG (BẬT SẢNH).3105",
                                "\\(folder)/AIM NECK (BẬT SẢNH).3105",
                                "\\(folder)/MAGIC BULLET (BẬT SẢNH).3105"
                            ])"""
new_proxy_call = """                            InteractiveSectionView(title: "PATCHES (BẬT SẢNH)", items: [
                                "\\(folder)/AIM BODY (BẬT SẢNH).3105",
                                "\\(folder)/AIM CHEST (BẬT SẢNH).3105",
                                "\\(folder)/AIM DRAG (BẬT SẢNH).3105",
                                "\\(folder)/AIM NECK (BẬT SẢNH).3105",
                                "\\(folder)/MAGIC BULLET (BẬT SẢNH).3105"
                            ], appBundleId: app.bundleId)"""
text = text.replace(old_proxy_call, new_proxy_call)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Applied massive fixes!")
