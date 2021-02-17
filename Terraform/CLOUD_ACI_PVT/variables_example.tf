/*This is an example file, you can change the variables to your own data using an .tfvars file.*/


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