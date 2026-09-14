with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('LicenseActivationView()', 'LicenseActivationView(manager: licenseManager)')

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed LicenseActivationView argument")
