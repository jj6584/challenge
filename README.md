# Challenge

Reusable DevOps boilerplate to quickly spin up infrastructure for challenges and projects. Cost-optimized Terraform modules for personal accounts.

## Structure

```
challenge/
├── modules/              # Infrastructure building blocks
│   └── AWS/
│       └── ecs/         # Container orchestration
├── service-modules/      # Complete application stacks
│   └── n8n-ecs/        # N8N workflow automation
└── apps/                # Environment deployments
    ├── production/
    │   ├── apsea1/      # ap-southeast-1 (Singapore)
    │   └── use1/        # us-east-1 (Virginia)
    └── staging/
```

## Quick Start

1. **Infrastructure Modules**: [modules/](./modules/) - Reusable AWS components
2. **Service Modules**: [service-modules/](./service-modules/) - Complete application stacks
3. **Applications**: [apps/](./apps/) - Environment-specific deployments with S3 remote state

## Deployment Flow

```
Infrastructure Modules → Service Modules → Applications
     (ECS, SSM)      →   (N8N Stack)   → (Client Deployments)
```

## Cost Optimization

All modules are designed for **minimal AWS costs** with:
- Small instance sizes (t3.micro, t3.small)
- Host path volumes by default
- Single-AZ deployments
- Quick teardown capabilities

Perfect for personal testing and short-term projects.
