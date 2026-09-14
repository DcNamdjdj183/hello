import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Remove the extra Spacer().frame(height: 0)
text = text.replace('                Spacer().frame(height: 0) // Anchor top\n', '')
text = text.replace('                Spacer().frame(height: 0)\n', '')

# 2. Fix the Navigation Bar Gap
text = text.replace('.navigationBarHidden(true)', '.navigationBarHidden(true)\n        .navigationBarTitle("", displayMode: .inline)')
# In case it was already replaced previously, let's make sure we don't duplicate
text = text.replace('.navigationBarHidden(true)\n        .navigationBarTitle("", displayMode: .inline)\n        .navigationBarTitle("", displayMode: .inline)', '.navigationBarHidden(true)\n        .navigationBarTitle("", displayMode: .inline)')

# 3. Remove "Pass patches: 3105" text
target_text_to_remove = """                                Text("Pass patches: 3105")
                                    .font(.system(size: 12))
                                    .foregroundColor(.cyan)"""
text = text.replace(target_text_to_remove, "")

# 4. Also, check if there's any remaining `Spacer().frame(height: 0)` that I missed
text = re.sub(r'^[ \t]*Spacer\(\)\.frame\(height: 0\).*?\n', '', text, flags=re.MULTILINE)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Layout fixed and password text removed.")
