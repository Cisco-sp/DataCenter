
variable "cloudvrf_name" {
    type = string
    description = "Name of the VRF that will be created, you will see it in AWS as the name of the VPC"
}

variable "TENANT_ACCOUNT_ID"{
    type = string
    description = "You forgot to run the credentials.sh, configure it and run like this ---> \". credentials.sh\""
}

variable "TENANT_ACCOUNT_ACCESS_KEY" {
    type = string
    description = "You forgot to run the credentials.sh, configure it and run like this ---> \". credentials.sh\""
}

variable "TENANT_ACCOUNT_SECRET_KEY_ID" {
    type = string
    description = "You forgot to run the credentials.sh, configure it and run like this ---> \". credentials.sh\""
}

variable "tenant_region" {
    type = string
    description = "The region that your tenant will be created"
}

variable "tenant_cidr" {
    type = string
    description = "CIDR of your tenant, all subnets need to be in this CIDR."
}

variable "tenant_subnets" {
    type = map
    description = "This variable is a map of all the information to configure a Subnet in CLOUD APIC, see the documentation for an example."
}

variable "anp_name" {
    type = string
    description = "The name of your ANP"
}

variable "ec2_ssh_key_name" {
    type = string
    description = "Name that will be used to create an SSH Key on AWS for your EC2s"
  
}

variable "endpoint_sel_tag_epg1" {
    type = string
    description = "This tag will be used in your EC2 and in your EPG so that the Cloud APIC can put this EC2 in the right EPG."
  
}

variable "endpoint_sel_tag_epg2" {
    type = string
    description = "This tag will be used in your EC2 and in your EPG so that the Cloud APIC can put this EC2 in the right EPG."
  
}

