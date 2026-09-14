import urllib.request
import json

url = 'https://api.github.com/repos/DcNamdjdj183/hello/actions/runs/34700524631'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        print("Commit SHA:", data.get('head_sha'))
        print("Status:", data.get('status'))
        print("Conclusion:", data.get('conclusion'))
        print("Created At:", data.get('created_at'))
except Exception as e:
    print('Error:', e)
