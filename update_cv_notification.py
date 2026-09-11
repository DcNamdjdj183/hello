import sys

path = 'ThreeOneOSFive/ContentView.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Add StateObject
if '@StateObject private var notificationManager' not in text:
    text = text.replace(
        '@StateObject private var licenseManager = LicenseManager()',
        '@StateObject private var licenseManager = LicenseManager()\n    @StateObject private var notificationManager = AppNotificationManager.shared'
    )

# 2. Add alert and onAppear/onReceive
old_bottom = """            patchMessage = message
        }
    }
}
"""
new_bottom = """            patchMessage = message
        }
    }
}
"""
if '.alert(isPresented: $notificationManager.showNotification)' not in text:
    # Need to inject at the end of the root view. Let's find `.sheet(isPresented: $showSettings) { SettingsView() }`
    text = text.replace(
        '.sheet(isPresented: $showSettings) { SettingsView() }',
        '.sheet(isPresented: $showSettings) { SettingsView() }\n        .alert(isPresented: $notificationManager.showNotification) {\n            Alert(\n                title: Text(notificationManager.notificationTitle),\n                message: Text(notificationManager.notificationMessage),\n                dismissButton: .default(Text("OK"))\n            )\n        }\n        .onAppear {\n            notificationManager.fetchNotification()\n        }\n        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in\n            notificationManager.fetchNotification()\n        }'
    )

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated ContentView.swift for Notifications')
