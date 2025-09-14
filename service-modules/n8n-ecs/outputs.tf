output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.n8n_ecs.cluster_id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.n8n_ecs.cluster_name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = module.n8n_ecs.service_name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = module.n8n_ecs.service_arn
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.n8n_ecs.task_definition_arn
}