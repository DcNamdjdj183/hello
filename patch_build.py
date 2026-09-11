import sys
path = 'build_unsigned.sh'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('test -d "$APP"', 'test -d "$APP"\n\n# Copy video and dns folders directly to app bundle\ncp -R "$ROOT/ThreeOneOSFive/video" "$APP/" || true\ncp -R "$ROOT/ThreeOneOSFive/dns" "$APP/" || true\n')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print('Updated build_unsigned.sh')
