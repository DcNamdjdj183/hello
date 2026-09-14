import urllib.request
import json

url = 'https://api.github.com/repos/DcNamdjdj183/hello/actions/runs/34700524631/jobs'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        for job in data.get('jobs', []):
            print("Job ID:", job['id'])
            # Fetch annotations for this job
            ann_url = f"https://api.github.com/repos/DcNamdjdj183/hello/check_runs/{job['id']}/annotations"
            ann_req = urllib.request.Request(ann_url, headers={'User-Agent': 'Mozilla/5.0'})
            try:
                with urllib.request.urlopen(ann_req) as ann_res:
                    anns = json.loads(ann_res.read().decode('utf-8'))
                    for ann in anns:
                        print("Annotation:", ann['message'], ann['path'], ann['start_line'])
            except Exception as e:
                print("Error fetching annotations:", e)
except Exception as e:
    print('Error:', e)
