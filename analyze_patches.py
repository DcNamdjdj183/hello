import os
import re

folder = r'c:\Users\Administrator\Downloads\OGIOS - SOURCE FULL\Tele @dntweaks\ThreeOneOSFive\Patches\FREEFIRETH'
files = [f for f in os.listdir(folder) if f.endswith('.3105')]

mod_files = [f for f in files if f.lower().startswith('mod ')]
proxy_files = [f for f in files if not f.lower().startswith('mod ')]

# Deduplicate proxy files
# If we have "Name --2.3105" and "Name -.3105", we should keep only one.
# Let's normalize the names to find duplicates.
seen_bases = set()
deduped_proxy = []

for f in sorted(proxy_files):
    # Try to extract the base name by removing trailing dashes and .3105
    base = re.sub(r' -+2?\.3105$', '', f)
    if base not in seen_bases:
        seen_bases.add(base)
        deduped_proxy.append(f)

print("MOD FILES:", mod_files)
print("PROXY FILES (DEDUPED):", deduped_proxy)
print("PROXY FILES (ORIGINAL):", proxy_files)
