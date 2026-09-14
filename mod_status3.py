import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

pattern = r'(                  if appState\.isSupported \{\n                      HStack\(spacing: 12\) \{[\s\S]*?\n                      \}\n                      \.padding\(\.top, 8\)\n                  \})'

new_status = """                  if appState.isSupported {
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
                  }"""

if re.search(pattern, text):
    text = re.sub(pattern, new_status, text)
    with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Replaced via generic regex!")
else:
    print("Generic regex failed to match!")
