import os, plistlib

for f in os.listdir('ThreeOneOSFive/Patches'):
    path = os.path.join('ThreeOneOSFive/Patches', f)
    with open(path, 'rb') as f_obj:
        data = f_obj.read()[10:]
    try:
        plist = plistlib.loads(data, fmt=plistlib.FMT_BINARY)
        print(f'{f}:')
        print(f'  isPasswordProtected: {plist.get("isPasswordProtected")}')
        print(f'  publicContentKey length: {len(plist.get("publicContentKey", b""))}')
        print(f'  kdfSalt length: {len(plist.get("kdfSalt", b""))}')
    except Exception as e:
        print(e)
