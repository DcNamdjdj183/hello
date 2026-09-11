import sys
path = 'ThreeOneOSFive.xcodeproj/project.pbxproj'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# BuildFile
if 'N3105B009 /* AppNotificationManager.swift in Sources */' not in text:
    text = text.replace(
        '3105K200 /* LicenseManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 3105K100; };',
        '3105K200 /* LicenseManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 3105K100; };\n\t\tN3105B009 /* AppNotificationManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = N3105P009; };'
    )

# FileReference
if 'N3105P009 /* AppNotificationManager.swift */' not in text:
    text = text.replace(
        '3105K100 /* LicenseManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LicenseManager.swift; sourceTree = "<group>"; };',
        '3105K100 /* LicenseManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LicenseManager.swift; sourceTree = "<group>"; };\n\t\tN3105P009 /* AppNotificationManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppNotificationManager.swift; sourceTree = "<group>"; };'
    )

# PBXGroup
text = text.replace(
    '3105K100 /* LicenseManager.swift */,\n',
    '3105K100 /* LicenseManager.swift */,\n\t\t\t\tN3105P009 /* AppNotificationManager.swift */,\n'
)

# PBXSourcesBuildPhase
text = text.replace(
    '3105K200 /* LicenseManager.swift in Sources */,\n',
    '3105K200 /* LicenseManager.swift in Sources */,\n\t\t\t\tN3105B009 /* AppNotificationManager.swift in Sources */,\n'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print('Updated pbxproj')
