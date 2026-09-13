import re

with open("ThreeOneOSFive.xcodeproj/project.pbxproj", "r", encoding="utf-8") as f:
    text = f.read()

# 1. Fix path for ESP_FREE_FIRE_TH.3105
text = text.replace(
    'path = ESP_FREE_FIRE_TH.3105; sourceTree = "<group>";',
    'path = "ThreeOneOSFive/Patches/ESP_FREE_FIRE_TH.3105"; sourceTree = "<group>";'
)

# 2. Fix path for ESP_FREE_FIRE_MAX.3105
text = text.replace(
    'path = ESP_FREE_FIRE_MAX.3105; sourceTree = "<group>";',
    'path = "ThreeOneOSFive/Patches/ESP_FREE_FIRE_MAX.3105"; sourceTree = "<group>";'
)

# 3. Remove duplicate N3105B016 and N3105B017 from files array
# Replace exactly:
# 				N3105B016,
# 				N3105B017,
# 				N3105B016,
# 				N3105B017,
duplicates = """				N3105B016,
				N3105B017,
				N3105B016,
				N3105B017,"""
fixed_files = """				N3105B016,
				N3105B017,"""
text = text.replace(duplicates, fixed_files)

with open("ThreeOneOSFive.xcodeproj/project.pbxproj", "w", encoding="utf-8") as f:
    f.write(text)
print("Fixed PBXProj paths and duplicates")
