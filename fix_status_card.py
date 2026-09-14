import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

start_str = "struct StatusCard: View {"
end_str = "struct InfoRow: View {"

start_idx = text.find(start_str)
end_idx = text.find(end_str)

if start_idx != -1 and end_idx != -1:
    correct_status_card = """struct StatusCard: View {
    @ObservedObject var appState: AppState
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "iphone.gen3")
                    .font(.system(size: 22))
                    .foregroundColor(.purple)
                Text("Device Identity")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 14) {
                InfoRow(title: "OS Version", value: AppInfo.osVersion)
                InfoRow(title: "Hardware", value: AppInfo.displayMachineName)
                HStack {
                    Text("Kernel Support")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(appState.isSupported ? "Supported" : "Unsupported")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(appState.isSupported ? .green : .red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(appState.isSupported ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                        .clipShape(Capsule())
                }
                
                if appState.isSupported {
                    HStack {
                        Text("Exploit Status")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(appState.exploitStatus.isSuccess ? "Active" : (appState.kernelExploitRunning ? "Injecting..." : "Waiting"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(appState.exploitStatus.isSuccess ? .green : (appState.kernelExploitRunning ? .yellow : .orange))
                    }
                    
                    Button(action: {
                        NotificationCenter.default.post(name: NSNotification.Name("ShowLogView"), object: nil)
                    }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("View Session Logs")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(24)
        .background(Color.black.opacity(0.3))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
    }
}

"""

    text = text[:start_idx] + correct_status_card + text[end_idx:]
    with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Fixed StatusCard!")
else:
    print("Could not find start or end bounds.")
