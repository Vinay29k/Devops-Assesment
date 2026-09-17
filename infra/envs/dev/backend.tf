# Remote state configuration for the dev environment.
#
# Replace `bucket` / `dynamodb_table` with real, already-provisioned
# resources before applying this against an actual AWS account.
#
# For local validation (fmt / validate / plan), no real backend needs to be
# reachable — run `terraform init -backend=false` instead of `terraform init`.

terraform {
  backend "s3" {
    bucket         = "bookingapp-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "bookingapp-terraform-locks"
    encrypt        = true
  }
}
