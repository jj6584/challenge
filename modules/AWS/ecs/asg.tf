# Auto Scaling Group for EC2 instances (when using EC2 launch type)
resource "aws_autoscaling_group" "ecs_asg" {
  count               = var.launch_type[0] == "EC2" ? 1 : 0
  name                = "${var.cluster_name}-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.asg_target_group_arns
  health_check_type   = "ELB"

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.ecs_lt[0].id
    version = "$Latest"
  }

  # Enable instance refresh for rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Launch Template for EC2 instances
resource "aws_launch_template" "ecs_lt" {
  count       = var.launch_type[0] == "EC2" ? 1 : 0
  name_prefix = "${var.cluster_name}-lt"
  description = "Launch template for ECS cluster ${var.cluster_name} - SSM access only"

  image_id      = var.ec2_ami_id != null ? var.ec2_ami_id : data.aws_ami.ecs_optimized[0].id
  instance_type = var.ec2_instance_type

  # NO SSH KEY - Access only via SSM Session Manager
  # key_name is intentionally omitted for security

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = var.iam_instance_profile != null ? var.iam_instance_profile : aws_iam_instance_profile.ecs_agent[0].name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name            = aws_ecs_cluster.main.name
    custom_user_data        = var.user_data_script
    additional_commands     = var.additional_user_data_commands
    custom_environment_vars = var.custom_environment_variables
    enable_ebs_data_volume  = var.enable_ebs_data_volume
    ebs_data_mount_point    = var.ebs_data_mount_point
  }))

  # Enable detailed monitoring for better scaling decisions
  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  # Instance metadata options (required for SSM)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  # Enable Spot instances for cost optimization
  dynamic "instance_market_options" {
    for_each = var.enable_spot_instances ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        spot_instance_type = "one-time"
      }
    }
  }

  # EBS Block Device Mappings
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.ec2_volume_size
      volume_type           = var.ec2_volume_type
      delete_on_termination = true
      encrypted             = true
    }
  }

  # Additional EBS Data Volume for persistent storage
  dynamic "block_device_mappings" {
    for_each = var.enable_ebs_data_volume ? [1] : []
    content {
      device_name = "/dev/xvdf"
      ebs {
        volume_size           = var.ebs_data_volume_size
        volume_type           = var.ebs_data_volume_type
        iops                  = var.ebs_data_volume_iops
        throughput            = var.ebs_data_volume_throughput
        delete_on_termination = false  # Persist data volume
        encrypted             = var.ebs_data_volume_encrypted
        kms_key_id            = var.ebs_data_volume_kms_key_id
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name       = "${var.cluster_name}-instance"
      Access     = "SSM-Only"
      SSMManaged = "true"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.cluster_name}-volume"
    })
  }
}