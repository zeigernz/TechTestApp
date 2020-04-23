terraform {
  required_version = "~> 0.12"
}

provider "aws" {
  version = "~> 2.12"
  region  = "ap-southeast-2"
  profile = "default"
}

module "fargate" {
  source = "strvcom/fargate/aws"
  version = "0.17.0"

  name = "servian-techtest"

  services = {
    api = {
      task_definition = "api.json"
      container_port  = 80
      cpu             = "256"
      memory          = "512"
      replicas        = 1

      registry_retention_count = 15 # Optional. 20 by default
      logs_retention_days      = 14 # Optional. 30 by default

      health_check_interval = 100             # Optional. In seconds. 30 by default
      health_check_path     = "/healthcheck/" # Optional. "/" by default
    }
  }

  # If you want to set up a SNS topic receiving CodePipeline current status
  # SNS's ARN could be use by getting the output of the module eg =>
  # arn = "${module.fargate.codepipeline_events_sns_arn}"
  codepipeline_events_enabled = true
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "servian-techtest-postgres"

  engine            = "postgres"
  engine_version    = "9.6.9"
  instance_class    = "db.t3.micro"
  allocated_storage = 5
  storage_encrypted = false

  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  name = "postgres"

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = "postgres"

  password = "postgres"
  port     = "5432"

  vpc_security_group_ids = [data.aws_security_group.default.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = {
    Owner       = "zeigernz"
    Environment = "servian-techtestapp"
  }

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = data.aws_subnet_ids.all.ids

  # DB parameter group
  family = "postgres9.6"

  # DB option group
  major_engine_version = "9.6"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "servian-techtest-postgres-final"

  # Database Deletion Protection
  deletion_protection = false
}