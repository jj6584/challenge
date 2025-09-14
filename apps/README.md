# Applications

Environment-specific Terraform deployments with local execution and S3 remote state.

## Structure

```
apps/
├── production/
│   ├── apsea1/         # ap-southeast-1 (Singapore)
│   └── use1/           # us-east-1 (Virginia)
└── staging/
```

## Quick Start

1. **Navigate to app directory**:
   ```bash
   cd apps/production/apsea1/n8n-challenge-<client>
   ```

2. **Configure S3 backend** (`backend.tf`):
   ```hcl
   terraform {
     backend "s3" {
       bucket = "your-terraform-state-bucket"
       key    = "apps/production/apsea1/n8n-challenge-<client>/terraform.tfstate"
       region = "ap-southeast-1"
       encrypt = true
     }
   }
   ```

3. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## App Structure

Each application contains:
- `main.tf` - Service module configuration
- `variables.tf` - Environment variables
- `backend.tf` - S3 state configuration
- `terraform.tfvars` - Variable values (gitignored)

## Example Usage

```hcl
# main.tf
module "n8n_stack" {
  source = "../../../../service-modules/n8n-ecs"
  
  cluster_name       = "n8n-prod-apsea1"
  service_name       = "n8n-service"
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  security_group_ids = var.security_group_ids
  
  postgres_password = var.postgres_password
  ec2_instance_type = "t3.micro"  # Cost-optimized
  
  tags = {
    Environment = "production"
    Application = "n8n-challenge-<client>"
  }
}
```

## State Management

- **Local execution**: Run Terraform from your machine
- **Remote state**: Stored in S3 bucket
- **State key pattern**: `apps/{env}/{region}/{app}/terraform.tfstate`
- **Cost optimized**: Minimal resources for personal accounts

## Prerequisites

- AWS CLI configured
- Terraform >= 1.3
- S3 bucket for state storage

## Related

- [Service Modules](../service-modules/) - Application building blocks
- [Infrastructure Modules](../modules/) - Low-level components
