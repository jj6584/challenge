# Service Modules

Pre-configured application stacks optimized for **personal accounts** and **cost-effective short-term testing**. These modules are designed to minimize AWS costs while providing complete functionality for evaluation and development.

## 💰 Cost-Optimized Design

All service modules prioritize **minimal costs** with the following principles:

- **Small instances** (t3.micro, t3.small) for low compute costs
- **Host path volumes** by default (no EBS charges)
- **Single-AZ deployments** to avoid cross-AZ data transfer fees
- **Minimal resource allocation** suitable for testing workloads
- **Quick teardown** capabilities for short-term usage (days, not months)

## Available Modules

| Module | Description | Estimated Cost/Day* | Status |
|--------|-------------|-------------------|--------|
| [n8n-ecs-multiservice](./n8n-ecs-multiservice/) | Enhanced N8N with ALB, ACM certs, external RDS/Redis | ~$3-5 | ✅ Production Ready |

*_Cost estimates based on t3.micro instances in ap-southeast-1, actual costs may vary_

## Quick Start

Each module includes cost-optimized defaults and detailed documentation:

- **[N8N ECS Multiservice Stack](./n8n-ecs-multiservice/README.md)** - Enhanced workflow automation platform with ALB and ACM certificate support

## Module Architecture

```
service-modules/
├── n8n-ecs/              # N8N automation platform
│   ├── main.tf           # Cost-optimized resource configuration
│   ├── variables.tf      # Defaults tuned for minimal cost
│   ├── outputs.tf        # Essential outputs only
│   └── README.md         # Usage and cost guidance
└── README.md
```

## Related

- [Infrastructure Modules](../modules/) - Building blocks for these service modules
- [Applications](../apps/) - Environment-specific deployments