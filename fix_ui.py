import sys
with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('import SwiftUI\n', 'import SwiftUI\nimport SystemConfiguration\n')

old_layout = """                ScrollView {
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
        .navigationBarHidden(true)"""

new_layout = """                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTab == "DNS" {
                            DNSSectionView(title: "CẤU HÌNH DNS")
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
                }
                
                // Bottom Fixed Section (Not floating over content)
                VStack(spacing: 12) {
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
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(red: 0.07, green: 0.07, blue: 0.1).ignoresSafeArea(edges: .bottom))
            }
        }
        .navigationBarHidden(true)"""

if old_layout in text:
    text = text.replace(old_layout, new_layout)
    print('Layout updated')
else:
    print('Failed to find old layout')

dns_code = """
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
"""
if 'struct DNSSectionView' not in text:
    text += dns_code
    print('DNSSectionView appended')

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)
