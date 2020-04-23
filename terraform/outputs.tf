# VPC
output "vpc" {
  value = "${module.fargate.vpc_id}"
}

# ECR
output "ecr" {
  value = "${module.fargate.ecr_repository_urls}"
}

# ECS Cluster
output "ecs_cluster" {
  value = "${module.fargate.ecs_cluster_arn}"
}

# ALBs
output "application_load_balancers" {
  value = "${module.fargate.application_load_balancers_dns_names}"
}

# CloudWatch
output "cloudwatch_log_groups" {
  value = "${module.fargate.cloudwatch_log_group_names}"
}

output "postgres_endpoint" {
  value = "${module.db.this_db_instance_endpoint}"
}