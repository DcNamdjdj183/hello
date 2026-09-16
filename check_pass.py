import plistlib
import struct

data = open(r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\Patches\FREEFIRETH\Mod V10 - Alok -.3105', 'rb').read()
if data.startswith(b'3105PATCH\x00'):
    # The header size is 4 bytes at offset 10
    # Wait, looking at PatchPackageCodec.swift, how does it read?
    # envelopeData size is an Int32?
    pass

# We can just search for the bytes representing 'isPasswordProtected' and see what follows
idx = data.find(b'isPasswordProtected')
if idx != -1:
    print("Found isPasswordProtected at", idx)
    # The next byte in bplist usually indicates boolean True/False.
    # bplist booleans: 0x08 is False, 0x09 is True.
    # The key itself is usually a string, so after the string is the value.
    # Wait, bplist structure: the values are in the object table, the dict maps indices.
    # Better to just use plistlib on the exact slice if we know the size.
    # Let's just find 0x08 or 0x09 nearby? Or let plistlib decode the whole bplist if we pass the right chunk.
    # Actually, the file format:
    # 3105PATCH (9 bytes)
    # Version (1 byte) -> 0x00
    # Envelope size (4 bytes, UInt32)
    # Envelope data
    # ...
    
    env_size = struct.unpack('>I', data[10:14])[0]
    print("Env size:", env_size)
    env_data = data[14:14+env_size]
    try:
        pl = plistlib.loads(env_data)
        print("isPasswordProtected:", pl.get('isPasswordProtected'))
    except Exception as e:
        print("Error parsing plist:", e)
