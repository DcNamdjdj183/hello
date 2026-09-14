import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

target = """struct InteractiveSectionView: View {
    let title: String
    let items: [String]
    
    var body: some View {"""

rep = """struct InteractiveSectionView: View {
    let title: String
    let items: [String]
    let appBundleId: String
    
    var body: some View {"""

text = text.replace(target, rep)

target2 = """            VStack(spacing: 12) {
                ForEach(items, id: \\.self) { item in
                    InteractiveRow(item: item)
                }
            }"""

rep2 = """            VStack(spacing: 12) {
                ForEach(items, id: \\.self) { item in
                    InteractiveRow(item: item, appBundleId: appBundleId)
                }
            }"""

text = text.replace(target2, rep2)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed InteractiveSectionView")
