import sys
path = 'ThreeOneOSFive.xcodeproj/project.pbxproj'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Add to PBXBuildFile
text = text.replace(
    'N3105B003 /* AIMNECK.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P003; };',
    'N3105B003 /* AIMNECK.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P003; };\n\t\tN3105B004 /* SKIN-1.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P004; };\n\t\tN3105B005 /* CHAMS-BLUE.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P005; };'
)

# Add to PBXFileReference
text = text.replace(
    'N3105P003 /* AIMNECK.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMNECK.3105"; sourceTree = "<group>"; };',
    'N3105P003 /* AIMNECK.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMNECK.3105"; sourceTree = "<group>"; };\n\t\tN3105P004 /* SKIN-1.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/SKIN-1.3105"; sourceTree = "<group>"; };\n\t\tN3105P005 /* CHAMS-BLUE.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/CHAMS-BLUE.3105"; sourceTree = "<group>"; };'
)

# Add to Patches PBXGroup
text = text.replace(
    'N3105P003 /* AIMNECK.3105 */,',
    'N3105P003 /* AIMNECK.3105 */,\n\t\t\t\tN3105P004 /* SKIN-1.3105 */,\n\t\t\t\tN3105P005 /* CHAMS-BLUE.3105 */,'
)

# Add to PBXResourcesBuildPhase
text = text.replace(
    'N3105B003,',
    'N3105B003,\n\t\t\t\tN3105B004,\n\t\t\t\tN3105B005,'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated pbxproj')
