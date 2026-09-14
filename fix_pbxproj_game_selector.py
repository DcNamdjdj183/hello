import sys

pbxproj_path = 'ThreeOneOSFive.xcodeproj/project.pbxproj'
with open(pbxproj_path, 'r', encoding='utf-8') as f:
    text = f.read()

if 'GameSelectorView.swift' not in text:
    # 1. Add PBXBuildFile
    build_files = '''/* Begin PBXBuildFile section */
		N3105GSV2 /* GameSelectorView.swift in Sources */ = {isa = PBXBuildFile; fileRef = N3105GSV1 /* GameSelectorView.swift */; };'''
    text = text.replace('/* Begin PBXBuildFile section */', build_files)

    # 2. Add PBXFileReference
    file_refs = '''/* Begin PBXFileReference section */
		N3105GSV1 /* GameSelectorView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GameSelectorView.swift; sourceTree = "<group>"; };'''
    text = text.replace('/* Begin PBXFileReference section */', file_refs)

    # 3. Add to views group
    views_group = '''		3105A404 /* views */ = {
			isa = PBXGroup;
			children = (
				N3105GSV1 /* GameSelectorView.swift */,'''
    text = text.replace('''		3105A404 /* views */ = {
			isa = PBXGroup;
			children = (''', views_group)

    # 4. Add to Sources Build Phase
    sources_phase = '''		3105A01C /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				N3105GSV2 /* GameSelectorView.swift in Sources */,'''
    text = text.replace('''		3105A01C /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (''', sources_phase)

    with open(pbxproj_path, 'w', encoding='utf-8') as f:
        f.write(text)
    print('Added GameSelectorView to PBXProj')
else:
    print('Already in PBXProj')
