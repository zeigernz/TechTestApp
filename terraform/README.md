# Infrastructure deployments with Terraform

## Prerequisites
1. Terraform executable v0.12.24 (already included in this repo: `terraform/terraform`)
1. A working AWS CLI configured on the machine from which `terraform` commands will be run
1. Make sure that the `aws` provider `region` and `profile` values under `terraform/main.tf` are valid as per the AWS CLI configuration

## Steps
1. cd `terraform/terraform`
1. `./terraform init`
1. `./terraform plan`
1. If the plan looks good, `./terraform apply -auto-approve`

## Outputs
Outputs produced by the `terraform apply` command are used to access the HTTP based services, once the build for this change passes in CircleCI. 

A typical output looks like:
```
application_load_balancers = [
  "servian-techtest-default-api-alb-246170260.ap-southeast-2.elb.amazonaws.com",
]
cloudwatch_log_groups = [
  "/ecs/servian-techtest-api",
]
ecr = [
  "111444222333.dkr.ecr.ap-southeast-2.amazonaws.com/api-default",
]
ecs_cluster = arn:aws:ecs:ap-southeast-2:111444222333:cluster/servian-techtest-default-cluster
vpc = vpc-2c233c283ef9c54d3
```

This implies that the service `default-api` is available at the URL: `servian-techtest-default-api-alb-246170260.ap-southeast-2.elb.amazonaws.com` once the next CircleCI build is successful.

## Build configuration
TODO

## TODO
1. Get rid of dependency on AWS CodeBuild, use CircleCI to push directly to ECS and do a smoke test after that push
1. Separate IAM credentials for CircleCI user
1. Internal DNS entry for postgres, so services can automatically know which database to use
1. Remove backend for terraform state
1. HTTPS when we own a domain
