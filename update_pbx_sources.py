import sys
path = 'ThreeOneOSFive.xcodeproj/project.pbxproj'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# PBXSourcesBuildPhase
text = text.replace(
    '3105K200,',
    '3105K200,\n\t\t\t\t\tN3105B009,'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print('Updated pbxproj sources')
