# ===================================================================
# ECS INSTANCE IAM ROLES (for EC2 launch type)
# ===================================================================

# IAM Instance Profile for ECS Agent
resource "aws_iam_instance_profile" "ecs_agent" {
  count = var.launch_type[0] == "EC2" && var.iam_instance_profile == null ? 1 : 0
  name  = "${var.cluster_name}-ecs-instance-profile"
  role  = aws_iam_role.ecs_agent[0].name

  tags = var.tags
}

# IAM Role for ECS Agent
resource "aws_iam_role" "ecs_agent" {
  count = var.launch_type[0] == "EC2" && var.iam_instance_profile == null ? 1 : 0
  name  = "${var.cluster_name}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach ECS Agent Policy to Role
resource "aws_iam_role_policy_attachment" "ecs_agent" {
  count      = var.launch_type[0] == "EC2" && var.iam_instance_profile == null ? 1 : 0
  role       = aws_iam_role.ecs_agent[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Additional IAM policies for enhanced ECS functionality
resource "aws_iam_role_policy_attachment" "ecs_agent_ssm" {
  count      = var.launch_type[0] == "EC2" && var.iam_instance_profile == null ? 1 : 0
  role       = aws_iam_role.ecs_agent[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Additional SSM policies for enhanced session management
resource "aws_iam_role_policy_attachment" "ecs_agent_ssm_patch" {
  count      = var.launch_type[0] == "EC2" && var.iam_instance_profile == null && var.enable_ssm_patch_management ? 1 : 0
  role       = aws_iam_role.ecs_agent[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}

# Custom policy to deny SSH key operations and enforce SSM-only access
resource "aws_iam_role_policy" "ecs_agent_deny_ssh" {
  count = var.launch_type[0] == "EC2" && var.iam_instance_profile == null && var.enforce_ssm_only ? 1 : 0
  name  = "${var.cluster_name}-ecs-deny-ssh"
  role  = aws_iam_role.ecs_agent[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "ec2:CreateKeyPair",
          "ec2:DeleteKeyPair",
          "ec2:ImportKeyPair",
          "ec2:DescribeKeyPairs"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssm:SendCommand",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstanceInformation",
          "ssm:GetCommandInvocation",
          "ssm:DescribeInstanceAssociations",
          "ssm:ListAssociations",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus"
        ]
        Resource = "*"
      }
    ]
  })
}

# Custom policy for CloudWatch logs if needed
resource "aws_iam_role_policy" "ecs_agent_cloudwatch" {
  count = var.launch_type[0] == "EC2" && var.iam_instance_profile == null && var.enable_cloudwatch_logs ? 1 : 0
  name  = "${var.cluster_name}-ecs-cloudwatch-logs"
  role  = aws_iam_role.ecs_agent[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ===================================================================
# ECS TASK ROLES (for both Fargate and EC2)
# ===================================================================

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  count = var.create_task_execution_role ? 1 : 0
  name  = "${var.cluster_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  count      = var.create_task_execution_role ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policies for task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_ssm" {
  count      = var.create_task_execution_role && var.enable_task_ssm_access ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# Custom policy for accessing secrets from SSM Parameter Store/Secrets Manager
resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  count = var.create_task_execution_role && length(var.task_secrets_arns) > 0 ? 1 : 0
  name  = "${var.cluster_name}-ecs-task-execution-secrets"
  role  = aws_iam_role.ecs_task_execution_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ]
        Resource = var.task_secrets_arns
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arns
      }
    ]
  })
}

# ECS Task Role (for application permissions)
resource "aws_iam_role" "ecs_task_role" {
  count = var.create_task_role ? 1 : 0
  name  = "${var.cluster_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Custom policy for task role (application-specific permissions)
resource "aws_iam_role_policy" "ecs_task_role_custom" {
  count = var.create_task_role && var.task_role_policy != null ? 1 : 0
  name  = "${var.cluster_name}-ecs-task-role-custom"
  role  = aws_iam_role.ecs_task_role[0].id

  policy = var.task_role_policy
}

# Additional custom inline policies for task role
resource "aws_iam_role_policy" "ecs_task_role_additional_policies" {
  count = var.create_task_role ? length(var.task_role_additional_policies) : 0
  name  = "${var.cluster_name}-ecs-task-role-policy-${count.index + 1}"
  role  = aws_iam_role.ecs_task_role[0].id

  policy = var.task_role_additional_policies[count.index]
}

# Additional managed policies for task role
resource "aws_iam_role_policy_attachment" "ecs_task_role_additional" {
  count      = var.create_task_role ? length(var.task_role_managed_policies) : 0
  role       = aws_iam_role.ecs_task_role[0].name
  policy_arn = var.task_role_managed_policies[count.index]
}

# Common AWS service policies that can be easily attached
resource "aws_iam_role_policy_attachment" "ecs_task_role_s3_read" {
  count      = var.create_task_role && var.enable_s3_read_access ? 1 : 0
  role       = aws_iam_role.ecs_task_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_s3_full" {
  count      = var.create_task_role && var.enable_s3_full_access ? 1 : 0
  role       = aws_iam_role.ecs_task_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_rds_access" {
  count      = var.create_task_role && var.enable_rds_access ? 1 : 0
  role       = aws_iam_role.ecs_task_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_secrets_manager" {
  count      = var.create_task_role && var.enable_secrets_manager_access ? 1 : 0
  role       = aws_iam_role.ecs_task_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_parameter_store" {
  count      = var.create_task_role && var.enable_parameter_store_access ? 1 : 0
  role       = aws_iam_role.ecs_task_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# Custom policy for specific resource access (e.g., specific S3 buckets, SQS queues)
resource "aws_iam_role_policy" "ecs_task_role_resource_specific" {
  count = var.create_task_role && length(var.task_role_s3_bucket_arns) > 0 ? 1 : 0
  name  = "${var.cluster_name}-ecs-task-role-s3-buckets"
  role  = aws_iam_role.ecs_task_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = concat(
          var.task_role_s3_bucket_arns,
          [for bucket in var.task_role_s3_bucket_arns : "${bucket}/*"]
        )
      }
    ]
  })
}

# Custom policy for SQS access
resource "aws_iam_role_policy" "ecs_task_role_sqs_access" {
  count = var.create_task_role && length(var.task_role_sqs_queue_arns) > 0 ? 1 : 0
  name  = "${var.cluster_name}-ecs-task-role-sqs-queues"
  role  = aws_iam_role.ecs_task_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = var.task_role_sqs_queue_arns
      }
    ]
  })
}

# Custom policy for DynamoDB access
resource "aws_iam_role_policy" "ecs_task_role_dynamodb_access" {
  count = var.create_task_role && length(var.task_role_dynamodb_table_arns) > 0 ? 1 : 0
  name  = "${var.cluster_name}-ecs-task-role-dynamodb-tables"
  role  = aws_iam_role.ecs_task_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = var.task_role_dynamodb_table_arns
      }
    ]
  })
}