import re

path = 'ThreeOneOSFive.xcodeproj/project.pbxproj'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Find path = ThreeOneOSFive/Patches/OGIOS File (x).3105; and quote it
def quote_path(match):
    prefix = match.group(1)
    unquoted_path = match.group(2)
    return f'{prefix}"{unquoted_path}";'

# Regex to match: path = ThreeOneOSFive/Patches/OGIOS File (x).3105;
# (where it's not already quoted)
fixed_text = re.sub(r'(path\s*=\s*)(ThreeOneOSFive/Patches/[^";]+);', quote_path, text)

with open(path, 'w', encoding='utf-8') as f:
    f.write(fixed_text)

print("Fixed project.pbxproj")
