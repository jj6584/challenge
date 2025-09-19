# Infrastructure Modules

Reusable Terraform modules for cloud infrastructure components.

## Available Modules

| Module | Description | Status |
|--------|-------------|--------|
| [AWS/ecs](./AWS/ecs/) | Elastic Container Service (Fargate & EC2) | ✅ Production Ready |
| [AWS/rds](./AWS/rds/) | Relational Database Service (Single-AZ) | ✅ Production Ready |

## Quick Start

Each module has its own detailed README with usage examples and configuration options:

- **[AWS ECS Module](./AWS/ecs/README.md)** - Complete documentation for container orchestration
- **[AWS RDS Module](./AWS/rds/README.md)** - Complete documentation for managed databases

## Module Structure

```
modules/
├── AWS/
│   ├── ecs/          # Container orchestration
│   └── rds/          # Managed databases
└── README.md
```

## Development

Each module follows standard Terraform conventions:
- `main.tf` - Resources
- `variables.tf` - Inputs  
- `outputs.tf` - Outputs
- `README.md` - Documentation

## Related

- [Service Modules](../service-modules/) - Application-specific modules
- [Apps](../apps/) - Environment deployments