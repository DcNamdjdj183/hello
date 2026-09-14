const fs = require('fs');
let text = fs.readFileSync('ThreeOneOSFive/ContentView.swift', 'utf8');

// Fix Liên Quân encoding and remove Locket
text = text.replace('LiAn QuAn Mobile', 'Liên Quân Mobile');
text = text.replace('LiAn QuAn Mobile', 'Liên Quân Mobile');
text = text.replace(/\n\s*AppTarget\(name: "Locket", bundleId: "com\.locket\.Locket", iconName: "camera\.fill"\)/, '');
// For cases where there's a comma
text = text.replace(/,\n\s*AppTarget\(name: "Locket", bundleId: "com\.locket\.Locket", iconName: "camera\.fill"\)/, '');

// Update AppDetailView tabs
const old_appdetail_start = `struct AppDetailView: View {
    let app: AppTarget
    @Environment(\\.presentationMode) var presentationMode
    @State private var selectedTab = "Chams"
    
    let tabs = ["Proxy", "DNS", "Chams", "ESP"]`;

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
        } else {
            self.tabs = ["Proxy", "DNS", "Chams", "ESP"]
            self._selectedTab = State(initialValue: "Chams")
        }
    }`;

text = text.replace(old_appdetail_start, new_appdetail_start);

// Update iconForTab
text = text.replace('case "Chams": return "person.fill.viewfinder"', 'case "Chams": return "person.fill.viewfinder"\n        case "CapcutPro": return "star.fill"');

// Update selectedTab conditions
const old_conditions = `                        if selectedTab == "DNS" {
                            DNSSectionView(title: "CẤU HÌNH DNS")
                        } else if selectedTab == "Proxy" {
                            InteractiveSectionView(title: "PROXY DELTA VIP", items: ["Proxy Rank", "Proxy Cày K/D", "Proxy Magic"])
                            InteractiveSectionView(title: "PROXY DELTA VIP M2", items: ["Proxy An Toàn", "Proxy Bypass"])
                        } else if selectedTab == "Chams" {
                            InteractiveSectionView(title: "CHAMS & TỰ ĐỘNG", items: ["Aimbot VIP Mới Nhất", "Magic Bullet", "Headshot 100%"])
                        } else if selectedTab == "ESP" {
                            InteractiveSectionView(title: "ESP (HIỂN THỊ)", items: ["ESP Box / Khung", "ESP Line / Tia", "ESP Name / Tên"])
                        }`;

const new_conditions = `                        if selectedTab == "CapcutPro" {
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

text = text.replace(old_conditions, new_conditions);

fs.writeFileSync('ThreeOneOSFive/ContentView.swift', text, 'utf8');
console.log('Successfully updated AppDetailView tabs and Capcut settings');
