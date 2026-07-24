variable "aws_access_key" {
  description = "AWS Access Key for Fluent Bit S3 Uploads"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key for Fluent Bit S3 Uploads"
  type        = string
  sensitive   = true
}