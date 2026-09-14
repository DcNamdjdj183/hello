import os

cv_path = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\ContentView.swift'
with open(cv_path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('let passes = ["3105", ""]', 'let passes = ["3105", "Tele@YaPaor", "dntweaks", ""]')

with open(cv_path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Passwords added.")
