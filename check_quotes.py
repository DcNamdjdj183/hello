with open("ThreeOneOSFive/ContentView.swift", "r", encoding="utf-8") as f:
    text = f.read()

# count quotes excluding escaped quotes
import re
text_no_escape = text.replace('\\"', '')
print("Quote count:", text_no_escape.count('"'))
