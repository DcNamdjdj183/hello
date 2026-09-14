const fs = require('fs');
let text = fs.readFileSync('ThreeOneOSFive/ContentView.swift', 'utf8');

// 1. Fix AppDetailView layout (sập khung)
text = text.replace('VStack(spacing: 0) {', 'VStack(spacing: 0) {\n                Spacer().frame(height: 0) // Anchor top');
text = text.replace('ScrollView {\n                    VStack(spacing: 16) {', 'ScrollView {\n                    VStack(spacing: 16) {');
text = text.replace('.background(Color(red: 0.07, green: 0.07, blue: 0.1).ignoresSafeArea(edges: .bottom))', '.background(Color(red: 0.07, green: 0.07, blue: 0.1).ignoresSafeArea(edges: .bottom))\n            }\n            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)');
text = text.replace('            }\n            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)\n        }\n        .navigationBarHidden(true)', '            }\n            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)\n        }\n        .navigationBarHidden(true)');

// Fix the exact replacement:
// Wait, a better way to fix the frame is to add `.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)` to the `VStack(spacing: 0)`.
let appDetailRegex = /VStack\(spacing: 0\) \{([\s\S]*?\.background\(Color\(red: 0\.07, green: 0\.07, blue: 0\.1\)\.ignoresSafeArea\(edges: \.bottom\)\))\n            \}/;
let match = text.match(appDetailRegex);
if (match) {
    text = text.replace(appDetailRegex, 'VStack(spacing: 0) {$1\n            }\n            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)');
}

// 2. Modify tabs initialization
const old_appdetail_start = `struct AppDetailView: View {
    let app: AppTarget
    @Environment(\\.presentationMode) var presentationMode
    @State private var selectedTab: String
    
    let tabs: [String]
    
    init(app: AppTarget) {
        self.app = app
        if app.name.contains("CapCut") {
            self.tabs = ["CapcutPro"]
            self._selectedTab = State(initialValue: "CapcutPro")
        } else {
            self.tabs = ["Proxy", "DNS", "Chams", "ESP"]
            self._selectedTab = State(initialValue: "Chams")
        }
    }`;

const new_appdetail_start = `struct AppDetailView: View {
    let app: AppTarget
    @Environment(\\.presentationMode) var presentationMode
    @State private var selectedTab: String
    
    let tabs: [String]
    
    init(app: AppTarget) {
        self.app = app
        if app.name.contains("CapCut") {
            self.tabs = ["CapcutPro"]
            self._selectedTab = State(initialValue: "CapcutPro")
        } else if app.name.contains("Free Fire") {
            self.tabs = ["Proxy", "DNS", "Chams", "ESP"]
            self._selectedTab = State(initialValue: "Proxy")
        } else {
            self.tabs = []
            self._selectedTab = State(initialValue: "")
        }
    }`;
text = text.replace(old_appdetail_start, new_appdetail_start);

// 3. Update conditions in ScrollView
const old_conditions = `                        if selectedTab == "CapcutPro" {
                            InteractiveSectionView(title: "CAPCUT PRO", items: ["Mở Khóa Pro (Xoá Logo)", "Mở Khóa Hiệu Ứng VIP", "Xuất Video 4K 60FPS"])
                        } else if selectedTab == "DNS" {
                            DNSSectionView(title: "CẤU HÌNH DNS")
                        } else if selectedTab == "Proxy" {
                            InteractiveSectionView(title: "PROXY DELTA VIP", items: ["Proxy Rank", "Proxy Cày K/D", "Proxy Magic"])
                            InteractiveSectionView(title: "PROXY DELTA VIP M2", items: ["Proxy An Toàn", "Proxy Bypass"])
                        } else if selectedTab == "Chams" {
                            InteractiveSectionView(title: "CHAMS & TỰ ĐỘNG", items: ["Aimbot VIP Mới Nhất", "Magic Bullet", "Headshot 100%"])
                        } else if selectedTab == "ESP" {
                            InteractiveSectionView(title: "ESP (HIỂN THỊ)", items: ["ESP Box / Khung", "ESP Line / Tia", "ESP Name / Tên"])
                        }`;

const new_conditions = `                        if tabs.isEmpty {
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
                            InteractiveSectionView(title: "CAPCUT PRO", items: ["CapcutPro.3105"])
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Lưu ý: Sử dụng không login acc capcut.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                                Text("Pass patches: 3105")
                                    .font(.system(size: 12))
                                    .foregroundColor(.cyan)
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                        } else if selectedTab == "DNS" {
                            DNSSectionView(title: "CẤU HÌNH DNS")
                        } else if selectedTab == "Proxy" {
                            InteractiveSectionView(title: "PATCHES (BẬT SẢNH)", items: [
                                "AIM BODY (BẬT SẢNH).3105",
                                "AIM CHEST (BẬT SẢNH).3105",
                                "AIM DRAG (BẬT SẢNH).3105",
                                "AIM NECK (BẬT SẢNH).3105",
                                "MAGIC BULLET (BẬT SẢNH).3105"
                            ])
                        } else if selectedTab == "Chams" || selectedTab == "ESP" {
                            VStack(spacing: 20) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Đang cập nhật!")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 60)
                        }`;
text = text.replace(old_conditions, new_conditions);

// 4. Also hide the custom tab bar if tabs is empty
const old_tab_bar = `                // Custom Tab Bar
                HStack(spacing: 0) {
                    ForEach(tabs, id: \\.self) { tab in`;
const new_tab_bar = `                // Custom Tab Bar
                if !tabs.isEmpty {
                HStack(spacing: 0) {
                    ForEach(tabs, id: \\.self) { tab in`;
const old_tab_bar_end = `                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)`;
const new_tab_bar_end = `                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                }`;

text = text.replace(old_tab_bar, new_tab_bar);
text = text.replace(old_tab_bar_end, new_tab_bar_end);

fs.writeFileSync('ThreeOneOSFive/ContentView.swift', text, 'utf8');
console.log('UI updated for tabs, patches, and layout.');
