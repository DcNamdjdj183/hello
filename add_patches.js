const fs = require('fs');
let text = fs.readFileSync('ThreeOneOSFive.xcodeproj/project.pbxproj', 'utf8');

if (!text.includes('N3105P001')) {
    // 1. Add to PBXBuildFile
    text = text.replace('/* Begin PBXBuildFile section */', '/* Begin PBXBuildFile section */\n\t\tN3105P002 /* Patches in Resources */ = {isa = PBXBuildFile; fileRef = N3105P001; };');

    // 2. Add to PBXFileReference
    text = text.replace('/* Begin PBXFileReference section */', '/* Begin PBXFileReference section */\n\t\tN3105P001 /* Patches */ = {isa = PBXFileReference; lastKnownFileType = folder; path = Patches; sourceTree = "<group>"; };');

    // 3. Add to Group
    text = text.replace('3105A401 /* ThreeOneOSFive */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (', '3105A401 /* ThreeOneOSFive */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\tN3105P001 /* Patches */,');

    // 4. Add to Resources Phase
    text = text.replace('3105A800 /* Resources */ = {\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (', '3105A800 /* Resources */ = {\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t\tN3105P002 /* Patches in Resources */,');

    fs.writeFileSync('ThreeOneOSFive.xcodeproj/project.pbxproj', text, 'utf8');
    console.log('Added Patches folder to pbxproj');
} else {
    console.log('Already added');
}
