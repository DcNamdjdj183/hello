import sys

path = 'ThreeOneOSFive/ContentView.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

old_dns = """struct DNSCard: View {
    @State private var dnsURL: URL?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DNS Profile")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
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
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
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
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("DNS Profile")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("Trạng thái: SAFE")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                Text("| Khu vực: GLOBAL")
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
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
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

# Must use ASCII characters to avoid swiftc failure again!
# "Trạng thái:" -> "Trang thai:"
# "Khu vực:" -> "Khu vuc:"
new_dns_ascii = new_dns.replace("Trạng thái:", "Trang thai:").replace("Khu vực:", "Khu vuc:")

text = text.replace(old_dns, new_dns_ascii)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated DNSCard')
