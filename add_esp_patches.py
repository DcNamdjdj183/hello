import sys
import re

with open("ThreeOneOSFive.xcodeproj/project.pbxproj", "r", encoding="utf-8") as f:
    text = f.read()

# Add to PBXBuildFile
build_files = """/* Begin PBXBuildFile section */
		N3105B016 /* ESP_FREE_FIRE_TH.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P016; };
		N3105B017 /* ESP_FREE_FIRE_MAX.3105 in Resources */ = {isa = PBXBuildFile; fileRef = N3105P017; };"""
if "N3105B016" not in text:
    text = text.replace("/* Begin PBXBuildFile section */", build_files)

# Add to PBXFileReference
file_refs = """/* Begin PBXFileReference section */
		N3105P016 /* ESP_FREE_FIRE_TH.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/ESP_FREE_FIRE_TH.3105"; sourceTree = "<group>"; };
		N3105P017 /* ESP_FREE_FIRE_MAX.3105 */ = {isa = PBXFileReference; lastKnownFileType = file; path = "ThreeOneOSFive/Patches/ESP_FREE_FIRE_MAX.3105"; sourceTree = "<group>"; };"""
if "N3105P016" not in text:
    text = text.replace("/* Begin PBXFileReference section */", file_refs)

# Add to Resources
resources_match = re.search(r'(3105A800 /\* Resources \*/ = \{\n\s*isa = PBXResourcesBuildPhase;\n\s*buildActionMask = 2147483647;\n\s*files = \([\s\S]*?N3105B015,)\n', text)
if resources_match and "N3105B016" not in resources_match.group(0):
    original_files = resources_match.group(1)
    new_files = original_files + """\n\t\t\t\tN3105B016,\n\t\t\t\tN3105B017,"""
    text = text.replace(original_files, new_files)
else:
    print("Resources match failed or already added")

with open("ThreeOneOSFive.xcodeproj/project.pbxproj", "w", encoding="utf-8") as f:
    f.write(text)
print("Updated project.pbxproj")
