import os
import re

folder_path = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\Patches\FREEFIRETH'
files = [f for f in os.listdir(folder_path) if f.endswith('.3105')]

mod_files = []
proxy_files = []

for f in files:
    if f.lower().startswith('mod '):
        mod_files.append(f)
    else:
        proxy_files.append(f)

# Deduplicate proxy files
deduped_proxy_files = []
seen_bases = set()

for f in sorted(proxy_files):
    # Base name: remove trailing things like "--2.3105" or "-.3105" or ".3105"
    base = re.sub(r'\s*-+2?\.3105$', '', f)
    base = re.sub(r'\.3105$', '', base)
    if base not in seen_bases:
        seen_bases.add(base)
        deduped_proxy_files.append(f)

print("MOD files:", len(mod_files))
print("Proxy files deduplicated:", len(deduped_proxy_files))

mod_items_str = ',\n                                '.join([f'"\\(folder)/{f}"' for f in sorted(mod_files)])
proxy_items_str = ',\n                                '.join([f'"\\(folder)/{f}"' for f in sorted(deduped_proxy_files)])

cv_path = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\ContentView.swift'
with open(cv_path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Update the tabs array in AppDetailView
text = text.replace('self.tabs = ["Proxy", "DNS", "Chams", "ESP"]', 'self.tabs = ["Proxy", "DNS", "MOD", "ESP"]')

# 2. Update Proxy Section
pattern_proxy = r'(} else if selectedTab == "Proxy" \{\s+let folder = app.bundleId == "com.dts.freefiremax" \? "FREEFIREMAX" : "FREEFIRETH"\s+InteractiveSectionView\(title: "PATCHES \(BẬT SẢNH\)", items: \[).*?(\],\s*appBundleId: app.bundleId\))'
new_proxy_section = r'\1\n                                ' + proxy_items_str + r'\n                            \2'
text = re.sub(pattern_proxy, new_proxy_section, text, flags=re.DOTALL)

# 3. Update the Chams/ESP section to include MOD, and separate MOD
# Find: } else if selectedTab == "Chams" || selectedTab == "ESP" {
# Replace with:
# } else if selectedTab == "MOD" {
#     let folder = app.bundleId == "com.dts.freefiremax" ? "FREEFIREMAX" : "FREEFIRETH"
#     InteractiveSectionView(title: "MOD TỰ ĐỘNG", items: [ ... ], appBundleId: app.bundleId)
# } else if selectedTab == "Chams" || selectedTab == "ESP" {
mod_block = f"""}} else if selectedTab == "MOD" {{
                            let folder = app.bundleId == "com.dts.freefiremax" ? "FREEFIREMAX" : "FREEFIRETH"
                            InteractiveSectionView(title: "MOD", items: [
                                {mod_items_str}
                            ], appBundleId: app.bundleId)
                        }} else if selectedTab == "ESP" {{"""

text = text.replace('} else if selectedTab == "Chams" || selectedTab == "ESP" {', mod_block)
text = text.replace('} else if selectedTab == "Chams" || selectedTab == "ESP" || selectedTab == "MOD" {', mod_block) # Just in case

with open(cv_path, 'w', encoding='utf-8') as f:
    f.write(text)

print("ContentView updated successfully.")
