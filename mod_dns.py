import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace DNSCard
old_dns = """struct DNSCard: View {
    @State private var dnsURL: URL?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("DNS Profile")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("Trang thai: SAFE")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                Text("| Khu vuc: GLOBAL")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)
            }
            
            Button(action: {
                if let url = dnsURL {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "network")
                    Text("Install DNS Profile")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(dnsURL == nil)
            .opacity(dnsURL == nil ? 0.5 : 1)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
        .onAppear {
            dnsURL = Bundle.main.urls(forResourcesWithExtension: "mobileconfig", subdirectory: "dns")?.first
        }
    }
}"""

new_dns = """struct DNSCard: View {
    @State private var dnsURL: URL?
    @ObservedObject private var server = ProfileServer.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("DNS Profile")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("Trang thai: SAFE")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                Text("| Khu vuc: GLOBAL")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)
            }
            
            Button(action: {
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
            }) {
                HStack {
                    Image(systemName: "network")
                    Text("Install DNS Profile")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(dnsURL == nil)
            .opacity(dnsURL == nil ? 0.5 : 1)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
        .onAppear {
            let fm = FileManager.default
            if let bundlePath = Bundle.main.resourcePath {
                let dnsPath = bundlePath + "/dns"
                if let files = try? fm.contentsOfDirectory(atPath: dnsPath) {
                    if let profile = files.first(where: { $0.hasSuffix(".mobileconfig") }) {
                        dnsURL = URL(fileURLWithPath: dnsPath + "/" + profile)
                        // Start server preemptively if possible
                        server.startServer(with: dnsURL!)
                    }
                }
            }
        }
    }
}"""

if old_dns in text:
    text = text.replace(old_dns, new_dns)
    with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Replaced DNSCard successfully!")
else:
    print("Could not find exact DNSCard string. Applying via regex...")
    pattern = r'struct DNSCard: View \{[\s\S]*?Bundle\.main\.urls\(forResourcesWithExtension: "mobileconfig", subdirectory: "dns"\)\?\.first\n        \}\n    \}\n\}'
    match = re.search(pattern, text)
    if match:
        text = text[:match.start()] + new_dns + text[match.end():]
        with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
            f.write(text)
        print("Replaced via regex!")
    else:
        print("Regex match failed too.")
