Terraform Infrastructure

Design: `Internet → ALB → ECS/Fargate → RDS`.

Layout

```
infra/
  modules/
    network/   # VPC, public/private subnets, IGW, NAT, ALB + SG, target group, listener
    ecs/       # ECS cluster, task execution IAM role, task definition, service, ECS SG
    rds/       # DB subnet group, RDS SG, RDS instance (Postgres or MySQL)
  envs/
    dev/       # small instance, 1-day backups, deletion_protection = false
    prod/      # larger instance, 30-day backups, deletion_protection = true, multi-AZ
```

Each `envs/<name>` is a root module with its own `variables.tf`, `terraform.tfvars`,
and `backend.tf`, so `dev` and `prod` never share state.

Security groups are chained so only the intended hop can talk to the next one:
internet → ALB SG (80/443) → ECS SG (container port, only from ALB SG) → RDS SG
(db port, only from ECS SG). RDS has no public access.

## Validating locally (no AWS account required)

Actual deployment is not required for this assessment — `fmt`, `init`, `validate`,
and `plan` are enough. Because the backends point at S3 buckets that don't exist
yet, run `init` without a backend:

```bash
cd infra/envs/dev   # or infra/envs/prod

terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan -refresh=false -var-file=terraform.tfvars
```

## Deploying for real

1. Create the S3 state bucket and DynamoDB lock table referenced in
   `backend.tf` (or point `backend.tf` at your own).
2. `terraform init` (no `-backend=false`).
3. `terraform plan -var-file=terraform.tfvars` and review.
4. `terraform apply -var-file=terraform.tfvars`.

`db_password` is optional in `terraform.tfvars` — if omitted, a random
password is generated via the `random` provider on first apply.
