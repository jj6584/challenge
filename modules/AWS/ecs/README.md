# AWS ECS Terraform Module

## Usage

### Fargate Service

```hcl
module "ecs_fargate" {
  source = "./modules/AWS/ecs"

  cluster_name = "my-app-cluster"
  service_name = "my-app-service"
  
  container_definitions = jsonencode([
    {
      name  = "my-app"
      image = "nginx:latest"
      cpu   = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/my-app"
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  vpc_id  = "vpc-12345678"
  subnets = ["subnet-12345678", "subnet-87654321"]
  
  cpu    = "256"
  memory = "512"
  
  desired_count = 2
  
  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### EC2 Service

```hcl
module "ecs_ec2" {
  source = "./modules/AWS/ecs"

  cluster_name = "my-app-cluster"
  service_name = "my-app-service"
  
  launch_type = ["EC2"]
  
  container_definitions = jsonencode([
    {
      name  = "my-app"
      image = "nginx:latest"
      cpu   = 128
      memory = 256
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
    }
  ])

  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]
  
  ec2_instance_type    = "t3.medium"
  asg_min_size         = 1
  asg_max_size         = 5
  asg_desired_capacity = 2
  
  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### With Load Balancer

```hcl
module "ecs_with_alb" {
  source = "./modules/AWS/ecs"

  cluster_name = "my-app-cluster"
  service_name = "my-app-service"
  
  container_definitions = jsonencode([
    {
      name  = "my-app"
      image = "my-app:latest"
      cpu   = 512
      memory = 1024
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])

  vpc_id  = "vpc-12345678"
  subnets = ["subnet-12345678", "subnet-87654321"]
  
  cpu    = "512"
  memory = "1024"
  desired_count = 3

  create_alb = true
  alb_subnets = ["subnet-public1", "subnet-public2"]
  container_port = 8080
  health_check_path = "/health"

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### With Auto Scaling

```hcl
module "ecs_autoscaling" {
  source = "./modules/AWS/ecs"

  cluster_name = "my-app-cluster"
  service_name = "my-app-service"
  
  container_definitions = jsonencode([
    {
      name  = "my-app"
      image = "my-app:latest"
      cpu   = 256
      memory = 512
      essential = true
    }
  ])

  vpc_id  = "vpc-12345678"
  subnets = ["subnet-12345678", "subnet-87654321"]
  
  cpu    = "256"
  memory = "512"
  desired_count = 2

  enable_autoscaling = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 10
  cpu_target_value = 75
  memory_target_value = 80

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### With Custom IAM Policies

```hcl
module "ecs_custom_iam" {
  source = "./modules/AWS/ecs"

  cluster_name = "my-app-cluster"
  service_name = "my-app-service"
  
  container_definitions = jsonencode([
    {
      name  = "my-app"
      image = "my-app:latest"
      cpu   = 256
      memory = 512
      essential = true
    }
  ])

  vpc_id  = "vpc-12345678"
  subnets = ["subnet-12345678", "subnet-87654321"]
  
  cpu    = "256"
  memory = "512"

  # Enable AWS service access
  enable_s3_read_access = true
  enable_secrets_manager_access = true
  enable_parameter_store_access = true

  # Custom policy
  task_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### EC2 with Custom User Data

```hcl
module "ecs_ec2_custom" {
  source = "./modules/AWS/ecs"

  cluster_name = "my-app-cluster"
  service_name = "my-app-service"
  
  launch_type = ["EC2"]
  
  container_definitions = jsonencode([
    {
      name  = "my-app"
      image = "my-app:latest"
      cpu   = 128
      memory = 256
      essential = true
    }
  ])

  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]
  
  ec2_instance_type    = "t3.medium"
  asg_min_size         = 1
  asg_max_size         = 3
  asg_desired_capacity = 2

  # Custom environment variables
  custom_environment_variables = {
    APP_ENV = "production"
    LOG_LEVEL = "info"
  }

  # Custom user data script
  user_data_script = <<-EOF
    #!/bin/bash
    yum install -y htop jq
    echo 'ECS_ENABLE_TASK_ENI=true' >> /etc/ecs/ecs.config
  EOF

  # Additional commands
  additional_user_data_commands = [
    "systemctl enable docker",
    "usermod -a -G docker ec2-user"
  ]

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

## Required Variables

- `cluster_name` - Name of the ECS cluster
- `service_name` - Name of the ECS service  
- `vpc_id` - VPC ID where resources will be created
- `subnets` - List of subnet IDs for Fargate
- `subnet_ids` - List of subnet IDs for EC2 (alternative to subnets)

## Common Variables

- `cluster_name` - Name of the ECS cluster
- `service_name` - Name of the ECS service  
- `vpc_id` - VPC ID where resources will be created
- `subnets` - List of subnet IDs for Fargate
- `subnet_ids` - List of subnet IDs for EC2 (alternative to subnets)
- `container_definitions` - JSON container definitions
- `cpu` - CPU units (Fargate: "256", "512", "1024", "2048", "4096")
- `memory` - Memory in MB (Fargate: combinations based on CPU)
- `launch_type` - ["FARGATE"] or ["EC2"]
- `desired_count` - Number of tasks to run
- `ec2_instance_type` - Instance type for EC2 launch type
- `asg_min_size` - Auto Scaling Group minimum size
- `asg_max_size` - Auto Scaling Group maximum size
- `asg_desired_capacity` - Auto Scaling Group desired capacity

## Sample Outputs

When you use this module, you'll get various outputs that you can reference in other resources or modules:

### Individual Outputs (Legacy)
```hcl
# Basic cluster information
cluster_id   = "arn:aws:ecs:us-west-2:123456789012:cluster/my-app-cluster"
cluster_arn  = "arn:aws:ecs:us-west-2:123456789012:cluster/my-app-cluster"
cluster_name = "my-app-cluster"

# Service information
service_id   = "arn:aws:ecs:us-west-2:123456789012:service/my-app-cluster/my-app-service"
service_arn  = "arn:aws:ecs:us-west-2:123456789012:service/my-app-cluster/my-app-service"
service_name = "my-app-service"

# Task definition
task_definition_arn      = "arn:aws:ecs:us-west-2:123456789012:task-definition/my-app-service:1"
task_definition_family   = "my-app-service"
task_definition_revision = "1"

# IAM roles
task_execution_role_arn = "arn:aws:iam::123456789012:role/my-app-cluster-task-execution-role"
task_role_arn          = "arn:aws:iam::123456789012:role/my-app-cluster-task-role"

# Security groups
ecs_tasks_security_group_id = "sg-0123456789abcdef0"
security_group_ids         = ["sg-0123456789abcdef0"]

# For EC2 launch type
autoscaling_group_arn    = "arn:aws:autoscaling:us-west-2:123456789012:autoScalingGroup:..."
autoscaling_group_name   = "my-app-cluster-asg"
launch_template_id       = "lt-0123456789abcdef0"
capacity_provider_name   = "my-app-cluster-capacity-provider"
```

### Grouped Outputs (Recommended)
```hcl
# Cluster information
cluster = {
  id   = "arn:aws:ecs:us-west-2:123456789012:cluster/my-app-cluster"
  arn  = "arn:aws:ecs:us-west-2:123456789012:cluster/my-app-cluster"
  name = "my-app-cluster"
}

# Service information
service = {
  id   = "arn:aws:ecs:us-west-2:123456789012:service/my-app-cluster/my-app-service"
  arn  = "arn:aws:ecs:us-west-2:123456789012:service/my-app-cluster/my-app-service"
  name = "my-app-service"
}

# Task definition information
task_definition = {
  arn      = "arn:aws:ecs:us-west-2:123456789012:task-definition/my-app-service:1"
  family   = "my-app-service"
  revision = "1"
}

# IAM roles information
iam_roles = {
  task_execution_role = {
    arn  = "arn:aws:iam::123456789012:role/my-app-cluster-task-execution-role"
    name = "my-app-cluster-task-execution-role"
  }
  task_role = {
    arn  = "arn:aws:iam::123456789012:role/my-app-cluster-task-role"
    name = "my-app-cluster-task-role"
  }
  instance_profile = {
    arn  = "arn:aws:iam::123456789012:instance-profile/my-app-cluster-instance-profile"
    name = "my-app-cluster-instance-profile"
  }
}

# Security groups information
security_groups = {
  ecs_tasks = {
    id  = "sg-0123456789abcdef0"
    arn = "arn:aws:ec2:us-west-2:123456789012:security-group/sg-0123456789abcdef0"
  }
  alb = {
    id  = "sg-0123456789abcdef1"
    arn = "arn:aws:ec2:us-west-2:123456789012:security-group/sg-0123456789abcdef1"
  }
  ec2_instances = {
    id  = "sg-0123456789abcdef2"
    arn = "arn:aws:ec2:us-west-2:123456789012:security-group/sg-0123456789abcdef2"
  }
  all_ids = ["sg-0123456789abcdef0", "sg-0123456789abcdef1", "sg-0123456789abcdef2"]
}

# EC2 infrastructure (for EC2 launch type)
ec2_infrastructure = {
  autoscaling_group = {
    arn  = "arn:aws:autoscaling:us-west-2:123456789012:autoScalingGroup:..."
    name = "my-app-cluster-asg"
  }
  launch_template = {
    id      = "lt-0123456789abcdef0"
    version = "1"
  }
  capacity_provider = {
    name = "my-app-cluster-capacity-provider"
    arn  = "arn:aws:ecs:us-west-2:123456789012:capacity-provider/my-app-cluster-capacity-provider"
  }
}

# Auto scaling information (when enabled)
autoscaling = {
  target = {
    resource_id        = "service/my-app-cluster/my-app-service"
    scalable_dimension = "ecs:service:DesiredCount"
    min_capacity       = 1
    max_capacity       = 10
  }
  policies = {
    cpu_scaling = {
      arn  = "arn:aws:application-autoscaling:us-west-2:123456789012:scalingPolicy/..."
      name = "my-app-cluster-cpu-scaling"
    }
    memory_scaling = {
      arn  = "arn:aws:application-autoscaling:us-west-2:123456789012:scalingPolicy/..."
      name = "my-app-cluster-memory-scaling"
    }
  }
}

# CloudWatch information
cloudwatch = {
  log_group = {
    name              = "/ecs/my-app-cluster"
    arn               = "arn:aws:logs:us-west-2:123456789012:log-group:/ecs/my-app-cluster"
    retention_in_days = 7
  }
}

# Complete module output
ecs_module = {
  cluster           = { /* cluster info */ }
  service           = { /* service info */ }
  task_definition   = { /* task definition info */ }
  iam_roles         = { /* IAM roles info */ }
  security_groups   = { /* security groups info */ }
  ec2_infrastructure = { /* EC2 infrastructure info */ }
  autoscaling       = { /* autoscaling info */ }
  cloudwatch        = { /* CloudWatch info */ }
  launch_type       = "FARGATE"
  module_version    = "enhanced"
}
```

### Using Outputs in Other Resources

```hcl
# Reference the ECS module
module "my_app" {
  source = "./modules/AWS/ecs"
  
  cluster_name = "my-app-cluster"
  service_name = "my-app-service"
  # ... other configuration
}

# Use outputs in other resources
resource "aws_cloudwatch_dashboard" "app_dashboard" {
  dashboard_name = "my-app-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", module.my_app.service_name, "ClusterName", module.my_app.cluster_name]
          ]
        }
      }
    ]
  })
}

# Create additional security group rules
resource "aws_security_group_rule" "app_database_access" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.database.id
  security_group_id        = module.my_app.ecs_tasks_security_group_id
}

# Reference grouped outputs (cleaner)
resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.example.com"
  type    = "A"
  
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
  
  # You can access nested output values
  depends_on = [module.my_app]
}

# Use the complete module output for complex integrations
locals {
  ecs_info = module.my_app.ecs_module
  
  monitoring_config = {
    cluster_name = local.ecs_info.cluster.name
    service_name = local.ecs_info.service.name
    log_group    = local.ecs_info.cloudwatch.log_group.name
  }
}
```