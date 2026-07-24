# enrichment/enrich_logs.py



# enrichment/enrich_logs.py
import boto3
import json
import requests
import time
import os
from datetime import datetime, timezone
from dotenv import load_dotenv

# Load environment variables from the .env file
load_dotenv()

S3_BUCKET = 'honeynet-central-logs-2026'
PREFIX = 'fluent-bit-logs/honeypot.'

# Pull the API key from the environment securely
ABUSE_IPDB_KEY = os.getenv('ABUSEIPDB_API_KEY')

def fetch_raw_logs_from_s3():
    """Connects to AWS S3, downloads raw logs, and tracks processed files."""
    s3_client = boto3.client('s3')
    response = s3_client.list_objects_v2(Bucket=S3_BUCKET, Prefix=PREFIX)
    
    if 'Contents' not in response:
        return [], []

    extracted_ips = set()
    processed_files = [] # Keep track of files to move later
    
    for obj in response['Contents']:
        file_key = obj['Key']
        processed_files.append(file_key)
        
        raw_data = s3_client.get_object(Bucket=S3_BUCKET, Key=file_key)['Body'].read().decode('utf-8')
        
        for line in raw_data.strip().split('\n'):
            if line:
                log_entry = json.loads(line)
                if log_entry.get('eventid') == 'cowrie.session.connect':
                    src_ip = log_entry.get('src_ip')
                    if src_ip:
                        extracted_ips.add(src_ip)
                        
    return list(extracted_ips), processed_files

def archive_processed_logs(file_keys):
    """Moves processed logs into an archive folder so they aren't read twice."""
    s3_client = boto3.client('s3')
    
    print("\nArchiving processed log files...")
    for old_key in file_keys:
        # Create the new path (e.g., archive/fluent-bit-logs/...)
        new_key = f"archive/{old_key}"
        
        # Copy to the new location
        s3_client.copy_object(
            Bucket=S3_BUCKET,
            CopySource={'Bucket': S3_BUCKET, 'Key': old_key},
            Key=new_key
        )
        
        # Delete the original
        s3_client.delete_object(Bucket=S3_BUCKET, Key=old_key)
        print(f"Moved: {old_key} -> {new_key}")

def get_geolocation(ip):
    url = f"http://ip-api.com/json/{ip}"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            return {
                "country": data.get("country", "Unknown"),
                "city": data.get("city", "Unknown"),
                "isp": data.get("isp", "Unknown")
            }
    except Exception:
        pass
    return {"country": "Unknown", "city": "Unknown", "isp": "Unknown"}

def get_reputation(ip):
    if ABUSE_IPDB_KEY == 'YOUR_API_KEY_HERE':
        return {"abuse_score": "Skipped - No API Key"}
        
    url = "https://api.abuseipdb.com/api/v2/check"
    headers = {'Accept': 'application/json', 'Key': ABUSE_IPDB_KEY}
    params = {'ipAddress': ip, 'maxAgeInDays': '90'}
    
    try:
        response = requests.get(url, headers=headers, params=params)
        if response.status_code == 200:
            return {"abuse_score": response.json()['data'].get("abuseConfidenceScore", 0)}
    except Exception:
        pass
    return {"abuse_score": "Unknown"}

def save_enriched_logs_to_s3(enriched_data):
    s3_client = boto3.client('s3')
    
    # Use timezone-aware datetime to fix the deprecation warning
    from datetime import timezone
    timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%d_%H-%M-%S')
    file_name = f"enriched-logs/threat-intel-{timestamp}.json"
    
    json_payload = json.dumps(enriched_data, indent=4)
    
    print(f"\nUploading enriched logs to s3://{S3_BUCKET}/{file_name}...")
    s3_client.put_object(
        Bucket=S3_BUCKET,
        Key=file_name,
        Body=json_payload,
        ContentType='application/json'
    )
    print("Upload complete!")

if __name__ == "__main__":
    print("--- Starting Threat Enrichment Pipeline ---\n")
    unique_ips, processed_files = fetch_raw_logs_from_s3()
    
    if not unique_ips:
        print("No new logs to process. Exiting.")
    else:
        print(f"Found {len(unique_ips)} unique attacking IPs. Running enrichment...\n")
        
        enriched_results = []
        for ip in unique_ips:
            print(f"Investigating {ip}...")
            geo = get_geolocation(ip)
            rep = get_reputation(ip)
            
            from datetime import timezone
            enriched_results.append({
                "ip": ip,
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "country": geo["country"],
                "city": geo["city"],
                "isp": geo["isp"],
                "abuse_confidence_score": rep["abuse_score"]
            })
            time.sleep(1)
            
        # Save the new data
        save_enriched_logs_to_s3(enriched_results)
        
        # Archive the old logs so they aren't processed again
        archive_processed_logs(processed_files)
        
        print("\n--- Week 8 Enrichment Pipeline Executed Successfully ---")