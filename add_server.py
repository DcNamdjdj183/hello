import re

with open('ThreeOneOSFive.xcodeproj/project.pbxproj', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Add file reference
file_ref = '		N3105P099 /* ProfileServer.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProfileServer.swift; sourceTree = "<group>"; };'
if file_ref not in text:
    text = text.replace('/* End PBXFileReference section */', file_ref + '\n/* End PBXFileReference section */')

# 2. Add build file
build_file = '		N3105B099 /* ProfileServer.swift in Sources */ = {isa = PBXBuildFile; fileRef = N3105P099; };'
if build_file not in text:
    text = text.replace('/* End PBXBuildFile section */', build_file + '\n/* End PBXBuildFile section */')

# 3. Add to helpers group
group_pattern = r'(3105A405 /\* helpers \*/ = \{[\s\S]*?children = \()([\s\S]*?)(\);)'
match = re.search(group_pattern, text)
if match and 'N3105P099' not in match.group(2):
    prefix = match.group(1)
    children = match.group(2)
    suffix = match.group(3)
    text = text[:match.start()] + prefix + children + '				N3105P099 /* ProfileServer.swift */,\n' + suffix + text[match.end():]

# 4. Add to PBXSourcesBuildPhase
sources_pattern = r'(isa = PBXSourcesBuildPhase;[\s\S]*?files = \()([\s\S]*?)(\);)'
match = re.search(sources_pattern, text)
if match and 'N3105B099' not in match.group(2):
    prefix = match.group(1)
    children = match.group(2)
    suffix = match.group(3)
    text = text[:match.start()] + prefix + children + '				N3105B099 /* ProfileServer.swift in Sources */,\n' + suffix + text[match.end():]

with open('ThreeOneOSFive.xcodeproj/project.pbxproj', 'w', encoding='utf-8') as f:
    f.write(text)
print('Added ProfileServer.swift to PBXProj')
