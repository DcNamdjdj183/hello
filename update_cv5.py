import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

target1 = """struct CustomSettingsView: View {
    @Environment(\\.presentationMode) var presentationMode
    @AppStorage("AppTouchPointerEnabled") private var touchEnabled = true
    @State private var showLanguageAlert = false"""

rep1 = """struct CustomSettingsView: View {
    @Environment(\\.presentationMode) var presentationMode
    @EnvironmentObject private var licenseManager: LicenseManager
    @AppStorage("AppTouchPointerEnabled") private var touchEnabled = true
    @State private var showLanguageAlert = false"""

text = text.replace(target1, rep1)

settings_btn_regex = r'(Button\(action: \{ resetAllSettings\(\) \}\) \{\s*SettingsRow\(icon: "arrow\.counterclockwise", title: "Khôi phục cài đặt", subtitle: "Về trạng thái gốc", hasArrow: false\)\s*\})'
rep2 = r'\1\n                        \n                        Button(action: {\n                            licenseManager.deactivate()\n                            presentationMode.wrappedValue.dismiss()\n                        }) {\n                            SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Đăng Xuất", subtitle: "Thay đổi Key", hasArrow: false)\n                        }'
text = re.sub(settings_btn_regex, rep2, text)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Applied CustomSettingsView changes.")
