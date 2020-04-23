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