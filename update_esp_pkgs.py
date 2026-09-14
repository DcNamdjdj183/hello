import sys

with open("ThreeOneOSFive/ContentView.swift", "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace('pkg: "ESP_FREE_FIRE_TH.3105"', 'pkg: "com.dts.freefireth"')
text = text.replace('pkg: "ESP_FREE_FIRE_MAX.3105"', 'pkg: "com.dts.freefiremax"')

with open("ThreeOneOSFive/ContentView.swift", "w", encoding="utf-8") as f:
    f.write(text)
print("Updated UI packages")
