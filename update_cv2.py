import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Restore LicenseActivationView in ContentView
old_content_view_body = """    var body: some View {
        NavigationView {"""

new_content_view_body = """    var body: some View {
        Group {
            if !licenseManager.isActive {
                LicenseActivationView()
            } else {
                mainContent
            }
        }
    }
    
    var mainContent: some View {
        NavigationView {"""

text = text.replace(old_content_view_body, new_content_view_body)

# 2. Add KeyStatusCard structure and inject into ContentView
key_status_struct = """struct KeyStatusCard: View {
    @EnvironmentObject private var licenseManager: LicenseManager
    var body: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(.purple)
            Text("Thời gian sử dụng:")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Text(formattedTime)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(licenseManager.remainingSeconds < 3600 ? .red : .green)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
    
    var formattedTime: String {
        let h = licenseManager.remainingSeconds / 3600
        let m = (licenseManager.remainingSeconds % 3600) / 60
        let s = licenseManager.remainingSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
"""

text = text + "\n" + key_status_struct

# Inject KeyStatusCard into ContentView list
old_list_start = """                        VStack(alignment: .leading, spacing: 16) {
                            Text("QUẢN LÝ APP")"""
new_list_start = """                        VStack(alignment: .leading, spacing: 16) {
                            KeyStatusCard()
                                .padding(.bottom, 8)
                            Text("QUẢN LÝ APP")"""
text = text.replace(old_list_start, new_list_start)


# 3. Add Logout to CustomSettingsView
# First, we need to ensure licenseManager is available in CustomSettingsView
old_settings_env = """struct CustomSettingsView: View {
    @Environment(\\.presentationMode) var presentationMode
    @State private var showLanguageAlert = false"""

new_settings_env = """struct CustomSettingsView: View {
    @Environment(\\.presentationMode) var presentationMode
    @EnvironmentObject private var licenseManager: LicenseManager
    @State private var showLanguageAlert = false"""
text = text.replace(old_settings_env, new_settings_env)

old_settings_buttons = """                        Button(action: { resetAllSettings() }) {
                            SettingsRow(icon: "arrow.counterclockwise", title: "Khôi phục cài đặt", subtitle: "Về trạng thái gốc", hasArrow: false)
                        }"""
new_settings_buttons = """                        Button(action: { resetAllSettings() }) {
                            SettingsRow(icon: "arrow.counterclockwise", title: "Khôi phục cài đặt", subtitle: "Về trạng thái gốc", hasArrow: false)
                        }
                        
                        Button(action: {
                            licenseManager.deactivate()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Đăng Xuất", subtitle: "Thay đổi Key", hasArrow: false)
                        }"""
text = text.replace(old_settings_buttons, new_settings_buttons)


# 4. Fix AppDetailView layout gap
# We will apply ignoresSafeArea to VStack and add top padding 44
old_app_detail_vstack = """            VStack(spacing: 0) {
                // Header"""
new_app_detail_vstack = """            VStack(spacing: 0) {
                // Header"""
# Actually, the simplest fix is to just pad the HStack Header directly and ignoreSafeArea on ZStack
old_app_detail_header = """                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {"""
new_app_detail_header = """                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {"""

old_app_detail_frame = """            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)"""
new_app_detail_frame = """            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(.all, edges: .top)
            .padding(.top, 44) // Fix Navigation Bar gap
        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)"""
text = text.replace(old_app_detail_frame, new_app_detail_frame)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Update completed.")
