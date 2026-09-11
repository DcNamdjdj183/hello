import sys
path = 'ThreeOneOSFive.xcodeproj/project.pbxproj'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    '3105A213 /* AudioFeedback.swift in Sources */ = {isa = PBXBuildFile; fileRef = 3105A013; };',
    '3105A213 /* AudioFeedback.swift in Sources */ = {isa = PBXBuildFile; fileRef = 3105A013; };\n\t\tN3105B009 /* AppNotificationManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = N3105P009; };'
)

text = text.replace(
    '3105A013 /* AudioFeedback.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AudioFeedback.swift; sourceTree = "<group>"; };',
    '3105A013 /* AudioFeedback.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AudioFeedback.swift; sourceTree = "<group>"; };\n\t\tN3105P009 /* AppNotificationManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppNotificationManager.swift; sourceTree = "<group>"; };'
)

text = text.replace(
    '3105A013 /* AudioFeedback.swift */,',
    '3105A013 /* AudioFeedback.swift */,\n\t\t\t\tN3105P009 /* AppNotificationManager.swift */,'
)

text = text.replace(
    '3105A213 /* AudioFeedback.swift in Sources */,',
    '3105A213 /* AudioFeedback.swift in Sources */,\n\t\t\t\tN3105B009 /* AppNotificationManager.swift in Sources */,'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print('Updated pbxproj')
