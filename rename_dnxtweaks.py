import os
import glob

def replace_in_file(filepath, replacements):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = False
    for old, new in replacements:
        if old in content:
            content = content.replace(old, new)
            modified = True
            
    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

base_dir = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive'
files_to_check = []
for ext in ['*.swift']:
    files_to_check.extend(glob.glob(os.path.join(base_dir, '**', ext), recursive=True))

replacements = [
    ('app: DNXTWEAKS launching', 'app: THANH DO IOS launching'),
    ('Text("DNXTWEAKS")', 'Text("THANH DO IOS")'),
    ('Text("Package: DNXTWEAKS")', 'Text("Package: THANH DO IOS")'),
    ('Text("Enter your DNXTWEAKS license key', 'Text("Enter your THANH DO IOS license key'),
    ('"[DNXTWEAKS] \\(msg)"', '"[THANH DO IOS] \\(msg)"'),
    ('"DNXTWEAKS Log"', '"THANH DO IOS Log"'),
    ('com.DNXTWEAKS.external', 'com.THANHDOIOS.external')
]

for f in files_to_check:
    replace_in_file(f, replacements)

print("Done replacing DNXTWEAKS with THANH DO IOS.")
