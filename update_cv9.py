with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

start_marker = "            if appState.exploitStatus.isSuccess {"
end_marker = "                        .cornerRadius(8)\n                }\n            }"

start_idx = text.find(start_marker)
end_idx = text.find(end_marker, start_idx) + len(end_marker)

rep = """            if appState.kernelExploitRunning {
                Text("Đang chạy...")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
            } else if appState.exploitStatus.isSuccess {
                Text("Active")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
            } else if appState.exploitStatus.isFailed {
                Text("Thất bại")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
            } else {
                Text("Đang chờ...")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }"""

if start_idx != -1 and text.find(end_marker, start_idx) != -1:
    text = text[:start_idx] + rep + text[end_idx:]
    with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Fixed KernelStatusCard")
else:
    print("Could not find markers")
