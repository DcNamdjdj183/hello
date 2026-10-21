import Combine
import Foundation
import Security
import UIKit

// MARK: - Key Tiers Definition (4 Phân Hệ)
enum KeyTier: String, Codable {
    case all = "all"
    case aimlock = "aimlock"
    case sensitive = "sensitive"
    case regedit = "regedit"

    var displayName: String {
        switch self {
        case .all: return "VIP ALL (Trọn Bộ)"
        case .aimlock: return "AIMLOCK VIP"
        case .sensitive: return "SENSITIVE VIP"
        case .regedit: return "REGEDIT VIP"
        }
    }

    var badgeText: String {
        switch self {
        case .all: return "ALL ACCESS VIP"
        case .aimlock: return "AIMLOCK ONLY"
        case .sensitive: return "SENSITIVE ONLY"
        case .regedit: return "REGEDIT ONLY"
        }
    }
}

@MainActor
final class LicenseManager: ObservableObject {
    @Published private(set) var expirationDate: Date?
    @Published private(set) var isActive = false
    @Published private(set) var isBusy = false
    @Published private(set) var message: String?
    @Published private(set) var contactOwner: String?
    @Published var rememberKey = true
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var tier: KeyTier = .all
    @Published private(set) var tierName: String = "ALL ACCESS VIP"
    @Published private(set) var allowedModules: Set<String> = ["aimlock", "sensitive", "regedit"]

    private let service = "com.DNTWEAKS.external-ios.activation"
    private let keyAccount = "license-key"
    private let hwidAccount = "device-hwid"
    private let expiresAccount = "license-expires"
    private let tierAccount = "license-tier"
    private let modulesAccount = "license-allowed-modules"
    private var lastAttemptAt: Date?
    private var timer: Timer?

    // URL Máy chủ License Key mới (Cloudflare Worker D1)
    private let serverBaseURL = "https://dntweaks-key-server.ddnstore.workers.dev"

    init() {
        checkStoredKey()
    }

    private func checkStoredKey() {
        if let savedMods = string(for: modulesAccount), !savedMods.isEmpty {
            let list = savedMods.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            self.allowedModules = Set(list)
        } else if let savedTier = string(for: tierAccount), !savedTier.isEmpty {
            if savedTier == "all" {
                self.allowedModules = ["aimlock", "sensitive", "regedit"]
            } else {
                let list = savedTier.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                self.allowedModules = Set(list)
            }
        } else {
            self.allowedModules = ["aimlock", "sensitive", "regedit"]
        }

        if let savedTier = string(for: tierAccount), let parsed = KeyTier(rawValue: savedTier) {
            self.tier = parsed
            self.tierName = parsed.badgeText
        } else {
            self.tier = .all
            if allowedModules.count == 3 || allowedModules.contains("all") {
                self.tierName = "ALL ACCESS VIP"
            } else {
                self.tierName = allowedModules.map { $0.uppercased() }.joined(separator: " + ") + " VIP"
            }
        }

        if let savedKey = string(for: keyAccount), let expiresStr = string(for: expiresAccount) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            var expDate = formatter.date(from: expiresStr)
            if expDate == nil {
                let formatter2 = ISO8601DateFormatter()
                expDate = formatter2.date(from: expiresStr)
            }
            
            if let expDate = expDate {
                if Date() < expDate {
                    self.expirationDate = expDate
                    self.isActive = true
                    self.startTimer()
                } else {
                    self.isActive = false
                    self.delete(keyAccount)
                }
            } else {
                self.isActive = false
            }
        } else {
            self.isActive = false
        }
    }

    var hwid: String {
        if let saved = string(for: hwidAccount) {
            return saved
        }
        let newHwid = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        save(newHwid, for: hwidAccount)
        return newHwid
    }

    func beginLaunchSession() {
        checkStoredKey()
        message = isActive ? "Ready to use" : "Key required — enter your access key"
    }

    // Kiểm tra quyền kích hoạt các phân hệ (Aimlock, Sensitive, Regedit)
    func canAccess(category: ExternalCategory) -> Bool {
        guard isActive else { return false }
        if allowedModules.contains("all") { return true }
        return allowedModules.contains(category.rawValue.lowercased())
    }

    func canAccess(moduleName: String) -> Bool {
        guard isActive else { return false }
        let lower = moduleName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if allowedModules.contains("all") { return true }
        return allowedModules.contains(lower)
    }

    func activate(key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isBusy else { return }
        if let lastAttemptAt, Date().timeIntervalSince(lastAttemptAt) < 1 {
            message = "Vui lòng chờ một chút trước khi thử lại"
            return
        }
        lastAttemptAt = Date()
        isBusy = true
        message = "Đang kiểm tra bản quyền với máy chủ…"

        let upper = trimmed.uppercased()

        // Developer / Test Overrides
        if upper == "OGIOS" || upper == "DNTWEAKS" || upper == "VIP" || upper == "3105" || upper == "EXTERNAL-PRO" {
            let expDate = Calendar.current.date(byAdding: .year, value: 10, to: Date()) ?? Date()
            self.expirationDate = expDate
            self.isActive = true
            self.tier = .all
            self.tierName = "ALL ACCESS VIP (TRỌN BỘ)"
            self.allowedModules = ["aimlock", "sensitive", "regedit", "all"]
            self.message = "Kích hoạt quyền Master Developer VIP thành công!"
            self.isBusy = false
            if self.rememberKey {
                self.save(trimmed, for: self.keyAccount)
                let formatter = ISO8601DateFormatter()
                self.save(formatter.string(from: expDate), for: self.expiresAccount)
                self.save(self.tier.rawValue, for: self.tierAccount)
                self.save("aimlock,sensitive,regedit", for: self.modulesAccount)
            }
            self.startTimer()
            return
        }

        // Gọi Server Key dntweaks-key-server.ddnstore.workers.dev
        guard let url = URL(string: "\(serverBaseURL)/api/activate") else {
            self.isBusy = false
            self.message = "URL máy chủ không hợp lệ"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let payload: [String: Any] = ["key": trimmed, "hwid": hwid]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isBusy = false
                if let error = error {
                    self.message = "Lỗi kết nối máy chủ: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    self.message = "Không nhận được phản hồi từ server"
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let ok = (json["ok"] as? Bool) ?? (json["success"] as? Bool) ?? false
                        if ok {
                            // Phân giải Allowed Modules từ Server
                            if let modsList = json["allowedModules"] as? [String] {
                                self.allowedModules = Set(modsList.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() })
                            } else if let tierStr = json["tier"] as? String {
                                if tierStr == "all" {
                                    self.allowedModules = ["aimlock", "sensitive", "regedit"]
                                } else {
                                    let list = tierStr.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                                    self.allowedModules = Set(list)
                                }
                            } else {
                                self.allowedModules = ["aimlock", "sensitive", "regedit"]
                            }

                            // Phân giải loại Tier & Tên hiển thị từ Server
                            if let tierNameStr = json["tierName"] as? String {
                                self.tierName = tierNameStr
                            } else if self.allowedModules.contains("all") || self.allowedModules.count == 3 {
                                self.tierName = "ALL ACCESS VIP (TRỌN BỘ)"
                            } else {
                                let names = self.allowedModules.map { $0.uppercased() }.joined(separator: " + ")
                                self.tierName = "\(names) VIP"
                            }

                            if let tierStr = json["tier"] as? String, let parsedTier = KeyTier(rawValue: tierStr) {
                                self.tier = parsedTier
                            } else {
                                self.tier = self.allowedModules.count == 3 ? .all : (self.allowedModules.first == "aimlock" ? .aimlock : (self.allowedModules.first == "sensitive" ? .sensitive : .regedit))
                            }

                            if let expiresAt = json["expiresAt"] as? String {
                                let formatter = ISO8601DateFormatter()
                                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                                var expDate = formatter.date(from: expiresAt)
                                if expDate == nil {
                                    let formatter2 = ISO8601DateFormatter()
                                    expDate = formatter2.date(from: expiresAt)
                                }
                                
                                if let expDate = expDate {
                                    self.expirationDate = expDate
                                    self.isActive = true
                                    self.message = (json["message"] as? String) ?? "Kích hoạt thành công!"
                                    if self.rememberKey {
                                        self.save(trimmed, for: self.keyAccount)
                                        self.save(expiresAt, for: self.expiresAccount)
                                        self.save(self.tier.rawValue, for: self.tierAccount)
                                        let modsStr = Array(self.allowedModules).joined(separator: ",")
                                        self.save(modsStr, for: self.modulesAccount)
                                    }
                                    self.startTimer()
                                } else {
                                    self.message = "Ngày hết hạn từ máy chủ không hợp lệ"
                                }
                            } else {
                                // Default lifetime
                                let expDate = Calendar.current.date(byAdding: .year, value: 5, to: Date()) ?? Date()
                                self.expirationDate = expDate
                                self.isActive = true
                                self.message = (json["message"] as? String) ?? "Kích hoạt thành công!"
                                if self.rememberKey {
                                    self.save(trimmed, for: self.keyAccount)
                                    let formatter = ISO8601DateFormatter()
                                    self.save(formatter.string(from: expDate), for: self.expiresAccount)
                                    self.save(self.tier.rawValue, for: self.tierAccount)
                                    let modsStr = Array(self.allowedModules).joined(separator: ",")
                                    self.save(modsStr, for: self.modulesAccount)
                                }
                                self.startTimer()
                            }
                        } else {
                            let errMessage = (json["message"] as? String) ?? (json["error"] as? String) ?? "Key không hợp lệ!"
                            self.message = errMessage
                        }
                    }
                } catch {
                    self.message = "Lỗi đọc dữ liệu phản hồi từ máy chủ"
                }
            }
        }
        task.resume()
    }
    
    private func startTimer() {
        timer?.invalidate()
        updateRemaining()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRemaining()
        }
    }
    
    private func updateRemaining() {
        guard let exp = expirationDate else { return }
        let remain = Int(exp.timeIntervalSince(Date()))
        if remain <= 0 {
            remainingSeconds = 0
            timer?.invalidate()
            isActive = false
            delete(keyAccount)
            exit(0) // Crash/exit app as requested
        } else {
            remainingSeconds = remain
        }
    }

    func rememberedKey() -> String? { string(for: keyAccount) }

    func refresh() {
        checkStoredKey()
        message = isActive ? "Ready to use" : "Key required — enter your access key"
    }

    func deactivate() {
        delete(keyAccount)
        delete(expiresAccount)
        delete(tierAccount)
        delete(modulesAccount)
        isActive = false
        tier = .all
        tierName = "ALL ACCESS VIP"
        allowedModules = ["aimlock", "sensitive", "regedit"]
        message = "Đã đăng xuất key trên thiết bị này"
    }

    private func string(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func save(_ value: String, for account: String) {
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(base as CFDictionary)
        var item = base
        item[kSecValueData as String] = Data(value.utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(item as CFDictionary, nil)
    }

    private func delete(_ account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
