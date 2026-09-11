import os, plistlib

for f in os.listdir('ThreeOneOSFive/Patches'):
    path = os.path.join('ThreeOneOSFive/Patches', f)
    with open(path, 'rb') as f_obj:
        data = f_obj.read()[10:]
    try:
        plist = plistlib.loads(data, fmt=plistlib.FMT_BINARY)
        print(f)
        print("  kdfSalt:", "kdfSalt" in plist)
        print("  kdfIterations:", "kdfIterations" in plist)
        print("  wrappedContentKey:", "wrappedContentKey" in plist)
    except Exception as e:
        print(e)
