import os

def replace_ogios(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        text = f.read()
    
    text = text.replace('Text("OGIOS")', 'Text("DNXTWEAKS")')
    text = text.replace('"[OGIOS] ', '"[DNXTWEAKS] ')
    text = text.replace('"OGIOS Workspace"', '"DNXTWEAKS Workspace"')
    text = text.replace('navigationTitle("OGIOS")', 'navigationTitle("DNXTWEAKS")')
    text = text.replace('OGIOS Data', 'DNXTWEAKS Data')
    
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(text)

files_to_update = [
    "ThreeOneOSFive/views/SettingsView.swift",
    "ThreeOneOSFive/helpers/Utils.swift",
    "ThreeOneOSFive/views/FileBrowserView.swift",
    "ThreeOneOSFive/views/AppDataBrowserView.swift",
    "ThreeOneOSFive/views/PatchProjectsView.swift",
    "ThreeOneOSFive/helpers/PatchDraftCoordinator.swift",
    "ThreeOneOSFive/helpers/PatchProjectLibrary.swift",
    "ThreeOneOSFive/views/WallpaperLabView.swift",
    "ThreeOneOSFive/views/LogView.swift"
]

for f in files_to_update:
    if os.path.exists(f):
        replace_ogios(f)
print("Replaced OGIOS with DNXTWEAKS in UI")
