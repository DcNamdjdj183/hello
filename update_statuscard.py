import sys

with open("ThreeOneOSFive/ContentView.swift", "r", encoding="utf-8") as f:
    text = f.read()

status_card_old = """            VStack(spacing: 14) {
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
            }"""

status_card_new = """            VStack(spacing: 14) {
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
                    Button(action: {
                        appState.runKernelExploitIfNeeded()
                    }) {
                        HStack {
                            Image(systemName: appState.exploitStatus.isSuccess ? "checkmark.shield.fill" : (appState.kernelExploitRunning ? "hourglass" : "shield.lefthalf.filled"))
                            Text(appState.exploitStatus.isSuccess ? "Exploit Active" : (appState.kernelExploitRunning ? "Injecting..." : "Initialize Exploit"))
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(appState.exploitStatus.isSuccess ? Color.green : (appState.kernelExploitRunning ? Color.gray : Color.blue))
                        .cornerRadius(12)
                    }
                    .disabled(appState.exploitStatus.isSuccess || appState.kernelExploitRunning)
                    .padding(.top, 8)
                }
            }"""

text = text.replace(status_card_old, status_card_new)

with open("ThreeOneOSFive/ContentView.swift", "w", encoding="utf-8") as f:
    f.write(text)
print("Updated ContentView.swift")
