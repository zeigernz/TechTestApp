# Infrastructure deployments with Terraform
This service can be run on [AWS](https://aws.amazon.com/), by spinning up the required infrastructure using [Terraform](https://www.terraform.io/).

Please install/configure the pre-requisites below and then follow the steps as described. 

## Prerequisites
1. Terraform executable v0.12.24 (already included in this repo: `terraform/terraform`)
1. A working AWS profile configured on the machine from which `terraform` commands will be run. Read [this](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) for setup instructions
1. Make sure that the `aws` provider `region` and `profile` values under `terraform/main.tf` are valid and what you intend to use, as per the AWS profile configuration
1. Make sure that the following variables are set as environment variables in CircleCI for this project, under `<TechTestApp> -> Project Settings -> Environment Variables`
    1. `AWS_ACCESS_KEY_ID`
    1. `AWS_SECRET_ACCESS_KEY`
    1. `AWS_ACCOUNT_ID`
    1. `AWS_DEFAULT_REGION`    

## Steps
1. cd `terraform/terraform`
1. `./terraform init`
1. `./terraform plan -var="api_config_file_name=api.json"`
1. If the plan looks good, `./terraform apply -var="api_config_file_name=api.json" -auto-approve`
1. Trigger a CircleCI build (configured under `.circleci/config.yml`) for the branch you want to deploy. One easy way to do this is by committing and pushing changes for that branch to the github remote repo.
1. Once the build is successful, your services should be accessible

**NOTE**
When running this deployment for the first time, create the database schema and seed it with some data by performing the above steps and replacing `-var="api_config_file_name=api.json"` with `-var="api_config_file_name=seed-api.json"`.
This step will be automated in the future.

## Outputs
One of the outputs produced by the `terraform apply` command contains HTTP load balancer URLs to access the HTTP based services deployed by this terraform configuration, once the build for this change passes in CircleCI. 

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
Refer to CircleCI configuration under: `.circleci/config.yml`

## TODO
1. The `updatedb` command currently needs to be run first to seed the database with a schema and some data. We can simplify deployment by simply doing what `updatedb` does, when we start the service using `serve`. 
This will remove the need to run `updatedb` before running `serve`. It can be achieved with some minor code changes. 
1. Run `terraform` commands in CircleCI on every push - to automatically create/update infrastructure when code is pushed to this github repo
1. Get rid of dependency on AWS CodeBuild, use CircleCI to push directly to ECS and do a smoke test after that push
1. Separate IAM credentials for CircleCI user
1. Internal DNS entry for postgres, so services can automatically know what database to use
1. Setup a remote backend for terraform state
1. HTTPS enabled load balancer, when we own a domain
