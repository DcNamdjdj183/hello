import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's find the block:
# VStack(spacing: 0) {
#     PremiumToggleRow(...)
#     ...
# }
# and replace it.

start_str = '                                VStack(spacing: 0) {\n                                    PremiumToggleRow(name: "AIM BODY 90%",'
end_str = 'PremiumToggleRow(name: "AIM NECK ANTENA", pkg: "Log 40%", isOn: $aimNeckAntenaEnabled, isBusy: patchOperationBusy, isDisabled: isPatchDisabled) { togglePatch(id: "497EDBD6-FA5C-4015-88CD-6C3DFE4C827F", name: "AIM NECK ANTENA", state: $aimNeckAntenaEnabled) }\n                                }\n'

# We'll just replace the whole body of `selectedScriptCategory == 0`'s VStack
vstack_body_pattern = r'(if selectedScriptCategory == 0 \{[\s\S]*?VStack\(spacing: 0\) \{)([\s\S]*?)(\}\n\s*\.background\(Color\.black\.opacity\(0\.3\)\))'

match = re.search(vstack_body_pattern, text)
if match:
    prefix = match.group(1)
    body = match.group(2)
    suffix = match.group(3)
    
    # split body into lines
    lines = [l for l in body.split('\n') if l.strip() != '']
    
    # group them into chunks of 10 lines max.
    # Actually, each "view" is 1 line.
    new_body = ""
    chunk = []
    for line in lines:
        chunk.append(line)
        if len(chunk) == 8:
            new_body += "                                    Group {\n"
            for cl in chunk:
                new_body += cl + "\n"
            new_body += "                                    }\n"
            chunk = []
            
    if chunk:
        new_body += "                                    Group {\n"
        for cl in chunk:
            new_body += cl + "\n"
        new_body += "                                    }\n"
        
    text = text[:match.start()] + prefix + "\n" + new_body + suffix + text[match.end():]
    
    with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Grouped views successfully!")
else:
    print("Could not find the VStack block.")
