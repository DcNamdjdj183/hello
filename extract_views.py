import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# We will match the entire `if selectedScriptCategory == 0 { ... } else if ... }` block
# and replace it with `scriptCategoryViews`

# Find the start of the `if selectedScriptCategory == 0 {` block
start_idx = text.find('                            if selectedScriptCategory == 0 {')
if start_idx != -1:
    # Find the end by counting braces
    stack = 0
    end_idx = -1
    for i in range(start_idx, len(text)):
        if text[i] == '{':
            stack += 1
        elif text[i] == '}':
            stack -= 1
            if stack == 0 and text[i:i+7] != '} else ' and text[i+1:i+8] != ' else i' and text.find('else if', i, i+20) == -1:
                # Wait, `} else if` is right after.
                # Let's use regex to find the end of the `selectedScriptCategory == 3` block
                pass

# Actually, doing it via regex is easier
pattern = r'(                            if selectedScriptCategory == 0 \{[\s\S]*?\.shadow\(color: Color\.black\.opacity\(0\.2\), radius: 10, y: 5\)\n\s*\})'
match = re.search(pattern, text)
if match:
    block = match.group(1)
    # Remove it from body
    text = text.replace(block, '                            scriptCategoryViews')
    
    # Unindent block by 16 spaces
    lines = block.split('\n')
    unindented_lines = []
    for line in lines:
        if line.startswith('                            '):
            unindented_lines.append(line[16:])
        elif line.startswith('                        '):
            unindented_lines.append(line[16:])
        elif line.startswith('                                '):
            unindented_lines.append(line[16:])
        else:
            unindented_lines.append(line)
    
    view_builder_func = "\n    @ViewBuilder\n    private var scriptCategoryViews: some View {\n"
    for line in lines:
        if line.startswith('                        '):
            view_builder_func += line[8:] + '\n'
        else:
            view_builder_func += line + '\n'
    view_builder_func += "    }\n"
    
    # Insert before private func syncPatchStates()
    text = text.replace('    private func syncPatchStates() {', view_builder_func + '\n    private func syncPatchStates() {')
    
    with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Successfully extracted scriptCategoryViews")
else:
    print("Could not find the block")
