import os

# Update Info.plist
info_plist = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\Info.plist'
with open(info_plist, 'r', encoding='utf-8') as f:
    text = f.read()

# Replace <string>OGIOS</string> with <string>THANH DO IOS</string> for CFBundleDisplayName and CFBundleName
text = text.replace('<key>CFBundleDisplayName</key>\n    <string>OGIOS</string>', '<key>CFBundleDisplayName</key>\n    <string>THANH DO IOS</string>')
text = text.replace('<key>CFBundleName</key>\n    <string>OGIOS</string>', '<key>CFBundleName</key>\n    <string>THANH DO IOS</string>')

with open(info_plist, 'w', encoding='utf-8') as f:
    f.write(text)

# Update project.pbxproj
pbxproj = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive.xcodeproj\project.pbxproj'
with open(pbxproj, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('INFOPLIST_KEY_CFBundleDisplayName = "OGIOS";', 'INFOPLIST_KEY_CFBundleDisplayName = "THANH DO IOS";')
# DO NOT CHANGE PRODUCT_NAME as it might break build paths if product name is used for executable naming

with open(pbxproj, 'w', encoding='utf-8') as f:
    f.write(text)

# Also update the title in ContentView if there's any
cv = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\ContentView.swift'
with open(cv, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('Text("OGIOS")', 'Text("THANH DO IOS")')

with open(cv, 'w', encoding='utf-8') as f:
    f.write(text)

print("Renamed app to THANH DO IOS")
