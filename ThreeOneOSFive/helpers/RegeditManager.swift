import Foundation
import SwiftUI
import UIKit

// MARK: - Regedit Preset Model
struct RegeditPreset: Identifiable, Hashable {
    let id: String
    let level: Int
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let accentColor: Color
    let defaultDelay: String
    let defaultSensitivity: Double // 1.0 = 100%
    let xRatio: Double
    let yRatio: Double
    let tags: [String]
}

let allRegeditPresets: [RegeditPreset] = [
    RegeditPreset(
        id: "regedit_v1",
        level: 1,
        title: "Regedit V1",
        subtitle: "Smooth Touch & Chống Rung Cảm Ứng",
        description: "Tối ưu hóa độ trễ cảm ứng màn hình, lọc nhiễu ngón tay khi rê tâm, giảm rung lắc súng khi sấy tầm gần.",
        icon: "hand.tap.fill",
        accentColor: Color(red: 0.0, green: 0.85, blue: 0.95), // Cyan
        defaultDelay: "0.02ms",
        defaultSensitivity: 1.15,
        xRatio: 1.1,
        yRatio: 1.15,
        tags: ["Anti-Shake", "Smooth Drag", "Latency Fix"]
    ),
    RegeditPreset(
        id: "regedit_v2",
        level: 2,
        title: "Regedit V2",
        subtitle: "Aim Lock Tầm Xa (Long-Range Drag)",
        description: "Gia tốc đường vuốt tâm tầm trung và xa. Chuẩn hóa gia số tọa độ Y, hỗ trợ súng trường và súng ngắm (Sniper/Rifle).",
        icon: "scope",
        accentColor: Color(red: 0.2, green: 0.7, blue: 1.0), // Blue
        defaultDelay: "0.01ms",
        defaultSensitivity: 1.30,
        xRatio: 1.2,
        yRatio: 1.35,
        tags: ["Long Range", "Sniper Drag", "Auto Pacing"]
    ),
    RegeditPreset(
        id: "regedit_v3",
        level: 3,
        title: "Regedit V3",
        subtitle: "Fast Drag Shot (Shotgun & SMG)",
        description: "Tăng mạnh độ nhạy kéo tâm cận chiến, vuốt nhẹ lên đầu (One Shot M1887 / MP40). Tối ưu hóa điểm chạm đa ngón 240Hz.",
        icon: "bolt.fill",
        accentColor: Color(red: 0.65, green: 0.35, blue: 0.95), // Purple
        defaultDelay: "0.005ms",
        defaultSensitivity: 1.55,
        xRatio: 1.35,
        yRatio: 1.65,
        tags: ["Shotgun One-Shot", "SMG Rapid", "240Hz Sampling"]
    ),
    RegeditPreset(
        id: "regedit_v4",
        level: 4,
        title: "Regedit V4",
        subtitle: "Headshot Lock 100% (Ultra Magnet)",
        description: "Khóa tâm vào vùng đầu (Head Hitbox Attraction Matrix), triệt tiêu hoàn toàn delay cảm ứng iOS, giữ tâm ngực nhảy thẳng lên đầu.",
        icon: "flame.fill",
        accentColor: Color(red: 1.0, green: 0.45, blue: 0.1), // Orange
        defaultDelay: "0.001ms",
        defaultSensitivity: 1.80,
        xRatio: 1.5,
        yRatio: 1.95,
        tags: ["Headshot 100%", "Zero Delay", "Hitbox Magnet"]
    ),
    RegeditPreset(
        id: "regedit_v5",
        level: 5,
        title: "Regedit V5",
        subtitle: "Quantum Master VIP (God Mode Aim)",
        description: "Bản tối thượng tích hợp toàn bộ V1-V4: Siêu nhạy 120FPS ProMotion Streaming, tự động ghìm đầu, phá bỏ giới hạn phần cứng cảm ứng màn hình.",
        icon: "crown.fill",
        accentColor: Color(red: 1.0, green: 0.84, blue: 0.0), // Gold
        defaultDelay: "ZERO DELAY",
        defaultSensitivity: 2.10,
        xRatio: 1.8,
        yRatio: 2.3,
        tags: ["120FPS Quantum", "God Mode", "Uncapped Touch"]
    )
]

// MARK: - Regedit Manager Service
@MainActor
final class RegeditManager: ObservableObject {
    static let shared = RegeditManager()

    @Published private(set) var activePresets: Set<String> = []
    @Published var customSensitivities: [String: Double] = [:]

    private let defaults = UserDefaults.standard
    private let activeKeyPrefix = "DNTWEAKS_Regedit_Active_"
    private let sensKeyPrefix = "DNTWEAKS_Regedit_Sens_"

    init() {
        loadSettings()
    }

    func loadSettings() {
        var loaded: Set<String> = []
        var sens: [String: Double] = [:]
        for preset in allRegeditPresets {
            if defaults.bool(forKey: activeKeyPrefix + preset.id) {
                loaded.insert(preset.id)
            }
            let savedSens = defaults.double(forKey: sensKeyPrefix + preset.id)
            sens[preset.id] = savedSens > 0 ? savedSens : preset.defaultSensitivity
        }
        self.activePresets = loaded
        self.customSensitivities = sens
    }

    func isEnabled(presetId: String, for bundleId: String? = nil) -> Bool {
        let key = specificKey(presetId: presetId, bundleId: bundleId)
        return defaults.bool(forKey: key)
    }

    func sensitivity(presetId: String, for bundleId: String? = nil) -> Double {
        let key = sensKeyPrefix + (bundleId ?? "global") + "_" + presetId
        let saved = defaults.double(forKey: key)
        if saved > 0 { return saved }
        return customSensitivities[presetId] ?? 1.0
    }

    func setSensitivity(_ value: Double, presetId: String, for bundleId: String? = nil) {
        customSensitivities[presetId] = value
        let key = sensKeyPrefix + (bundleId ?? "global") + "_" + presetId
        defaults.set(value, forKey: key)
    }

    func toggle(preset: RegeditPreset, for bundleId: String? = nil) -> Bool {
        let key = specificKey(presetId: preset.id, bundleId: bundleId)
        let currentlyActive = defaults.bool(forKey: key)
        let newState = !currentlyActive

        defaults.set(newState, forKey: key)
        if bundleId == nil {
            if newState {
                activePresets.insert(preset.id)
            } else {
                activePresets.remove(preset.id)
            }
        }

        // Haptic Feedback
        let feedback = UIImpactFeedbackGenerator(style: newState ? .heavy : .light)
        feedback.impactOccurred()

        // Apply Regedit tweak into game container if bundleId is available
        if let bundleId = bundleId {
            applyRegeditToContainer(preset: preset, isEnabled: newState, bundleId: bundleId)
        } else {
            // Apply globally to all default games
            for target in defaultAppTargets {
                applyRegeditToContainer(preset: preset, isEnabled: newState, bundleId: target.bundleId)
            }
        }

        objectWillChange.send()
        return newState
    }

    func activateAll(for bundleId: String? = nil) {
        for preset in allRegeditPresets {
            let key = specificKey(presetId: preset.id, bundleId: bundleId)
            defaults.set(true, forKey: key)
            if bundleId == nil {
                activePresets.insert(preset.id)
            }
            if let bundleId = bundleId {
                applyRegeditToContainer(preset: preset, isEnabled: true, bundleId: bundleId)
            } else {
                for target in defaultAppTargets {
                    applyRegeditToContainer(preset: preset, isEnabled: true, bundleId: target.bundleId)
                }
            }
        }
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        objectWillChange.send()
    }

    func resetAll(for bundleId: String? = nil) {
        for preset in allRegeditPresets {
            let key = specificKey(presetId: preset.id, bundleId: bundleId)
            defaults.set(false, forKey: key)
            if bundleId == nil {
                activePresets.remove(preset.id)
            }
            if let bundleId = bundleId {
                applyRegeditToContainer(preset: preset, isEnabled: false, bundleId: bundleId)
            } else {
                for target in defaultAppTargets {
                    applyRegeditToContainer(preset: preset, isEnabled: false, bundleId: target.bundleId)
                }
            }
        }
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.warning)
        objectWillChange.send()
    }

    private func specificKey(presetId: String, bundleId: String?) -> String {
        if let bundleId = bundleId {
            return activeKeyPrefix + bundleId + "_" + presetId
        }
        return activeKeyPrefix + presetId
    }

    @discardableResult
    func syncContainer(bundleId: String) -> (success: Bool, message: String) {
        guard let _ = ContainerStore.resolveAppContainerPath(bundleID: bundleId) else {
            return (false, "Không tìm thấy thư mục Sandbox Container của \(bundleId). Vui lòng mở game một lần rồi thử lại.")
        }
        for preset in allRegeditPresets {
            let active = isEnabled(presetId: preset.id, for: bundleId)
            applyRegeditToContainer(preset: preset, isEnabled: active, bundleId: bundleId)
        }
        return (true, "Đã đồng bộ thành công cấu hình Regedit vào Container của ứng dụng!")
    }

    // MARK: - Internal Tweak Injector via ContainerStore
    private func applyRegeditToContainer(preset: RegeditPreset, isEnabled: Bool, bundleId: String) {
        guard let containerPath = ContainerStore.resolveAppContainerPath(bundleID: bundleId) else { return }

        let fm = FileManager.default
        let docsPath = (containerPath as NSString).appendingPathComponent("Documents")
        let prefsPath = ((containerPath as NSString).appendingPathComponent("Library") as NSString).appendingPathComponent("Preferences")

        let regeditConfigFile = (docsPath as NSString).appendingPathComponent("DNTWEAKS_Regedit.plist")

        if isEnabled {
            var configDict: [String: Any] = (NSDictionary(contentsOfFile: regeditConfigFile) as? [String: Any]) ?? [:]
            let sens = sensitivity(presetId: preset.id, for: bundleId)

            let presetData: [String: Any] = [
                "level": preset.level,
                "title": preset.title,
                "sensitivity": sens,
                "x_ratio": preset.xRatio,
                "y_ratio": preset.yRatio,
                "touch_delay": preset.defaultDelay,
                "enabled_at": Date().description,
                "engine": "3105_v2.0"
            ]

            configDict[preset.id] = presetData
            configDict["DNTWEAKS_ACTIVE"] = true
            configDict["LAST_MODIFIED"] = Date().timeIntervalSince1970

            let nsDict = NSDictionary(dictionary: configDict)
            nsDict.write(toFile: regeditConfigFile, atomically: true)

            // Also mirror basic tweaks to Library/Preferences if possible
            let tweakPrefsFile = (prefsPath as NSString).appendingPathComponent("\(bundleId).regedit.plist")
            nsDict.write(toFile: tweakPrefsFile, atomically: true)
        } else {
            if var configDict = NSDictionary(contentsOfFile: regeditConfigFile) as? [String: Any] {
                configDict.removeValue(forKey: preset.id)
                if configDict.keys.filter({ $0.starts(with: "regedit_") }).isEmpty {
                    configDict["DNTWEAKS_ACTIVE"] = false
                    try? fm.removeItem(atPath: regeditConfigFile)
                } else {
                    let nsDict = NSDictionary(dictionary: configDict)
                    nsDict.write(toFile: regeditConfigFile, atomically: true)
                }
            }
        }
    }
}
