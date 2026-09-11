import sys

path = 'ThreeOneOSFive/ContentView.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

old_home = """                            VideoCard()
                            DNSCard()
                            LaunchCard(showCleaner: $showCleaner, onLaunch: openGame)"""

new_home = """                            VideoCard()
                            DNSCard()
                            CommunityCard()
                            LaunchCard(showCleaner: $showCleaner, onLaunch: openGame)"""

text = text.replace(old_home, new_home)

community_card = """
struct CommunityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Community & Support")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Link(destination: URL(string: "https://zalo.me/g/miuatq2xhhh0tarsc3me")!) {
                HStack {
                    Image(systemName: "bell.badge.fill")
                    Text("Cộng đồng thông báo cập nhật")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            Link(destination: URL(string: "http://zalo.me/0395109314")!) {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Zalo Admin")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.purple)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
    }
}
"""

if 'struct CommunityCard' not in text:
    text += community_card

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Added CommunityCard to Home Tab')
