import sys
path = 'ThreeOneOSFive.xcodeproj/project.pbxproj'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Add to PBXBuildFile
text = text.replace(
    'N3105B005 /* CHAMS-BLUE.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P005; };',
    'N3105B005 /* CHAMS-BLUE.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P005; };\n\t\tN3105B006 /* AIMDRAG.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P006; };\n\t\tN3105B007 /* AIMHEAD.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P007; };\n\t\tN3105B008 /* AIMMALFORMATION.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P008; };'
)

# Add to PBXFileReference
text = text.replace(
    'N3105P005 /* CHAMS-BLUE.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/CHAMS-BLUE.3105"; sourceTree = "<group>"; };',
    'N3105P005 /* CHAMS-BLUE.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/CHAMS-BLUE.3105"; sourceTree = "<group>"; };\n\t\tN3105P006 /* AIMDRAG.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMDRAG.3105"; sourceTree = "<group>"; };\n\t\tN3105P007 /* AIMHEAD.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMHEAD.3105"; sourceTree = "<group>"; };\n\t\tN3105P008 /* AIMMALFORMATION.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMMALFORMATION.3105"; sourceTree = "<group>"; };'
)

# Add to Patches PBXGroup
text = text.replace(
    'N3105P005 /* CHAMS-BLUE.3105 */,',
    'N3105P005 /* CHAMS-BLUE.3105 */,\n\t\t\t\tN3105P006 /* AIMDRAG.3105 */,\n\t\t\t\tN3105P007 /* AIMHEAD.3105 */,\n\t\t\t\tN3105P008 /* AIMMALFORMATION.3105 */,'
)

# Add to PBXResourcesBuildPhase
text = text.replace(
    'N3105B005,',
    'N3105B005,\n\t\t\t\tN3105B006,\n\t\t\t\tN3105B007,\n\t\t\t\tN3105B008,'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated pbxproj')
