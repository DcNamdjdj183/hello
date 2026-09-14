import sys
path = 'ThreeOneOSFive.xcodeproj/project.pbxproj'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Add to PBXBuildFile
text = text.replace(
    'N3105B008 /* AIMMALFORMATION.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P008; };',
    'N3105B008 /* AIMMALFORMATION.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P008; };\n\t\tN3105B010 /* AIMBODY_BATSANH.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P010; };\n\t\tN3105B011 /* AIMCHEST_BATSANH.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P011; };\n\t\tN3105B012 /* AIMDRAG_BATSANH.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P012; };\n\t\tN3105B013 /* AIMNECK_BATSANH.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P013; };\n\t\tN3105B014 /* MAGICBULLET_BATSANH.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P014; };\n\t\tN3105B015 /* AIMNECKANTENA_40.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P015; };'
)

# Add to PBXFileReference
text = text.replace(
    'N3105P008 /* AIMMALFORMATION.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMMALFORMATION.3105"; sourceTree = "<group>"; };',
    'N3105P008 /* AIMMALFORMATION.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMMALFORMATION.3105"; sourceTree = "<group>"; };\n\t\tN3105P010 /* AIMBODY_BATSANH.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMBODY_BATSANH.3105"; sourceTree = "<group>"; };\n\t\tN3105P011 /* AIMCHEST_BATSANH.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMCHEST_BATSANH.3105"; sourceTree = "<group>"; };\n\t\tN3105P012 /* AIMDRAG_BATSANH.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMDRAG_BATSANH.3105"; sourceTree = "<group>"; };\n\t\tN3105P013 /* AIMNECK_BATSANH.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMNECK_BATSANH.3105"; sourceTree = "<group>"; };\n\t\tN3105P014 /* MAGICBULLET_BATSANH.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/MAGICBULLET_BATSANH.3105"; sourceTree = "<group>"; };\n\t\tN3105P015 /* AIMNECKANTENA_40.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/AIMNECKANTENA_40.3105"; sourceTree = "<group>"; };'
)

# Add to Patches PBXGroup
text = text.replace(
    'N3105P008 /* AIMMALFORMATION.3105 */,',
    'N3105P008 /* AIMMALFORMATION.3105 */,\n\t\t\t\tN3105P010 /* AIMBODY_BATSANH.3105 */,\n\t\t\t\tN3105P011 /* AIMCHEST_BATSANH.3105 */,\n\t\t\t\tN3105P012 /* AIMDRAG_BATSANH.3105 */,\n\t\t\t\tN3105P013 /* AIMNECK_BATSANH.3105 */,\n\t\t\t\tN3105P014 /* MAGICBULLET_BATSANH.3105 */,\n\t\t\t\tN3105P015 /* AIMNECKANTENA_40.3105 */,'
)

# Add to PBXResourcesBuildPhase
text = text.replace(
    'N3105B008,',
    'N3105B008,\n\t\t\t\tN3105B010,\n\t\t\t\tN3105B011,\n\t\t\t\tN3105B012,\n\t\t\t\tN3105B013,\n\t\t\t\tN3105B014,\n\t\t\t\tN3105B015,'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated pbxproj for new patches')
