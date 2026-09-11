import sys

path = 'ThreeOneOSFive/ContentView.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('@EnvironmentObject private var appState: AppState', '@EnvironmentObject private var appState: AppState\n    @EnvironmentObject private var licenseManager: LicenseManager')
text = text.replace('Text("OGIOS")\n                            .font(.system(size: 32', 'Text("DNXTWEAKS")\n                            .font(.system(size: 32')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

path2 = 'ThreeOneOSFive/App.swift'
with open(path2, 'r', encoding='utf-8') as f:
    text2 = f.read()
text2 = text2.replace('OGIOS launching', 'DNXTWEAKS launching')
with open(path2, 'w', encoding='utf-8') as f:
    f.write(text2)

print('Patched successfully')
