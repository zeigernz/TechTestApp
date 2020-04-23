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

## Build configuration
TODO