# Remote state configuration for the prod environment.
#
# Replace `bucket` / `dynamodb_table` with real, already-provisioned
# resources before applying this against an actual AWS account. Prod uses
# the same state bucket as dev but a distinct key, so each environment's
# state is isolated.
#
# For local validation (fmt / validate / plan), no real backend needs to be
# reachable — run `terraform init -backend=false` instead of `terraform init`.

terraform {
  backend "s3" {
    bucket         = "bookingapp-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "bookingapp-terraform-locks"
    encrypt        = true
  }
}
