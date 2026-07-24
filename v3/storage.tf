# v3/storage.tf

# Create the S3 bucket for centralized logs
resource "aws_s3_bucket" "honeynet_logs" {
  bucket        = "honeynet-central-logs-2026" # Change this if the name is already taken globally
  force_destroy = true                         # Allows us to destroy the bucket even if it contains logs during testing
}

# Enforce AES-256 Encryption on the logs
resource "aws_s3_bucket_server_side_encryption_configuration" "log_encryption" {
  bucket = aws_s3_bucket.honeynet_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the logs
resource "aws_s3_bucket_public_access_block" "secure_logs" {
  bucket                  = aws_s3_bucket.honeynet_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "log_bucket_name" {
  value = aws_s3_bucket.honeynet_logs.bucket
}