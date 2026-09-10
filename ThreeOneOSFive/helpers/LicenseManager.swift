import Combine
import Foundation
import Security
import UIKit

@MainActor
final class LicenseManager: ObservableObject {
    @Published private(set) var expirationDate: Date?
    @Published private(set) var isActive = false
    @Published private(set) var isBusy = false
    @Published private(set) var message: String?
    @Published private(set) var contactOwner: String?
    @Published var rememberKey = true
    @Published private(set) var remainingSeconds: Int = 0

    private let service = "com.DNXTWEAKS.external-ios.activation"
    private let keyAccount = "license-key"
    private let hwidAccount = "device-hwid"
    private let expiresAccount = "license-expires"
    private var lastAttemptAt: Date?
    private var timer: Timer?

    init() {
        checkStoredKey()
    }

    private func checkStoredKey() {
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

    func activate(key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isBusy else { return }
        if let lastAttemptAt, Date().timeIntervalSince(lastAttemptAt) < 1 {
            message = "Please wait a moment before trying again"
            return
        }
        lastAttemptAt = Date()
        isBusy = true
        message = "Checking access key…"

        guard let url = URL(string: "https://ddnkey.ddnstore.workers.dev/api/activate") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = ["key": trimmed, "hwid": hwid]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isBusy = false
                if let error = error {
                    self.message = "Network error: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    self.message = "No data from server"
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let ok = json["ok"] as? Bool ?? false
                        if ok {
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
                                    self.message = "Activated successfully"
                                    if self.rememberKey {
                                        self.save(trimmed, for: self.keyAccount)
                                        self.save(expiresAt, for: self.expiresAccount)
                                    }
                                    self.startTimer()
                                } else {
                                    self.message = "Invalid date from server"
                                }
                            }
                        } else {
                            let errMessage = json["error"] as? String ?? "Invalid key"
                            self.message = errMessage
                        }
                    }
                } catch {
                    self.message = "Invalid server response"
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
        isActive = false
        message = "Activation removed from this device"
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
