const fs = require('fs');
let text = fs.readFileSync('ThreeOneOSFive.xcodeproj/project.pbxproj', 'utf8');

if (!text.includes('N3105P999')) {
    text = text.replace('/* Begin PBXBuildFile section */', '/* Begin PBXBuildFile section */\n\t\tN3105P999 /* Patches in Resources */ = {isa = PBXBuildFile; fileRef = N3105P998; };');
    text = text.replace('/* Begin PBXFileReference section */', '/* Begin PBXFileReference section */\n\t\tN3105P998 /* Patches */ = {isa = PBXFileReference; lastKnownFileType = folder; path = Patches; sourceTree = "<group>"; };');
    
    // Add to ThreeOneOSFive group children
    text = text.replace('3105A401 /* ThreeOneOSFive */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (', '3105A401 /* ThreeOneOSFive */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\tN3105P998 /* Patches */,');

    // Add to Resources Phase
    text = text.replace('3105A800 /* Resources */ = {\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (', '3105A800 /* Resources */ = {\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t\tN3105P999 /* Patches in Resources */,');

    fs.writeFileSync('ThreeOneOSFive.xcodeproj/project.pbxproj', text, 'utf8');
    console.log('Added Patches folder to pbxproj successfully');
} else {
    console.log('Already added');
}
