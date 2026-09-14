import os

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

target1 = """struct CustomSettingsView: View {
    @Environment(\\.presentationMode) var presentationMode
    @State private var showLanguageAlert = false"""

rep1 = """struct CustomSettingsView: View {
    @Environment(\\.presentationMode) var presentationMode
    @EnvironmentObject private var licenseManager: LicenseManager
    @State private var showLanguageAlert = false"""

text = text.replace(target1, rep1)

target2 = """                        Button(action: { resetAllSettings() }) {
                            SettingsRow(icon: "arrow.counterclockwise", title: "Khôi phục cài đặt", subtitle: "Về trạng thái gốc", hasArrow: false)
                        }"""

rep2 = """                        Button(action: { resetAllSettings() }) {
                            SettingsRow(icon: "arrow.counterclockwise", title: "Khôi phục cài đặt", subtitle: "Về trạng thái gốc", hasArrow: false)
                        }
                        
                        Button(action: {
                            licenseManager.deactivate()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Đăng Xuất", subtitle: "Thay đổi Key", hasArrow: false)
                        }"""

text = text.replace(target2, rep2)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Applied CustomSettingsView changes.")
