# N8N ECS Module

Complete N8N automation platform stack on AWS ECS using EC2 launch type. Cost-optimized for personal accounts and short-term testing.

## Stack Components

- **N8N**: Workflow automation platform
- **PostgreSQL**: Database backend for N8N
- **Traefik**: Reverse proxy and load balancer

## Architecture

```
Internet → Traefik (Port 80/443) → N8N (Port 5678)
                                  ↓
                               PostgreSQL (Port 5432)
```

## Storage Options

| Type | Cost | Persistence | Use Case |
|------|------|-------------|----------|
| **Host Path** (default) | Lowest | Instance lifetime | Testing, development |
| **EBS Volume** | Medium | Survives termination | Production data |
| **EFS** | Highest | Multi-AZ shared | High availability |

## Basic Usage

```hcl
module "n8n_stack" {
  source = "./service-modules/n8n-ecs"
  
  cluster_name       = "n8n-cluster"
  service_name       = "n8n-service"
  vpc_id            = "vpc-12345678"
  subnet_ids        = ["subnet-12345678"]
  security_group_ids = ["sg-12345678"]
  
  # N8N configuration
  n8n_host         = "localhost"  # or your domain
  n8n_protocol     = "http"       # or "https" 
  postgres_password = "secure-password"
  
  # Cost-optimized defaults
  ec2_instance_type = "t3.micro"  # ~$0.0104/hour
  desired_count     = 1
  cpu              = "1024"
  memory           = "2048"
}
```

## EBS Volume Storage

For persistent data across instance replacements:

```hcl
module "n8n_stack" {
  source = "./service-modules/n8n-ecs"
  
  # ... basic configuration ...
  
  # Enable EBS volumes
  enable_ebs_volumes    = true
  ebs_data_volume_size  = 20     # GB
  ebs_data_volume_type  = "gp3"
  
  # Data paths on EBS volume
  postgres_data_path = "/data/postgres"
  n8n_data_path     = "/data/n8n"
}
```

## Configuration

### Required Variables

- `cluster_name` - ECS cluster name
- `service_name` - ECS service name  
- `vpc_id` - VPC ID
- `subnet_ids` - List of subnet IDs
- `security_group_ids` - List of security group IDs
- `postgres_password` - PostgreSQL password

### Key Optional Variables

- `enable_ebs_volumes` - Enable EBS persistent storage (default: false)
- `ec2_instance_type` - Instance type (default: "t3.micro") 
- `n8n_host` - N8N hostname (default: "localhost")
- `n8n_protocol` - Protocol http/https (default: "http")

## Accessing N8N

After deployment, access N8N at:
- HTTP: `http://<traefik-ip>:80`
- HTTPS: `https://<your-domain>` (if configured)

## Outputs

- `service_arn` - ECS service ARN
- `cluster_arn` - ECS cluster ARN  
- `load_balancer_dns` - Traefik load balancer DNS

For complete variable and output documentation, see:
- [variables.tf](./variables.tf)
- [outputs.tf](./outputs.tf)