import SwiftUI

struct LicenseActivationView: View {
    @ObservedObject var manager: LicenseManager
    @State private var key = ""
    @FocusState private var keyFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedHyperBackdrop()
                    .ignoresSafeArea()

                Color.black.opacity(0.35)
                    .ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer(minLength: 40)

                            // Logo & Branding Header
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 76, height: 76)
                                        .overlay(Circle().stroke(Color.cyan.opacity(0.4), lineWidth: 1.5))
                                        .shadow(color: Color.cyan.opacity(0.3), radius: 15)

                                    Image(systemName: "bolt.shield.fill")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom))
                                }
                                .padding(.bottom, 6)

                                Text("EXTERNAL v2.0")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .tracking(2.5)
                                    .foregroundStyle(
                                        LinearGradient(colors: [.white, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .shadow(color: Color.cyan.opacity(0.45), radius: 10)

                                Text("AIMLOCK • SENSITIVE • REGEDIT SUITE")
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                                    .foregroundStyle(Color.cyan)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.cyan.opacity(0.12))
                                    .cornerRadius(6)

                                Text("Hệ Thống Tối Ưu Hóa & Trợ Năng Chuyên Nghiệp")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.55))
                                    .padding(.top, 2)
                            }

                            // Card Nhập Key
                            VStack(spacing: 16) {
                                HStack(spacing: 10) {
                                    Image(systemName: manager.isBusy ? "arrow.triangle.2.circlepath" : "key.fill")
                                        .foregroundStyle(Color.cyan)
                                        .font(.system(size: 16, weight: .bold))
                                    Text(manager.isBusy ? "Đang kết nối Server..." : "Yêu Cầu License Key")
                                        .font(.system(size: 15, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                    Spacer()
                                }

                                Text("Nhập mã bản quyền của bạn để mở khóa các phân hệ tính năng:")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.72))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Input Field
                                TextField("Ví dụ: DNT-ALL-XXXX-XXXX", text: $key)
                                    .focused($keyFocused)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                                    .submitLabel(.done)
                                    .onSubmit { activate() }
                                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .frame(height: 52)
                                    .background(Color.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color.cyan.opacity(0.4), lineWidth: 1))
                                    .id("license-field")

                                Toggle("Ghi nhớ key trên thiết bị này", isOn: $manager.rememberKey)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.72))
                                    .tint(Color.cyan)

                                // Button Kích Hoạt
                                Button(action: activate) {
                                    HStack(spacing: 9) {
                                        Image(systemName: manager.isBusy ? "hourglass" : "checkmark.shield.fill")
                                        Text(manager.isBusy ? "ĐANG XÁC THỰC..." : "KÍCH HOẠT NGAY")
                                    }
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(
                                        LinearGradient(colors: [Color.cyan, Color(red: 0.0, green: 0.85, blue: 0.95)], startPoint: .leading, endPoint: .trailing),
                                        in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    )
                                    .shadow(color: Color.cyan.opacity(0.35), radius: 12, y: 5)
                                }
                                .buttonStyle(.plain)
                                .disabled(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || manager.isBusy)
                                .opacity(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)

                                // Button Lấy Key Trực Tuyến
                                Button(action: {
                                    if let url = URL(string: "https://getkey-dnxtweaks.pages.dev/") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack(spacing: 9) {
                                        Image(systemName: "safari.fill")
                                            .foregroundColor(.cyan)
                                        Text("LẤY KEY MIỄN PHÍ (GET KEY)")
                                    }
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 1))
                                }
                                .buttonStyle(.plain)

                                // Message feedback
                                if let message = manager.message {
                                    Text(message)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(message.contains("thành công") ? Color.green : Color.red.opacity(0.95))
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(Color.black.opacity(0.3), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(message.contains("thành công") ? Color.green.opacity(0.4) : Color.red.opacity(0.4), lineWidth: 1))
                                }

                            }
                            .padding(20)
                            .background(Color(red: 0.05, green: 0.08, blue: 0.15).opacity(0.85), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.cyan.opacity(0.25), lineWidth: 1))
                            .padding(.horizontal, 22)
                            .padding(.top, 24)
                            .id("activation-card")

                            Spacer(minLength: 40)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 28)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func activate() {
        keyFocused = false
        manager.activate(key: key)
    }
}
