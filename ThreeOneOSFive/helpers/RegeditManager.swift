import Foundation
import SwiftUI
import UIKit

// MARK: - External Category (Aimlock, Sensitive, Regedit)
enum ExternalCategory: String, CaseIterable, Identifiable {
    case aimlock = "Aimlock"
    case sensitive = "Sensitive"
    case regedit = "Regedit"
    var id: String { rawValue }
}

// MARK: - External Preset Model
struct ExternalPreset: Identifiable, Hashable {
    let id: String
    let category: ExternalCategory
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

typealias RegeditPreset = ExternalPreset

// MARK: - 5 Aimlock Presets (V1 - V5)
let allAimlockPresets: [ExternalPreset] = [
    ExternalPreset(
        id: "aimlock_v1",
        category: .aimlock,
        level: 1,
        title: "Aimlock V1",
        subtitle: "Soft Assist & Chest Magnet",
        description: "Hỗ trợ kéo tâm nhẹ nhàng bám vùng ngực địch, ngăn tâm văng ra khỏi mục tiêu khi sấy liên thanh tầm gần.",
        icon: "scope",
        accentColor: Color(red: 0.0, green: 0.85, blue: 0.95), // Cyan
        defaultDelay: "0.02ms",
        defaultSensitivity: 1.15,
        xRatio: 1.10,
        yRatio: 1.20,
        tags: ["Soft Assist", "Chest Magnet", "Low FOV"]
    ),
    ExternalPreset(
        id: "aimlock_v2",
        category: .aimlock,
        level: 2,
        title: "Aimlock V2",
        subtitle: "Dynamic Scope Lock (Tầm Xa)",
        description: "Tự động căn chỉnh và ghim tâm mục tiêu khi mở ống ngắm (Scope 2x, 4x, Red Dot). Khử độ rung lắc súng trường.",
        icon: "target",
        accentColor: Color(red: 0.2, green: 0.65, blue: 1.0), // Blue
        defaultDelay: "0.01ms",
        defaultSensitivity: 1.35,
        xRatio: 1.25,
        yRatio: 1.40,
        tags: ["Scope Lock", "Sniper Drag", "Auto Track"]
    ),
    ExternalPreset(
        id: "aimlock_v3",
        category: .aimlock,
        level: 3,
        title: "Aimlock V3",
        subtitle: "Fast Flick Lock (Shotgun & SMG)",
        description: "Bám dính mục tiêu tức thì khi kéo tâm nhanh cận chiến (One Shot M1887, MP40). Snap tâm theo chuyển động lướt.",
        icon: "bolt.fill",
        accentColor: Color(red: 0.68, green: 0.35, blue: 1.0), // Purple
        defaultDelay: "0.005ms",
        defaultSensitivity: 1.60,
        xRatio: 1.40,
        yRatio: 1.70,
        tags: ["Fast Flick", "Shotgun Snap", "Close Combat"]
    ),
    ExternalPreset(
        id: "aimlock_v4",
        category: .aimlock,
        level: 4,
        title: "Aimlock V4",
        subtitle: "Headshot Lock 100% (Hitbox Magnet)",
        description: "Lực hút tâm cực mạnh vào Head Hitbox của đối thủ. Tâm ngực tự động nhảy thẳng lên đầu, triệt tiêu delay iOS.",
        icon: "flame.fill",
        accentColor: Color(red: 1.0, green: 0.45, blue: 0.1), // Orange
        defaultDelay: "0.001ms",
        defaultSensitivity: 1.85,
        xRatio: 1.55,
        yRatio: 2.05,
        tags: ["Headshot 100%", "Hitbox Magnet", "Zero Spread"]
    ),
    ExternalPreset(
        id: "aimlock_v5",
        category: .aimlock,
        level: 5,
        title: "Aimlock V5",
        subtitle: "Quantum Master Lock (God Mode Aim)",
        description: "Khóa cứng tâm vào đầu đối thủ bất chấp di chuyển tốc độ cao. Đồng bộ tracking từng frame ProMotion 120 FPS.",
        icon: "crown.fill",
        accentColor: Color(red: 1.0, green: 0.84, blue: 0.0), // Gold
        defaultDelay: "ZERO DELAY",
        defaultSensitivity: 2.25,
        xRatio: 1.85,
        yRatio: 2.45,
        tags: ["God Mode Lock", "120FPS Quantum", "Silent Snap"]
    )
]

// MARK: - 5 Sensitive Presets (V1 - V5)
let allSensitivePresets: [ExternalPreset] = [
    ExternalPreset(
        id: "sensitive_v1",
        category: .sensitive,
        level: 1,
        title: "Sensitive V1",
        subtitle: "Anti-Shake & Smooth Touch",
        description: "Khử nhiễu rung lắc ngón tay trên màn hình cảm ứng, làm mịn đường vuốt tâm khi sấy đạn liên thanh.",
        icon: "hand.tap.fill",
        accentColor: Color(red: 0.0, green: 0.9, blue: 0.75), // Mint Green
        defaultDelay: "0.02ms",
        defaultSensitivity: 1.15,
        xRatio: 1.10,
        yRatio: 1.20,
        tags: ["Anti-Shake", "Smooth Touch", "Filter Noise"]
    ),
    ExternalPreset(
        id: "sensitive_v2",
        category: .sensitive,
        level: 2,
        title: "Sensitive V2",
        subtitle: "Mid-Range Velocity Boost",
        description: "Gia tốc đường vuốt tâm tầm trung mượt mà, hỗ trợ xoay chuyển góc nhìn camera siêu nhạy và ổn định.",
        icon: "gauge.badge.plus",
        accentColor: Color(red: 0.1, green: 0.75, blue: 1.0), // Sky Blue
        defaultDelay: "0.01ms",
        defaultSensitivity: 1.35,
        xRatio: 1.25,
        yRatio: 1.45,
        tags: ["Velocity Boost", "Mid Range", "Smooth Drag"]
    ),
    ExternalPreset(
        id: "sensitive_v3",
        category: .sensitive,
        level: 3,
        title: "Sensitive V3",
        subtitle: "240Hz High Sampling Rate",
        description: "Đẩy tần số quét điểm chạm cảm ứng màn hình lên 240Hz, phản hồi cử chỉ vuốt ngón tay tức thì.",
        icon: "speedometer",
        accentColor: Color(red: 0.55, green: 0.45, blue: 1.0), // Indigo
        defaultDelay: "0.005ms",
        defaultSensitivity: 1.60,
        xRatio: 1.40,
        yRatio: 1.75,
        tags: ["240Hz Touch", "Instant Drag", "Multi-Touch"]
    ),
    ExternalPreset(
        id: "sensitive_v4",
        category: .sensitive,
        level: 4,
        title: "Sensitive V4",
        subtitle: "Ultra Drag Multiplier (Siêu Nhạy)",
        description: "Nhân hệ số độ nhạy vuốt tâm cực hạn x1.85, vuốt nhẹ tâm tự động bay lên đầu, không bị nghẽn tâm ở ngực.",
        icon: "bolt.horizontal.fill",
        accentColor: Color(red: 1.0, green: 0.35, blue: 0.35), // Red
        defaultDelay: "0.001ms",
        defaultSensitivity: 1.85,
        xRatio: 1.60,
        yRatio: 2.15,
        tags: ["Ultra Drag", "High Sens", "Chest Bypass"]
    ),
    ExternalPreset(
        id: "sensitive_v5",
        category: .sensitive,
        level: 5,
        title: "Sensitive V5",
        subtitle: "Zero Delay ProMotion Uncapped",
        description: "Mở khóa giới hạn phần cứng cảm ứng màn hình Apple ProMotion 120Hz, triệt tiêu hoàn toàn độ trễ cảm ứng.",
        icon: "flame.circle.fill",
        accentColor: Color(red: 1.0, green: 0.75, blue: 0.0), // Amber
        defaultDelay: "ZERO DELAY",
        defaultSensitivity: 2.25,
        xRatio: 1.90,
        yRatio: 2.50,
        tags: ["Uncapped Touch", "ProMotion 120Hz", "Zero Latency"]
    )
]

// MARK: - 5 Regedit Presets (V1 - V5)
let allRegeditSubPresets: [ExternalPreset] = [
    ExternalPreset(
        id: "regedit_v1",
        category: .regedit,
        level: 1,
        title: "Regedit V1",
        subtitle: "Smooth Touch & Chống Rung Cảm Ứng",
        description: "Tối ưu hóa bảng thanh ghi độ trễ cảm ứng màn hình, lọc nhiễu ngón tay khi rê tâm, giảm rung lắc súng.",
        icon: "slider.horizontal.3",
        accentColor: Color(red: 0.0, green: 0.85, blue: 0.95), // Cyan
        defaultDelay: "0.02ms",
        defaultSensitivity: 1.15,
        xRatio: 1.10,
        yRatio: 1.15,
        tags: ["Anti-Shake", "Touch Register", "Latency Fix"]
    ),
    ExternalPreset(
        id: "regedit_v2",
        category: .regedit,
        level: 2,
        title: "Regedit V2",
        subtitle: "Aim Assist Registry (Long-Range Drag)",
        description: "Gia tốc đường vuốt tâm tầm xa qua thanh ghi tọa độ Y. Chuẩn hóa đường đạn cho súng trường và Sniper.",
        icon: "cross.circle.fill",
        accentColor: Color(red: 0.2, green: 0.65, blue: 1.0), // Blue
        defaultDelay: "0.01ms",
        defaultSensitivity: 1.30,
        xRatio: 1.20,
        yRatio: 1.35,
        tags: ["Long Range", "Sniper Drag", "Register Pacing"]
    ),
    ExternalPreset(
        id: "regedit_v3",
        category: .regedit,
        level: 3,
        title: "Regedit V3",
        subtitle: "Fast Drag Shot (Shotgun & SMG)",
        description: "Thanh ghi gia tốc vuốt tâm cận chiến siêu tốc, vuốt nhẹ lên đầu (One Shot M1887/MP40). Lấy mẫu đa ngón 240Hz.",
        icon: "wand.and.stars",
        accentColor: Color(red: 0.65, green: 0.35, blue: 0.95), // Purple
        defaultDelay: "0.005ms",
        defaultSensitivity: 1.55,
        xRatio: 1.35,
        yRatio: 1.65,
        tags: ["Shotgun One-Shot", "Rapid Register", "240Hz Sampling"]
    ),
    ExternalPreset(
        id: "regedit_v4",
        category: .regedit,
        level: 4,
        title: "Regedit V4",
        subtitle: "Headshot Lock 100% (Ultra Hitbox Matrix)",
        description: "Ghi đè ma trận hút Head Hitbox trong Sandbox, triệt tiêu delay cảm ứng iOS, giữ tâm ngực nhảy thẳng lên đầu.",
        icon: "burst.fill",
        accentColor: Color(red: 1.0, green: 0.45, blue: 0.1), // Orange
        defaultDelay: "0.001ms",
        defaultSensitivity: 1.80,
        xRatio: 1.50,
        yRatio: 1.95,
        tags: ["Headshot 100%", "Zero Delay", "Hitbox Matrix"]
    ),
    ExternalPreset(
        id: "regedit_v5",
        category: .regedit,
        level: 5,
        title: "Regedit V5",
        subtitle: "Quantum Master VIP (God Mode Aim)",
        description: "Bản tối thượng tích hợp toàn bộ V1-V4: Siêu nhạy 120FPS ProMotion Streaming, phá vỡ giới hạn cảm ứng phần cứng.",
        icon: "sparkles",
        accentColor: Color(red: 1.0, green: 0.84, blue: 0.0), // Gold
        defaultDelay: "ZERO DELAY",
        defaultSensitivity: 2.10,
        xRatio: 1.80,
        yRatio: 2.30,
        tags: ["120FPS Quantum", "God Mode", "Uncapped Touch"]
    )
]

let allExternalPresets: [ExternalPreset] = allAimlockPresets + allSensitivePresets + allRegeditSubPresets
let allRegeditPresets: [ExternalPreset] = allExternalPresets

// MARK: - External iOS Manager Service
@MainActor
final class RegeditManager: ObservableObject {
    static let shared = RegeditManager()

    @Published private(set) var activePresets: Set<String> = []
    @Published var customSensitivities: [String: Double] = [:]

    private let defaults = UserDefaults.standard
    private let activeKeyPrefix = "EXTERNAL_IOS_Active_"
    private let sensKeyPrefix = "EXTERNAL_IOS_Sens_"

    init() {
        loadSettings()
    }

    func loadSettings() {
        var loaded: Set<String> = []
        var sens: [String: Double] = [:]
        for preset in allExternalPresets {
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
        objectWillChange.send()
    }

    func toggle(preset: ExternalPreset, for bundleId: String? = nil) -> Bool {
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

        applyTarget(preset: preset, isEnabled: newState, bundleId: bundleId)
        objectWillChange.send()
        return newState
    }

    // Aimlock Bulk Controls
    func activateAllAimlock(for bundleId: String? = nil) {
        for preset in allAimlockPresets {
            let key = specificKey(presetId: preset.id, bundleId: bundleId)
            defaults.set(true, forKey: key)
            if bundleId == nil { activePresets.insert(preset.id) }
            applyTarget(preset: preset, isEnabled: true, bundleId: bundleId)
        }
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        objectWillChange.send()
    }

    func resetAllAimlock(for bundleId: String? = nil) {
        for preset in allAimlockPresets {
            let key = specificKey(presetId: preset.id, bundleId: bundleId)
            defaults.set(false, forKey: key)
            if bundleId == nil { activePresets.remove(preset.id) }
            applyTarget(preset: preset, isEnabled: false, bundleId: bundleId)
        }
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.warning)
        objectWillChange.send()
    }

    // Sensitive Bulk Controls
    func activateAllSensitive(for bundleId: String? = nil) {
        for preset in allSensitivePresets {
            let key = specificKey(presetId: preset.id, bundleId: bundleId)
            defaults.set(true, forKey: key)
            if bundleId == nil { activePresets.insert(preset.id) }
            applyTarget(preset: preset, isEnabled: true, bundleId: bundleId)
        }
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        objectWillChange.send()
    }

    func resetAllSensitive(for bundleId: String? = nil) {
        for preset in allSensitivePresets {
            let key = specificKey(presetId: preset.id, bundleId: bundleId)
            defaults.set(false, forKey: key)
            if bundleId == nil { activePresets.remove(preset.id) }
            applyTarget(preset: preset, isEnabled: false, bundleId: bundleId)
        }
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.warning)
        objectWillChange.send()
    }

    // Regedit Bulk Controls
    func activateAllRegedit(for bundleId: String? = nil) {
        for preset in allRegeditSubPresets {
            let key = specificKey(presetId: preset.id, bundleId: bundleId)
            defaults.set(true, forKey: key)
            if bundleId == nil { activePresets.insert(preset.id) }
            applyTarget(preset: preset, isEnabled: true, bundleId: bundleId)
        }
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        objectWillChange.send()
    }

    func resetAllRegedit(for bundleId: String? = nil) {
        for preset in allRegeditSubPresets {
            let key = specificKey(presetId: preset.id, bundleId: bundleId)
            defaults.set(false, forKey: key)
            if bundleId == nil { activePresets.remove(preset.id) }
            applyTarget(preset: preset, isEnabled: false, bundleId: bundleId)
        }
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.warning)
        objectWillChange.send()
    }

    // Master Controls (All 15 Presets)
    func activateAll(for bundleId: String? = nil) {
        for preset in allExternalPresets {
            let key = specificKey(presetId: preset.id, bundleId: bundleId)
            defaults.set(true, forKey: key)
            if bundleId == nil {
                activePresets.insert(preset.id)
            }
            applyTarget(preset: preset, isEnabled: true, bundleId: bundleId)
        }
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        objectWillChange.send()
    }

    func resetAll(for bundleId: String? = nil) {
        for preset in allExternalPresets {
            let key = specificKey(presetId: preset.id, bundleId: bundleId)
            defaults.set(false, forKey: key)
            if bundleId == nil {
                activePresets.remove(preset.id)
            }
            applyTarget(preset: preset, isEnabled: false, bundleId: bundleId)
        }
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.warning)
        objectWillChange.send()
    }

    func activeAimlockCount(for bundleId: String? = nil) -> Int {
        allAimlockPresets.filter { isEnabled(presetId: $0.id, for: bundleId) }.count
    }

    func activeSensitiveCount(for bundleId: String? = nil) -> Int {
        allSensitivePresets.filter { isEnabled(presetId: $0.id, for: bundleId) }.count
    }

    func activeRegeditCount(for bundleId: String? = nil) -> Int {
        allRegeditSubPresets.filter { isEnabled(presetId: $0.id, for: bundleId) }.count
    }

    private func applyTarget(preset: ExternalPreset, isEnabled: Bool, bundleId: String?) {
        if let bundleId = bundleId {
            applyExternalToContainer(preset: preset, isEnabled: isEnabled, bundleId: bundleId)
        } else {
            for target in defaultAppTargets {
                applyExternalToContainer(preset: preset, isEnabled: isEnabled, bundleId: target.bundleId)
            }
        }
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
        for preset in allExternalPresets {
            let active = isEnabled(presetId: preset.id, for: bundleId)
            applyExternalToContainer(preset: preset, isEnabled: active, bundleId: bundleId)
        }
        return (true, "Đã đồng bộ thành công cấu hình EXTERNAL IOS (Aimlock, Sensitive & Regedit) vào Container của ứng dụng!")
    }

    // MARK: - Internal Tweak Injector via ContainerStore
    private func applyExternalToContainer(preset: ExternalPreset, isEnabled: Bool, bundleId: String) {
        guard let containerPath = ContainerStore.resolveAppContainerPath(bundleID: bundleId) else { return }

        let fm = FileManager.default
        let docsPath = (containerPath as NSString).appendingPathComponent("Documents")
        let prefsPath = ((containerPath as NSString).appendingPathComponent("Library") as NSString).appendingPathComponent("Preferences")

        let externalConfigFile = (docsPath as NSString).appendingPathComponent("DNTWEAKS_ExternalIOS.plist")
        let legacyConfigFile = (docsPath as NSString).appendingPathComponent("DNTWEAKS_Regedit.plist")

        if isEnabled {
            var configDict: [String: Any] = (NSDictionary(contentsOfFile: externalConfigFile) as? [String: Any]) ?? [:]
            let sens = sensitivity(presetId: preset.id, for: bundleId)

            let presetData: [String: Any] = [
                "category": preset.category.rawValue,
                "level": preset.level,
                "title": preset.title,
                "sensitivity": sens,
                "x_ratio": preset.xRatio,
                "y_ratio": preset.yRatio,
                "touch_delay": preset.defaultDelay,
                "enabled_at": Date().description,
                "engine": "EXTERNAL_IOS_v2.0"
            ]

            configDict[preset.id] = presetData
            configDict["EXTERNAL_IOS_ACTIVE"] = true
            configDict["LAST_MODIFIED"] = Date().timeIntervalSince1970

            let nsDict = NSDictionary(dictionary: configDict)
            nsDict.write(toFile: externalConfigFile, atomically: true)
            nsDict.write(toFile: legacyConfigFile, atomically: true)

            let tweakPrefsFile = (prefsPath as NSString).appendingPathComponent("\(bundleId).external.plist")
            nsDict.write(toFile: tweakPrefsFile, atomically: true)
        } else {
            if var configDict = NSDictionary(contentsOfFile: externalConfigFile) as? [String: Any] {
                configDict.removeValue(forKey: preset.id)
                if configDict.keys.filter({ $0.starts(with: "aimlock_") || $0.starts(with: "sensitive_") || $0.starts(with: "regedit_") }).isEmpty {
                    configDict["EXTERNAL_IOS_ACTIVE"] = false
                    try? fm.removeItem(atPath: externalConfigFile)
                    try? fm.removeItem(atPath: legacyConfigFile)
                } else {
                    let nsDict = NSDictionary(dictionary: configDict)
                    nsDict.write(toFile: externalConfigFile, atomically: true)
                    nsDict.write(toFile: legacyConfigFile, atomically: true)
                }
            }
        }
    }
}
