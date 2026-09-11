import re
import sys

def check_pbxproj(path):
    text = open(path, encoding='utf-8').read()
    lines = text.split('\n')
    
    # Check for missing semicolons after assignments
    for i, line in enumerate(lines):
        clean = re.sub(r'/\*.*?\*/', '', line).strip()
        clean = re.sub(r'//.*', '', clean).strip()
        
        # If it's an assignment, it should end with ; or { or (
        if '=' in clean and not clean.endswith(';') and not clean.endswith('{') and not clean.endswith('('):
            # check if it spans multiple lines. If the last char is not ;, it's suspicious
            # Actually, string values can span lines, but usually not in standard pbxproj.
            print(f'Line {i+1} suspicious: {line}')

check_pbxproj('ThreeOneOSFive.xcodeproj/project.pbxproj')
