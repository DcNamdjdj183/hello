import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

pattern = r'(                  if appState\.isSupported \{\n                      HStack\(spacing: 12\) \{\n                          Button\(action: \{\n                              appState\.runKernelExploitIfNeeded\(\)\n                          \}\) \{\n                              HStack \{\n                                  Image\(systemName: appState\.exploitStatus\.isSuccess \? "checkmark\.shield\.fill" : \(appState\.kernelExploitRunning \? "hourglass" : "shield\.lefthalf\.filled"\)\)\n                                  Text\(appState\.exploitStatus\.isSuccess \? "Exploit Active" : \(appState\.kernelExploitRunning \? "Injecting\.\.\." : "Initialize Exploit"\)\)\n                              \}\n                              \.font\(\.system\(size: 14, weight: \.bold, design: \.rounded\)\)\n                              \.foregroundColor\(\.white\)\n                              \.frame\(maxWidth: \.infinity\)\n                              \.padding\(\)\n                              \.background\(appState\.exploitStatus\.isSuccess \? Color\.green : \(appState\.kernelExploitRunning \? Color\.gray : Color\.blue\)\)\n                              \.cornerRadius\(12\)\n                          \}\n                          \.disabled\(appState\.exploitStatus\.isSuccess \|\| appState\.kernelExploitRunning\)\n                          \n                          Button\(action: \{\n                              // Trigger sheet presentation instead of NavigationLink because we are not in a NavigationView\n                              NotificationCenter\.default\.post\(name: NSNotification\.Name\("ShowLogView"\), object: nil\)\n                          \}\) \{\n                              Image\(systemName: "doc\.text\.fill"\)\n                                  \.font\(\.system\(size: 18\)\)\n                                  \.foregroundColor\(\.white\)\n                                  \.frame\(width: 50, height: 50\)\n                                  \.background\(Color\.white\.opacity\(0\.1\)\)\n                                  \.cornerRadius\(12\)\n                          \}\n                      \}\n                      \.padding\(\.top, 8\)\n                  \})'

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
    print("Replaced via regex!")
else:
    print("Regex failed to match!")
