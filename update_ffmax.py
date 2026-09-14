import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Update Capcut item
text = text.replace('InteractiveSectionView(title: "CAPCUT PRO", items: ["CapcutPro.3105"])',
                    'InteractiveSectionView(title: "CAPCUT PRO", items: ["CAPCUTPRO/CapcutPro.3105"])')

# 2. Update Free Fire Proxy tab
old_ff_proxy = """                        } else if selectedTab == "Proxy" {
                            InteractiveSectionView(title: "PATCHES (BẬT SẢNH)", items: [
                                "AIM BODY (BẬT SẢNH).3105",
                                "AIM CHEST (BẬT SẢNH).3105",
                                "AIM DRAG (BẬT SẢNH).3105",
                                "AIM NECK (BẬT SẢNH).3105",
                                "MAGIC BULLET (BẬT SẢNH).3105"
                            ])"""

new_ff_proxy = """                        } else if selectedTab == "Proxy" {
                            let folder = app.bundleId == "com.dts.freefiremax" ? "FREEFIREMAX" : "FREEFIRETH"
                            InteractiveSectionView(title: "PATCHES (BẬT SẢNH)", items: [
                                "\\(folder)/AIM BODY (BẬT SẢNH).3105",
                                "\\(folder)/AIM CHEST (BẬT SẢNH).3105",
                                "\\(folder)/AIM DRAG (BẬT SẢNH).3105",
                                "\\(folder)/AIM NECK (BẬT SẢNH).3105",
                                "\\(folder)/MAGIC BULLET (BẬT SẢNH).3105"
                            ])"""
text = text.replace(old_ff_proxy, new_ff_proxy)

# 3. Update InteractiveRow to parse the name
old_text = 'Text(item.replacingOccurrences(of: ".3105", with: ""))'
new_text = 'Text((item.components(separatedBy: "/").last ?? item).replacingOccurrences(of: ".3105", with: ""))'
text = text.replace(old_text, new_text)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated ContentView for multi-app patches")
