# N8N ECS Simple Module Outputs

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
}

output "service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_cluster.service_name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = module.ecs_cluster.service.id
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.ecs_cluster.load_balancer_arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.ecs_cluster.load_balancer_dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.ecs_cluster.load_balancer_zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.ecs_cluster.target_group_arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ecs_cluster.autoscaling_group_name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.ecs_cluster.task_definition_arn
}

output "ecs_security_group_id" {
  description = "ID of the ECS security group"
  value       = module.ecs_cluster.ecs_tasks_security_group_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.ecs_cluster.alb_security_group_id
}

# Add security_group_id for backward compatibility
output "security_group_id" {
  description = "ID of the ECS tasks security group (for backward compatibility)"
  value       = module.ecs_cluster.ecs_tasks_security_group_id
}

output "ec2_instances_security_group_id" {
  description = "ID of the EC2 instances security group (for bridge mode networking)"
  value       = module.ecs_cluster.ec2_instances_security_group_id
}