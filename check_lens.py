import os, plistlib

for f in os.listdir('ThreeOneOSFive/Patches'):
    path = os.path.join('ThreeOneOSFive/Patches', f)
    with open(path, 'rb') as f_obj:
        data = f_obj.read()[10:]
    try:
        plist = plistlib.loads(data, fmt=plistlib.FMT_BINARY)
        print(f)
        print("  keyFingerprint len:", len(plist.get("keyFingerprint", b"")))
        print("  encryptedPayload len:", len(plist.get("encryptedPayload", b"")))
    except Exception as e:
        print(e)
