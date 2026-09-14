import urllib.request
import json
import zipfile
import io

# Repository: DcNamdjdj183/hello
url = "https://api.github.com/repos/DcNamdjdj183/hello/actions/runs"
req = urllib.request.Request(url, headers={'Accept': 'application/vnd.github.v3+json'})
try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        if data['workflow_runs']:
            latest_run = data['workflow_runs'][0]
            print(f"Latest run ID: {latest_run['id']}, Status: {latest_run['status']}, Conclusion: {latest_run['conclusion']}")
            
            jobs_url = latest_run['jobs_url']
            jobs_req = urllib.request.Request(jobs_url, headers={'Accept': 'application/vnd.github.v3+json'})
            with urllib.request.urlopen(jobs_req) as jobs_response:
                jobs_data = json.loads(jobs_response.read().decode())
                if jobs_data['jobs']:
                    job = jobs_data['jobs'][0]
                    print(f"Job ID: {job['id']}")
                    
                    logs_url = f"https://api.github.com/repos/DcNamdjdj183/hello/actions/jobs/{job['id']}/logs"
                    print(f"Logs URL: {logs_url}")
                    # Downloading logs requires authentication for private repos, but this is a public repo?
                    # Wait, actions/jobs/{job_id}/logs might redirect to a text file.
                    try:
                        log_req = urllib.request.Request(logs_url)
                        with urllib.request.urlopen(log_req) as log_response:
                            log_text = log_response.read().decode('utf-8', errors='replace')
                            lines = log_text.splitlines()
                            # Print lines containing error
                            print("Extracting errors:")
                            for i, line in enumerate(lines):
                                if 'error:' in line.lower() or 'fatal' in line.lower():
                                    start = max(0, i - 2)
                                    end = min(len(lines), i + 3)
                                    print("...")
                                    for j in range(start, end):
                                        print(lines[j])
                    except Exception as e:
                        print("Could not fetch job logs:", e)
        else:
            print("No workflow runs found.")
except Exception as e:
    print("Error:", e)
