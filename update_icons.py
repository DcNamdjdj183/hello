import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# Update mockApps
text = text.replace('AppTarget(name: "Free Fire", bundleId: "com.dts.freefireth", iconName: "gamecontroller.fill")',
                    'AppTarget(name: "Free Fire", bundleId: "com.dts.freefireth", iconName: "icon_ffth")')
text = text.replace('AppTarget(name: "Free Fire MAX", bundleId: "com.dts.freefiremax", iconName: "gamecontroller.fill")',
                    'AppTarget(name: "Free Fire MAX", bundleId: "com.dts.freefiremax", iconName: "icon_ffmax")')
text = text.replace('AppTarget(name: "PUBG Mobile", bundleId: "com.vng.pubgmobile", iconName: "gamecontroller.fill")',
                    'AppTarget(name: "PUBG Mobile", bundleId: "com.vng.pubgmobile", iconName: "icon_pubg")')
text = text.replace('AppTarget(name: "Liên Quân Mobile", bundleId: "com.garena.game.kgvn", iconName: "gamecontroller.fill")',
                    'AppTarget(name: "Liên Quân Mobile", bundleId: "com.garena.game.kgvn", iconName: "icon_lq")')
text = text.replace('AppTarget(name: "CapCut", bundleId: "com.lemon.lvoverseas", iconName: "video.fill")',
                    'AppTarget(name: "CapCut", bundleId: "com.lemon.lvoverseas", iconName: "icon_capcut")')

# Update AppCardView
old_image = """            Image(systemName: app.iconName)
                .font(.system(size: 24))
                .foregroundColor(.cyan)
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)"""

new_image = """            Image(app.iconName)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))"""

text = text.replace(old_image, new_image)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Icons updated in UI")
