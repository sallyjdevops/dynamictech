terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.13.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Terraform backend
terraform {
  backend "s3" {
    bucket = var.bucket
    key    = var.key
    region = var.region
    dynamodb_table = var.dynamodb_table
  }
}

locals {
  owner_name = "Dynamic Tech"
  bucket_arn = module.create_s3_bucket.bucket_arn  
}

module "create_ec2_instance" {
    source = "./modules/EC2"
    resource_env = var.resource_env
    ami_id = var.ami_id 
    instance_type = var.instance_type
    Owner_number = "12345"
    owner_name = local.owner_name
}

# EC2 Folder, I have define a varaible (var.resource_env), then I call EC2 in my module block
# So in the module I have to define the value of that variable but rather then mentioning the value, I am again defining a varaible against var.resource_env

module "create_s3_bucket" {
    source = "./modules/S3"
    bucket_name = var.bucket_name 
    owner_name = local.owner_name
}

module "create_iam_resources" {
  # depends_on = [ module.create_s3_bucket ]
  source = "./modules/IAM"
  owner_name = local.owner_name
  iam_user_name = "suraj"
  iam_group_name = "DevOps"
  bucket_arn = local.bucket_arn #"arn:aws:s3:::${var.bucket_name}"
}

/*
Task
--> Create IAM Role for ec2
--> Create IAM policy with S3 and Secret manager permission
--> Attach Above policy with Role
--> Create VPC, 2 Private Subnet, 2 Public Subnet, Nat Gateway, IGW, Route Table, NACL
--> Create 1 Ec2 in Private Subnet & 2nd in Public Subnet (Also create 2 SG for Ec2 and attach Above created IAM role with EC2)
*/


# terraform init -reconfigure -backend-config=configuration/dev.hcl
# terraform apply -var-file=configuration/dev.tfvars

# terraform apply -var-file=configuration/dev.tfvars -replace="module.create_ec2_instance.aws_instance.my-first-ec2"  -- used to replace a resouce, means it will re-create it

# terraform taint module.create_iam_resources.aws_iam_user_group_membership.adding_to_developer  -- This command will update the statefile and mark resouce as tainted and then when we run terraform apply , it will re-create the resource



# If you want to do terraform plan or apply on any one module of a specific reason, then we can use below command. In this you can pass your specific module only, but don't use in production
# terraform plan -target=module.create_ec2_instance

# AWS Development --> S3 bucket & DynamoDB, Variables value will be diff

# AWS PROD --> S3 bucket & DynamoDB, Variables value will be diff

# module - variable A = variable B
