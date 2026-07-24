# GSoC 2026 Progress Blog

## Project Information

| Field            | Details                                          |
| ---------------- | ------------------------------------------------ |
| Organization     | C2SI                                             |
| Project          | Scalable Multi-Cloud Honeynet Framework          |
| Duration Covered | Weeks 1–8                                        |
| Repository       | https://github.com/TrishaG189/honeynet-framework |

---

## Introduction

As part of Google Summer of Code (GSoC) 2026, I am working with C2SI on the **Scalable Multi-Cloud Honeynet Framework**. The project aims to automate the deployment of Cowrie SSH honeypots on AWS and Google Cloud Platform using Terraform, centralize the collected logs, and enrich attacker information using threat intelligence APIs. This blog summarizes the work completed during the first eight weeks of the project.

---

## Project Goal

The framework focuses on:

- Deploying Cowrie honeypots on AWS and GCP
- Automating infrastructure using Terraform
- Collecting logs from deployed honeypots
- Storing logs centrally
- Enriching attacker IPs using IP-API and AbuseIPDB

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
```

---

## Progress Summary

| Week | Work Completed                 |
| ---- | ------------------------------ |
| 1    | AWS infrastructure setup       |
| 2    | Automated Cowrie deployment    |
| 3    | Terraform modules              |
| 4    | Multi-region AWS deployment    |
| 5    | Google Cloud support           |
| 6    | Remote Terraform state         |
| 7    | Centralized log collection     |
| 8    | Threat intelligence enrichment |

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

### Result

Logs from deployed honeypots are stored in one location.

> **Screenshot:** Fluent Bit forwarding logs

---

# Week 8 — Threat Intelligence Enrichment

### Pipeline

```text
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
```

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

## Repository Structure

```text
honeynet-framework/

├── docs/
├── enrichment/
├── v1/
├── v2/
├── v3/
├── v4/
├── deploy.sh
├── destroy.sh
└── README.md
```

---

## Tech Stack

| Category            | Technologies               |
| ------------------- | -------------------------- |
| Infrastructure      | Terraform                  |
| Cloud               | AWS, Google Cloud Platform |
| Honeypot            | Cowrie, Docker             |
| Logging             | Fluent Bit, Amazon S3      |
| Threat Intelligence | Python, IP-API, AbuseIPDB  |

---

## Challenges

- Understanding Terraform modules
- Managing AWS and GCP deployments
- Configuring Fluent Bit
- Setting up remote Terraform state
- Integrating multiple services into a single workflow

---

## Next Steps

- Improve monitoring
- Complete testing
- Refine deployment workflow
- Improve documentation

---

## Conclusion

During the first eight weeks, the project progressed from a basic Terraform deployment on AWS to a multi-cloud framework with automated Cowrie deployment, centralized log collection, and threat intelligence enrichment. The remaining work will focus on testing, documentation, and improving the overall deployment workflow.
