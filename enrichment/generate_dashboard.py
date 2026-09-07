import boto3
import json

S3_BUCKET = 'honeynet-central-logs-2026'
PREFIX = 'enriched-logs/'

def generate_html():
    print("Fetching enriched logs from S3...")
    s3 = boto3.client('s3')
    response = s3.list_objects_v2(Bucket=S3_BUCKET, Prefix=PREFIX)
    
    if 'Contents' not in response:
        print("No logs found.")
        return

    ips = []
    for obj in response['Contents']:
        raw_data = s3.get_object(Bucket=S3_BUCKET, Key=obj['Key'])['Body'].read()
        data = json.loads(raw_data)
        if isinstance(data, list):
            ips.extend(data)
        else:
            ips.append(data)

    html = """
    <html><head><title>Threat Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 2rem; background: #f9f9f9; }
        table { border-collapse: collapse; width: 100%; background: white; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #333; color: white; }
    </style></head><body>
    <h2>Global Honeynet Threat Dashboard</h2>
    <table><tr><th>Attacker IP</th><th>Country</th><th>City</th><th>ISP</th><th>Threat Score</th></tr>
    """
    
    for entry in ips:
        html += f"<tr><td>{entry.get('ip', '')}</td><td>{entry.get('country', '')}</td><td>{entry.get('city', '')}</td><td>{entry.get('isp', '')}</td><td>{entry.get('abuse_confidence_score', '0')}</td></tr>"
    
    html += "</table></body></html>"

    with open("threat_dashboard.html", "w", encoding="utf-8") as f:
        f.write(html)
    print("Dashboard generated successfully! Open 'threat_dashboard.html' in your web browser.")

if __name__ == "__main__":
    generate_html()