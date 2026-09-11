import sys

path = 'ThreeOneOSFive/ContentView.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Insert KeyStatusCard below StatusCard
text = text.replace('StatusCard(appState: appState)', 
'''StatusCard(appState: appState)
                            KeyStatusCard(remainingSeconds: licenseManager.remainingSeconds)''')

# Append KeyStatusCard struct at the bottom
card_code = '''
struct KeyStatusCard: View {
    let remainingSeconds: Int
    var body: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(.purple)
            Text("License Time Remaining:")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            Text(formattedTime)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(remainingSeconds < 3600 ? .red : .green)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
    }
    
    var formattedTime: String {
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
'''
text = text + card_code

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print('Added KeyStatusCard')
