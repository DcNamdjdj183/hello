const fs = require('fs');

let text = fs.readFileSync('ThreeOneOSFive/ContentView.swift', 'utf8');

// Rename Aimbot to Chams
text = text.replace('selectedTab = "Aimbot"', 'selectedTab = "Chams"');
text = text.replace('["Proxy", "DNS", "Aimbot", "ESP"]', '["Proxy", "DNS", "Chams", "ESP"]');
text = text.replace('selectedTab == "Aimbot"', 'selectedTab == "Chams"');
text = text.replace('case "Aimbot": return "scope"', 'case "Chams": return "person.fill.viewfinder"');
text = text.replace('AIMBOT & TỰ ĐỘNG', 'CHAMS & TỰ ĐỘNG');

// Rename DELTA HACK VN
text = text.replace('DELTA HACK VN', 'DNTWEAKS VN');

// Replace MockSectionView entirely with InteractiveSectionView
const interactive_section = `struct InteractiveSectionView: View {
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
                ForEach(items, id: \\.self) { item in
                    InteractiveRow(item: item)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct InteractiveRow: View {
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
        }) {
            HStack(spacing: 16) {
                Image(systemName: "shield.fill")
                    .foregroundColor(.cyan)
                    .font(.system(size: 24))
                    .frame(width: 40)
                
                Text(item)
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
}`;

text = text.replace(/struct MockSectionView: View \{[\s\S]*?(?=\nstruct CustomSettingsView: View)/, interactive_section + '\n\n');
text = text.replace(/MockSectionView\(/g, 'InteractiveSectionView(');

const new_settings = `struct CustomSettingsView: View {
    @Environment(\\.presentationMode) var presentationMode
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
            } message: { Text("DNTWEAKS VN\\nPhiên bản VIP 19.3\\nĐội ngũ phát triển: DNTweaks Team") }
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
}`;

text = text.replace(/struct CustomSettingsView: View \{[\s\S]*?(?=\nstruct SettingsRow: View)/, new_settings + '\n\n');

fs.writeFileSync('ThreeOneOSFive/ContentView.swift', text, 'utf8');
console.log('Update complete.');
