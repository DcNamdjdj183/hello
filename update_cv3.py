import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Update ContentView body to check LicenseManager
# Find the exact start of ContentView
content_view_start = text.find('struct ContentView: View {')
if content_view_start != -1:
    body_start = text.find('    var body: some View {\n        NavigationView {', content_view_start)
    if body_start != -1:
        new_body = """    var body: some View {
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
        
        text = text[:body_start] + new_body + text[body_start + len('    var body: some View {\n        NavigationView {'):]


# 2. Inject KeyStatusCard at the end of the file
key_status_struct = """
struct KeyStatusCard: View {
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
text = text + key_status_struct


# 3. Add KeyStatusCard to the ContentView list
list_marker = """                        VStack(alignment: .leading, spacing: 16) {
                            Text("QUẢN LÝ APP")"""
new_list = """                        VStack(alignment: .leading, spacing: 16) {
                            KeyStatusCard()
                                .padding(.bottom, 8)
                            Text("QUẢN LÝ APP")"""
text = text.replace(list_marker, new_list)


# 4. Inject Logout button in CustomSettingsView
settings_env_marker = """struct CustomSettingsView: View {
    @Environment(\\.presentationMode) var presentationMode
    @State private var showLanguageAlert = false"""
new_settings_env = """struct CustomSettingsView: View {
    @Environment(\\.presentationMode) var presentationMode
    @EnvironmentObject private var licenseManager: LicenseManager
    @State private var showLanguageAlert = false"""
text = re.sub(r'struct CustomSettingsView: View \{\s*@Environment\(\\\.presentationMode\) var presentationMode\s*@State private var showLanguageAlert = false', 
              r'struct CustomSettingsView: View {\n    @Environment(\\.presentationMode) var presentationMode\n    @EnvironmentObject private var licenseManager: LicenseManager\n    @State private var showLanguageAlert = false', text)


settings_buttons_marker = """                        Button(action: { resetAllSettings() }) {
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
text = text.replace(settings_buttons_marker, new_settings_buttons)


# 5. Fix AppDetailView layout gap
app_detail_frame_marker = """            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)"""
new_app_detail_frame = """            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(.all, edges: .top)
            .padding(.top, 44) // Fix Navigation Bar gap
        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)"""
text = text.replace(app_detail_frame_marker, new_app_detail_frame)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updates applied safely.")
