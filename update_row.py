import os

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('Text(item)\n                    .font(.system(size: 14, weight: .bold))',
                    'Text(item.replacingOccurrences(of: ".3105", with: ""))\n                    .font(.system(size: 14, weight: .bold))')

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated InteractiveRow UI")
