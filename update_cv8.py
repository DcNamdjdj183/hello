import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

target = """            if appState.exploitStatus.isSuccess {
                Text("Active")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
            } else {
                Button(action: {
                    appState.runKernelExploitIfNeeded()
                }) {
                    Text("Kích Hoạt")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.cyan.opacity(0.2))
                        .foregroundColor(.cyan)
                        .cornerRadius(8)
                }
            }"""

rep = """            if appState.kernelExploitRunning {
                Text("Đang chạy...")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
            } else if appState.exploitStatus.isSuccess {
                Text("Active")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
            } else if appState.exploitStatus.isFailed {
                Text("Thất Bại")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
            } else {
                Text("Đang chờ...")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }"""

# The text might have some UTF-8 mangling in the terminal output, let's use regex instead of literal
regex_target = r'if appState\.exploitStatus\.isSuccess \{.*?Text\("Active"\).*?\} else \{.*?Button\(action: \{.*?appState\.runKernelExploitIfNeeded\(\).*?\}\)'
text = re.sub(regex_target, rep, text, flags=re.DOTALL)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated KernelStatusCard")
