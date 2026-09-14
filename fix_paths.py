import sys
path = 'ThreeOneOSFive.xcodeproj/project.pbxproj'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Fix AppNotificationManager.swift path
text = text.replace(
    'path = AppNotificationManager.swift;',
    'path = helpers/AppNotificationManager.swift;'
)

# Fix LicenseManager.swift path if it's wrong
text = text.replace(
    'path = LicenseManager.swift;',
    'path = helpers/LicenseManager.swift;'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Fixed paths in project.pbxproj')
