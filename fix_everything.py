import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Fix Frame
# Find: VStack(spacing: 0) { ... \n            }\n        }\n        .navigationBarHidden(true)
# To avoid complex regex, I will just insert the layout modifier directly.
text = text.replace('                ScrollView {\n                    VStack(spacing: 16) {', '                Spacer().frame(height: 0)\n                ScrollView {\n                    VStack(spacing: 16) {')

text = text.replace('                .background(Color(red: 0.07, green: 0.07, blue: 0.1).ignoresSafeArea(edges: .bottom))\n            }\n        }\n        .navigationBarHidden(true)', '                .background(Color(red: 0.07, green: 0.07, blue: 0.1).ignoresSafeArea(edges: .bottom))\n            }\n            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)\n        }\n        .navigationBarHidden(true)')

# 2. Tabs logic
target_appdetail = """struct AppDetailView: View {
    let app: AppTarget
    @Environment(\\.presentationMode) var presentationMode
    @State private var selectedTab = "Chams"
    
    let tabs = ["Proxy", "DNS", "Chams", "ESP"]"""

replace_appdetail = """struct AppDetailView: View {
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
    }"""

text = text.replace(target_appdetail, replace_appdetail)

# 3. Tab Bar UI
target_tabbar = """                // Custom Tab Bar
                HStack(spacing: 0) {
                    ForEach(tabs, id: \\.self) { tab in"""

replace_tabbar = """                // Custom Tab Bar
                if !tabs.isEmpty {
                HStack(spacing: 0) {
                    ForEach(tabs, id: \\.self) { tab in"""

text = text.replace(target_tabbar, replace_tabbar)

target_tabbar_end = """                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)"""

replace_tabbar_end = """                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                }"""

text = text.replace(target_tabbar_end, replace_tabbar_end)

# 4. Conditions
target_conditions = """                        if selectedTab == "DNS" {
                            DNSSectionView(title: "CẤU HÌNH DNS")
                        } else if selectedTab == "Proxy" {
                            InteractiveSectionView(title: "PROXY DELTA VIP", items: ["Proxy Rank", "Proxy Cày K/D", "Proxy Magic"])
                            InteractiveSectionView(title: "PROXY DELTA VIP M2", items: ["Proxy An Toàn", "Proxy Bypass"])
                        } else if selectedTab == "Chams" {
                            InteractiveSectionView(title: "CHAMS & TỰ ĐỘNG", items: ["Aimbot VIP Mới Nhất", "Magic Bullet", "Headshot 100%"])
                        } else if selectedTab == "ESP" {
                            InteractiveSectionView(title: "ESP (HIỂN THỊ)", items: ["ESP Box / Khung", "ESP Line / Tia", "ESP Name / Tên"])
                        }"""

replace_conditions = """                        if tabs.isEmpty {
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
                        }"""

text = text.replace(target_conditions, replace_conditions)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)
print("Updated ContentView using Python")
