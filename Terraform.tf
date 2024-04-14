variable "owner_name" {
    type = string
    description = "Enter Owner name for Tagging"
}

variable "ami_id" {
    type = string
    description = "Enter AMI ID"
}


module "create_ec2_instance" {
    source = "./modules/EC2"
    resource_env = var.resource_env
    ami_id = var.ami_id 
    instance_type = var.instance_type
    Owner_number = "12345"
    owner_name = local.owner_name
}
