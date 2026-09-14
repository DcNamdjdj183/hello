import re

pbxproj_path = "ThreeOneOSFive.xcodeproj/project.pbxproj"

with open(pbxproj_path, "r", encoding="utf-8") as f:
    text = f.read()

if "N3105D001" not in text:
    # 1. Add to PBXBuildFile
    build_files = """/* Begin PBXBuildFile section */
		N3105D002 /* dns in Resources */ = {isa = PBXBuildFile; fileRef = N3105D001; };
		N3105V002 /* video in Resources */ = {isa = PBXBuildFile; fileRef = N3105V001; };"""
    text = text.replace("/* Begin PBXBuildFile section */", build_files)

    # 2. Add to PBXFileReference
    file_refs = """/* Begin PBXFileReference section */
		N3105D001 /* dns */ = {isa = PBXFileReference; lastKnownFileType = folder; path = dns; sourceTree = "<group>"; };
		N3105V001 /* video */ = {isa = PBXFileReference; lastKnownFileType = folder; path = video; sourceTree = "<group>"; };"""
    text = text.replace("/* Begin PBXFileReference section */", file_refs)

    # 3. Add to ThreeOneOSFive Group
    group_children = """children = (
				N3105D001 /* dns */,
				N3105V001 /* video */,"""
    # Find the exact group
    text = text.replace("""		3105A401 /* ThreeOneOSFive */ = {
			isa = PBXGroup;
			children = (""", """		3105A401 /* ThreeOneOSFive */ = {
			isa = PBXGroup;
			children = (
				N3105D001 /* dns */,
				N3105V001 /* video */,""")

    # 4. Add to Resources Phase
    resources = """		3105A800 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				N3105D002 /* dns in Resources */,
				N3105V002 /* video in Resources */,"""
    text = text.replace("""		3105A800 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (""", resources)

    with open(pbxproj_path, "w", encoding="utf-8") as f:
        f.write(text)
    print("Successfully added dns and video folders to project.pbxproj")
else:
    print("Folders already added")
