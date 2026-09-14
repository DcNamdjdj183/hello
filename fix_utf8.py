import re
with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

# Fix CACHE RES section
text = re.sub(r'\"AIM BODY \(B.*?\"', '\"AIM BODY (Bat Sanh)\"', text)
text = re.sub(r'\"AIM CHEST \(B.*?\"', '\"AIM CHEST (Bat Sanh)\"', text)
text = re.sub(r'\"AIM DRAG \(B.*?\"', '\"AIM DRAG (Bat Sanh)\"', text)
text = re.sub(r'\"AIM NECK \(B.*?\"', '\"AIM NECK (Bat Sanh)\"', text)
text = re.sub(r'\"MAGIC BULLET \(B.*?\"', '\"MAGIC BULLET (Bat Sanh)\"', text)
text = re.sub(r'pkg: \"B.*?nh\"', 'pkg: \"Bat Sanh\"', text)

# Fix CommunityCard text
text = re.sub(r'Text\(\".*?th.*?b.*?o.*?\"\)', 'Text("Cong dong thong bao cap nhat")', text)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print('Replaced corrupted text with ASCII')
