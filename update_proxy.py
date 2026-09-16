import os
import re

cv_path = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\ContentView.swift'
folder_th = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\Patches\FREEFIRETH'

files = [f for f in os.listdir(folder_th) if f.endswith('.3105')]
proxy_files = [f for f in files if not f.lower().startswith('mod ')]

# Create the new items array for proxy section
proxy_items_str = ',\n                                '.join([f'"\\(folder)/{f}"' for f in sorted(proxy_files)])

with open(cv_path, 'r', encoding='utf-8') as f:
    text = f.read()

# The proxy section is between `InteractiveSectionView(title: "PATCHES (BẬT SẢNH)", items: [` and `], appBundleId: app.bundleId)`
pattern_proxy = r'(} else if selectedTab == "Proxy" \{\s+let folder = app.bundleId == "com.dts.freefiremax" \? "FREEFIREMAX" : "FREEFIRETH"\s+InteractiveSectionView\(title: "PATCHES \(BẬT SẢNH\)", items: \[).*?(\],\s*appBundleId: app.bundleId\))'
new_proxy_section = r'\1\n                                ' + proxy_items_str + r'\n                            \2'

text = re.sub(pattern_proxy, new_proxy_section, text, flags=re.DOTALL)

with open(cv_path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated ContentView.swift with new proxy patches.")
