import re

with open("ThreeOneOSFive/ContentView.swift", "r", encoding="utf-8") as f:
    text = f.read()

matches = re.findall(r'PremiumToggleRow\(name: "(.*?)", .*?isOn: \$(.*?), .*?togglePatch\(id: "(.*?)"', text)
for name, state_var, id_ in matches:
    print(f"{name} -> {state_var} -> {id_}")
