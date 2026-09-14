const fs = require('fs');

let text = fs.readFileSync('ThreeOneOSFive/ContentView.swift', 'utf8');

const target1 = `struct AppDetailView: View {
    let app: AppTarget
    @Environment(\\.presentationMode) var presentationMode
    @State private var selectedTab = "Chams"
    
    let tabs = ["Proxy", "DNS", "Chams", "ESP"]`;

const replace1 = `struct AppDetailView: View {
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

text = text.replace(target1, replace1);

const targetTabBar = `                // Custom Tab Bar
                HStack(spacing: 0) {
                    ForEach(tabs, id: \\.self) { tab in
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
                .padding(.bottom, 16)`;

const replaceTabBar = `                // Custom Tab Bar
                if !tabs.isEmpty {
                    HStack(spacing: 0) {
                        ForEach(tabs, id: \\.self) { tab in
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
                }`;

text = text.replace(targetTabBar, replaceTabBar);

const targetConditions = `                        if selectedTab == "DNS" {
                            DNSSectionView(title: "CẤU HÌNH DNS")
                        } else if selectedTab == "Proxy" {
                            InteractiveSectionView(title: "PROXY DELTA VIP", items: ["Proxy Rank", "Proxy Cày K/D", "Proxy Magic"])
                            InteractiveSectionView(title: "PROXY DELTA VIP M2", items: ["Proxy An Toàn", "Proxy Bypass"])
                        } else if selectedTab == "Chams" {
                            InteractiveSectionView(title: "CHAMS & TỰ ĐỘNG", items: ["Aimbot VIP Mới Nhất", "Magic Bullet", "Headshot 100%"])
                        } else if selectedTab == "ESP" {
                            InteractiveSectionView(title: "ESP (HIỂN THỊ)", items: ["ESP Box / Khung", "ESP Line / Tia", "ESP Name / Tên"])
                        }`;

const replaceConditions = `                        if tabs.isEmpty {
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

text = text.replace(targetConditions, replaceConditions);

fs.writeFileSync('ThreeOneOSFive/ContentView.swift', text, 'utf8');
console.log('UI updated completely.');
