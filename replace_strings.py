import os

directory = r"D:\hello-repo\ThreeOneOSFive"
pbxproj = r"D:\hello-repo\ThreeOneOSFive.xcodeproj\project.pbxproj"

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return
    
    new_content = content.replace("THANH DO IOS", "DNTWEAKS")
    new_content = new_content.replace("Thanh Do IOS", "DNTWEAKS")
    new_content = new_content.replace("Thanh Do Team", "DNTWEAKS Team")
    new_content = new_content.replace("Thanh Do", "DNTWEAKS")
    new_content = new_content.replace("0846260109", "0395109314")
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.swift') or file.endswith('.plist'):
            replace_in_file(os.path.join(root, file))

replace_in_file(pbxproj)
