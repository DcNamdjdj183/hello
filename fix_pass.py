import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('let passes = ["3105", "Tele@YaPaor", ""]', 'let passes = ["3105", ""]')

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)
