import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# We'll just extract the whole block by index
start_idx = text.find('                if appState.isSupported {\n')
end_idx = text.find('                }\n            }\n        }\n        .padding(24)')

if start_idx != -1 and end_idx != -1:
    block = text[start_idx:end_idx + 17]
    
    new_status = """                if appState.isSupported {
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
        .padding(24)"""
    text = text[:start_idx] + new_status + text[end_idx + 17:]
    
    with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Replaced successfully via index!")
else:
    print(f"Could not find exact start or end. Start: {start_idx}, End: {end_idx}")
    
