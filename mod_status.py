import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

old_status = """                  if appState.isSupported {
                      HStack(spacing: 12) {
                          Button(action: {
                              appState.runKernelExploitIfNeeded()
                          }) {
                              HStack {
                                  Image(systemName: appState.exploitStatus.isSuccess ? "checkmark.shield.fill" : (appState.kernelExploitRunning ? "hourglass" : "shield.lefthalf.filled"))
                                  Text(appState.exploitStatus.isSuccess ? "Exploit Active" : (appState.kernelExploitRunning ? "Injecting..." : "Initialize Exploit"))
                              }
                              .font(.system(size: 14, weight: .bold, design: .rounded))
                              .foregroundColor(.white)
                              .frame(maxWidth: .infinity)
                              .padding()
                              .background(appState.exploitStatus.isSuccess ? Color.green : (appState.kernelExploitRunning ? Color.gray : Color.blue))
                              .cornerRadius(12)
                          }
                          .disabled(appState.exploitStatus.isSuccess || appState.kernelExploitRunning)
                          
                          Button(action: {
                              // Trigger sheet presentation instead of NavigationLink because we are not in a NavigationView
                              NotificationCenter.default.post(name: NSNotification.Name("ShowLogView"), object: nil)
                          }) {
                              Image(systemName: "doc.text.fill")
                                  .font(.system(size: 18))
                                  .foregroundColor(.white)
                                  .frame(width: 50, height: 50)
                                  .background(Color.white.opacity(0.1))
                                  .cornerRadius(12)
                          }
                      }
                      .padding(.top, 8)
                  }"""

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

if old_status in text:
    text = text.replace(old_status, new_status)
    with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Replaced StatusCard buttons!")
else:
    print("Could not find exact StatusCard block.")
