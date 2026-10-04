import io
import re

filepath = r"D:\hello-repo\ThreeOneOSFive\ContentView.swift"

with io.open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Hide Custom Tab Bar if tabs.count == 1
# Current: if !tabs.isEmpty { ... }
# Change to: if tabs.count > 1 { ... }
content = content.replace("if !tabs.isEmpty {", "if tabs.count > 1 {")

# 2. Reduce AppCardView padding
# Current: AppCardView(app: app)\n                      .padding(.bottom, 24)
content = content.replace("AppCardView(app: app)\n                      .padding(.bottom, 24)", 
                          "AppCardView(app: app)\n                      .padding(.bottom, 8)")

# 3. Reduce InteractiveSectionView spacing
# Current: VStack(spacing: 12) { ... ForEach(items, id: \.self)
content = content.replace("VStack(spacing: 12) {\n                  ForEach(items", 
                          "VStack(spacing: 8) {\n                  ForEach(items")

# 4. Reduce InteractiveRow padding
# Current: .padding()\n              .background(Color.white.opacity(0.05))
content = content.replace("              .padding()\n              .background(Color.white.opacity(0.05))", 
                          "              .padding(.vertical, 10)\n              .padding(.horizontal, 16)\n              .background(Color.white.opacity(0.05))")

# Let's fix the bad encoding in alert titles while we're here
content = content.replace("ThAnh cA'ng", "Thành công")
content = content.replace("ThAnh cA'ng", "Thành công")
content = content.replace("L-i", "Lỗi")
content = content.replace("B-t chcc nng thAnh cA'ng!", "Bật chức năng thành công!")
content = content.replace("Bt chcc nng thAnh cA'ng!", "Bật chức năng thành công!")

with io.open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated ContentView.swift for better spacing and encodings.")
