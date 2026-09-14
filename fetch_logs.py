import urllib.request, re

url = 'https://github.com/DcNamdjdj183/hello/actions/runs/34700524631/job/103571352241'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        html = response.read().decode('utf-8')
        print("HTML downloaded")
        # search for error lines in the HTML (GitHub often embeds initial log lines or data islands)
        for line in html.split('\n'):
            if 'error:' in line.lower() and 'swift' in line.lower():
                print(line.strip())
            
        urls = re.findall(r'https://[^"]+/logs[^"]*', html)
        for u in set(urls):
            print("Found URL:", u)
except Exception as e:
    print('Error:', e)
