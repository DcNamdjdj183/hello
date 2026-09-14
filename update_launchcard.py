import sys

with open("ThreeOneOSFive/ContentView.swift", "r", encoding="utf-8") as f:
    text = f.read()

old_launch = """            Button(action: { showCleaner = true }) {
                HStack {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                    Text("Clean Cache & Logs")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }"""

new_launch = """            Button(action: { showCleaner = true }) {
                HStack {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                    Text("Clean Cache")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            
            Button(action: { NotificationCenter.default.post(name: NSNotification.Name("ShowLogView"), object: nil) }) {
                HStack {
                    Image(systemName: "doc.text.viewfinder")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("View System Logs")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }"""

if old_launch in text:
    text = text.replace(old_launch, new_launch)
    with open("ThreeOneOSFive/ContentView.swift", "w", encoding="utf-8") as f:
        f.write(text)
    print("Updated LaunchCard")
else:
    print("old_launch not found in ContentView.swift")
