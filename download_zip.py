import urllib.request, zipfile, io, sys

url = 'https://github.com/DcNamdjdj183/hello/actions/runs/34700524631/logs'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        data = response.read()
        print("Downloaded zip size:", len(data))
        with zipfile.ZipFile(io.BytesIO(data)) as z:
            for name in z.namelist():
                if "Build Unsigned IPA" in name:
                    content = z.read(name).decode('utf-8')
                    lines = content.split('\n')
                    for line in lines:
                        if "error:" in line.lower():
                            print(line.strip())
except Exception as e:
    print('Error:', e)
