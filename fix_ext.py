import os

path = 'ThreeOneOSFive/helpers/PatchProjectLibrary.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('forResourcesWithExtension: "OGIOS"', 'forResourcesWithExtension: "3105"')
text = text.replace('url.pathExtension.lowercased() == "OGIOS"', 'url.pathExtension.lowercased() == "3105"')
text = text.replace('appendingPathExtension("OGIOS")', 'appendingPathExtension("3105")')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Fixed extensions')
