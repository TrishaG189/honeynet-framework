
# GSoC 2026 Progress Blog

## Project Information

| Field            | Details                                          |
| ---------------- | ------------------------------------------------ |
| Organization     | C2SI                                             |
| Project          | Scalable Multi-Cloud Honeynet Framework          |
| Duration Covered | Weeks 1–14                                       |
| Repository       | https://github.com/TrishaG189/honeynet-framework |

---

## Introduction

As part of Google Summer of Code (GSoC) 2026, I am working with C2SI on the **Scalable Multi-Cloud Honeynet Framework**. The project aims to automate the deployment of Cowrie SSH honeypots on AWS and Google Cloud Platform using Terraform, centralize the collected logs, and enrich attacker information using threat intelligence APIs. This blog summarizes the work completed during the entire fourteen weeks of the project.

---

## Project Goal

The framework focuses on:

- Deploying Cowrie honeypots on AWS and GCP
- Automating infrastructure using Terraform
- Collecting logs from deployed honeypots
- Storing logs centrally
- Enriching attacker IPs using IP-API and AbuseIPDB
- Delivering actionable offline dashboards and automated CI/CD pipelines

---

## Architecture

```text
                 Terraform
                      │
         ┌────────────┴────────────┐
         │                         │
         ▼                         ▼
      AWS                     Google Cloud
         │                         │
         └────────────┬────────────┘
                      ▼
             Cowrie Honeypots
                      │
                      ▼
                 Fluent Bit
                      │
                      ▼
                Amazon S3 Bucket
                      │
                      ▼
            Python Enrichment Script
                 │              │
                 ▼              ▼
             IP-API        AbuseIPDB
                      │
                      ▼
             Enriched Log Files
                      │
                      ▼
          Static HTML Threat Dashboard

```

## Progress Summary

| Week | Work Completed |
| ---- | -------------- |
| 1 | AWS infrastructure setup |
| 2 | Automated Cowrie deployment |
| 3 | Terraform modules |
| 4 | Multi-region AWS deployment |
| 5 | Google Cloud support |
| 6 | Remote Terraform state |
| 7 | Centralized log collection |
| 8 | Threat intelligence enrichment |
| 9-10 | S3 archive pattern & log lifecycle management |
| 11-12 | Observability & threat dashboard generator |
| 13 | Continuous Integration (CI/CD) pipeline |
| 14 | Final testing, automation & documentation |

---

# Week 1 — AWS Infrastructure

### Completed

- Configured AWS provider
- Created VPC
- Created subnet
- Created Internet Gateway
- Created route table
- Configured security groups
- Launched EC2 instance

### Result

Terraform can provision the complete AWS infrastructure without manual setup.

> **Screenshot:** Terraform Apply / AWS Console

---

# Week 2 — Automated Cowrie Deployment

### Completed

- Automated Docker installation
- Automated Cowrie installation
- Used `user_data` to initialize the instance
- Verified SSH access

### Result

Cowrie starts automatically whenever a new instance is deployed.

> **Screenshot:** Cowrie running inside Docker

---

# Week 3 — Terraform Refactoring

### Completed

- Created reusable Terraform modules
- Separated networking resources
- Separated compute resources
- Added variables
- Added outputs

### Why?

Managing everything from a single Terraform file became difficult as the project grew. Splitting the configuration into modules made it easier to maintain and extend.

---

# Week 4 — Multi-Region AWS Deployment

### Completed

- Added multi-region deployment support
- Added region selection
- Updated deployment scripts

### Result

The same infrastructure can now be deployed in different AWS regions without changing the Terraform code.

---

# Week 5 — Google Cloud Support

### Completed

- Configured GCP provider
- Created networking resources
- Created compute instance
- Automated Cowrie deployment

### Result

The framework now supports deployments on both AWS and Google Cloud Platform.

---

# Week 6 — Remote Terraform State

### AWS

- S3 backend
- DynamoDB state locking

### Google Cloud

- Google Cloud Storage backend

### Benefits

- Shared Terraform state
- State locking
- Easier deployment management

> **Screenshot:** S3 bucket / GCS backend

---

# Week 7 — Centralized Log Collection

### Completed

- Configured Fluent Bit
- Collected Cowrie logs automatically
- Uploaded logs to Amazon S3

### Workflow

```text
Cowrie
   │
   ▼
Fluent Bit
   │
   ▼
Amazon S3

```

# Week 8 — Threat Intelligence Enrichment

### Pipeline

    Cowrie Logs
          │
          ▼
    Extract IP Address
          │
          ├────────► IP-API
          │
          └────────► AbuseIPDB
                    │
                    ▼
            Enriched Log File
                    │
                    ▼
                 Archive

### Information Added

- Country
- City
- Region
- ISP
- ASN
- Abuse Confidence Score

### Result

Each log now contains additional information about the attacker IP instead of only the raw address.

> **Screenshot:** Sample enriched log

---

# Weeks 9-10 — S3 Archive Pattern & Log Lifecycle

### Completed

- Implemented `archive_processed_logs` function in Python
- Automated log deduplication using `boto3` `copy_object` and `delete_object`
- Created dedicated `archive/` S3 prefix

### Why?

Processing the same logs multiple times would consume unnecessary compute resources and quickly exhaust external API rate limits. Moving processed logs to an archive ensures the enrichment script only queries new threat data.

### Result

The serverless pipeline runs efficiently without processing duplicate attacker IPs.

---

# Weeks 11-12 — Observability & Threat Dashboard

### Completed

- Authored `generate_dashboard.py` script
- Configured JSON payload aggregation from the S3 data lake
- Rendered parsed data into a static HTML interface

### Result

Security researchers can run a single command to generate `threat_dashboard.html`, providing an immediate, offline geographic and ISP breakdown of the attack telemetry.

> **Screenshot:** Rendered HTML Threat Dashboard

---

# Week 13 — Continuous Integration (CI/CD)

### Completed

- Implemented `.github/workflows/terraform-validate.yml`
- Added automated `terraform fmt` checks for all modules
- Configured `py_compile` steps for Python syntax validation

### Result

Automated quality gates now run on every push and pull request, preventing unformatted infrastructure code or broken Python scripts from being merged into the main branch.

---

# Week 14 — Final Testing, Automation & Documentation

### Completed

- Finalized multi-cloud bash wrappers (`deploy.sh`, `destroy.sh`)
- Overhauled the root `README.md` with system diagrams, prerequisite tables, and setup instructions
- Added MIT License
- Submitted final GSoC report and code deliverables

### Result

The project is fully complete, well-documented, and ready for external security researchers to easily deploy across AWS or Google Cloud.

---

## Repository Structure

    honeynet-framework/
    ├── .github/
    │   └── workflows/
    │       └── terraform-validate.yml
    ├── docs/
    ├── enrichment/
    │   ├── enrich_logs.py
    │   └── generate_dashboard.py
    ├── v1/
    ├── v2/
    ├── v3/
    ├── v4/
    ├── deploy.sh
    ├── destroy.sh
    └── README.md

---

## Tech Stack

| Category            | Technologies                 |
| ------------------- | ---------------------------- |
| Infrastructure      | Terraform                    |
| Cloud               | AWS, Google Cloud Platform   |
| Honeypot            | Cowrie, Docker               |
| Logging             | Fluent Bit, Amazon S3        |
| Threat Intelligence | Python, IP-API, AbuseIPDB    |
| CI/CD & Automation  | GitHub Actions, Bash         |

---

## Challenges

- Understanding Terraform modules
- Managing AWS and GCP deployments
- Configuring Fluent Bit
- Setting up remote Terraform state
- Integrating multiple services into a single workflow
- Securely passing AWS S3 write credentials to Google Cloud instances
- Architecting the Python enrichment script to track processed files

---

## Next Steps

- Implement Slack/Discord webhook integration for critical alerts
- Connect the S3 data lake to AWS Athena or Grafana
- Extend Terraform modules to support Microsoft Azure or DigitalOcean

---

## Conclusion

Over the course of 14 weeks, this project successfully evolved from an isolated cloud script into a highly scalable, multi-cloud honeynet framework. The final implementation seamlessly bridges automated AWS/GCP infrastructure provisioning, zero-latency Fluent Bit telemetry streaming, and serverless Python threat enrichment. I am incredibly grateful to my mentors and the C2SI organization for their guidance throughout Google Summer of Code 2026!
