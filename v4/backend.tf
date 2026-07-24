terraform {
  backend "gcs" {
    bucket  = "honeynet-gsoc-26-gcs-state"
    prefix  = "gcp/honeynet.tfstate"
  }
}