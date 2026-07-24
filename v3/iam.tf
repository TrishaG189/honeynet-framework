# v3/iam.tf

# ---------------------------------------------------------
# AWS PERMISSIONS: IAM Role & Instance Profile for EC2
# ---------------------------------------------------------

# 1. Trust Policy: Allow EC2 to assume this role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_honeypot_role" {
  name               = "aws-honeypot-log-shipper-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# 2. Permissions Policy: Allow PutObject to our S3 bucket
data "aws_iam_policy_document" "s3_put_policy" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.honeynet_logs.arn}/*"]
  }
}

resource "aws_iam_policy" "s3_write_policy" {
  name   = "honeypot-s3-write-policy"
  policy = data.aws_iam_policy_document.s3_put_policy.json
}

# 3. Attach Policy to the EC2 Role
resource "aws_iam_role_policy_attachment" "attach_s3_policy_aws" {
  role       = aws_iam_role.aws_honeypot_role.name
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

# 4. Create the Instance Profile to attach to EC2
resource "aws_iam_instance_profile" "aws_honeypot_profile" {
  name = "aws-honeypot-instance-profile"
  role = aws_iam_role.aws_honeypot_role.name
}

# ---------------------------------------------------------
# GCP PERMISSIONS: IAM User & Access Keys for Cross-Cloud
# ---------------------------------------------------------

# 1. Create a dedicated IAM User for the GCP instances
resource "aws_iam_user" "gcp_log_shipper" {
  name = "gcp-fluent-bit-shipper"
}

# 2. Attach the exact same S3 Write policy to this user
resource "aws_iam_user_policy_attachment" "attach_s3_policy_gcp" {
  user       = aws_iam_user.gcp_log_shipper.name
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

# 3. Generate Access Keys for Fluent Bit on GCP
resource "aws_iam_access_key" "gcp_log_shipper_key" {
  user = aws_iam_user.gcp_log_shipper.name
}

# 4. Output the keys so we can pass them to the GCP module
output "gcp_access_key" {
  value     = aws_iam_access_key.gcp_log_shipper_key.id
  sensitive = true
}

output "gcp_secret_key" {
  value     = aws_iam_access_key.gcp_log_shipper_key.secret
  sensitive = true
}