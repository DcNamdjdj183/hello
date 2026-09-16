import os
import re

cv_path = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\ContentView.swift'

with open(cv_path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Update the Admin Zalo link and text
text = text.replace('http://zalo.me/0395109314', 'http://zalo.me/0846260109')

# 2. Remove the "Nhóm Thông Báo" block
# We will use regex to find and remove the block starting with `HStack {` and ending after its closing brace, specifically around "Nhóm Thông Báo".
# The block looks like:
#                        HStack {
#                            Image(systemName: "bell.badge.fill")
#                            ...
#                        }

pattern = r'\s*HStack\s*\{\s*Image\(systemName:\s*"bell\.badge\.fill"\)[\s\S]*?Text\("Nhóm Thông Báo"\)[\s\S]*?\}\s*\}\s*\}'
# Actually, the block is:
#                        HStack {
#                            Image(systemName: "bell.badge.fill")
#                            ...
#                            Button(action: {
#                                if let url = URL(string: "https://zalo.me/g/miuatq2xhhh0tarsc3me") { UIApplication.shared.open(url) }
#                            }) {
#                                Image(systemName: "chevron.right")
#                                ...
#                            }
#                        }

# Let's find exactly the range of the HStack to remove.
start_str = 'Image(systemName: "bell.badge.fill")'
idx = text.find(start_str)

if idx != -1:
    # Find the preceding HStack
    start_idx = text.rfind('HStack {', 0, idx)
    if start_idx != -1:
        # Find the closing brace of this HStack
        # We need to count braces to find the matching one.
        brace_count = 0
        end_idx = -1
        for i in range(start_idx, len(text)):
            if text[i] == '{':
                brace_count += 1
            elif text[i] == '}':
                brace_count -= 1
                if brace_count == 0:
                    end_idx = i + 1
                    break
        
        if end_idx != -1:
            # We found the whole block! Let's verify it contains "Nhóm Thông Báo"
            block = text[start_idx:end_idx]
            if "Nhóm Thông Báo" in block:
                text = text[:start_idx] + text[end_idx:]
                print("Successfully removed 'Nhóm Thông Báo' block.")
            else:
                print("Could not verify block contents.")
        else:
            print("Could not find matching closing brace.")
    else:
        print("Could not find preceding HStack.")
else:
    print("Could not find 'bell.badge.fill'")

with open(cv_path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Modifications saved.")
