
variable "aws_credentials" {
    type = string
    description = "Path to the shared credentials file, you can get it via awscli."
}

variable "aws_region" {
    type = string
    description = "The region that you are going to deploy the Cloud APIC"
}

variable "aws_credentials_profile" {
    type = string
    description = "The profile of the shared credentials file that you are going to use, the default value is (default)"
    default = "default"
}

variable "cloudformation_stack_name" {
    type = string
    description = "The name that will be used to create the AWS CloudFormation Stack"
    default = "CLOUD-APIC_TERRAFORM-DEPLOYED"
}

variable "cloudapic_fabric_name" {
    type = string
    description = "Fabric Name (must be only alphanumeric chars separated by '-')"
}

variable "cloudapic_az" {
    type = string
    description = "Availability zone of the Cloud APIC, it must match with the region that you are using in the AWS provider. Example: us-east-1a or us-east-1b"
}

variable "cloudapic_instance_type" {
    type = string
    description = "The type of the instance that will be used to deploy the Cloud APIC. Accepted Values are [m4.2xlarge/m5.2xlarge]" 
}

variable "cloudapic_allowed_extnet" {
    type = string
    description = "The CIDR that can access the Cloud APIC. Example: [0.0.0.0/0] to allow all the internet to access the Cloud APIC"
}

variable "cloudapic_password" {
    type = string
    description = "Path to the file with the password, it just need to be a plain text file with the password on it."
}

variable "cloudapic_ssh_key" {
    type = string
    description = "Name of the key that you want to use, this module will create an SSH key for you and deploy to AWS."
}