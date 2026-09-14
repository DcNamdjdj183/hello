import os
import re

directories = [
    r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\Patches\FREEFIRETH',
    r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\Patches\FREEFIREMAX'
]

# Rename files in directory
for folder in directories:
    if not os.path.exists(folder):
        continue
    for f in os.listdir(folder):
        if '--2' in f:
            new_f = f.replace('--2', '-')
            old_path = os.path.join(folder, f)
            new_path = os.path.join(folder, new_f)
            
            # If the - version already exists, just remove the --2 version
            if os.path.exists(new_path):
                os.remove(old_path)
            else:
                os.rename(old_path, new_path)

# Update ContentView.swift
cv_path = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\ContentView.swift'
with open(cv_path, 'r', encoding='utf-8') as f:
    text = f.read()

# Replace any occurrence of '--2' with '-' inside the ContentView string
text = text.replace('--2.3105', '-.3105')

with open(cv_path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Removed --2 from filenames and ContentView.swift!")
