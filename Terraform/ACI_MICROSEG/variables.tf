variable "apic_address" {
    description = "Input variable for the IP or URL of your APIC Controller"
}

variable "apic_user" {
    description = "Input variable for the user that will manage the infrastructure in ACI"
}

variable "apic_password" {
    description = "Input variable for the password of the user that will manage the infrastructure in AC.I"
}

variable "env_prefix" {
    description = "Input variable for the name of the environment that will be created, every object in ACI will\n have this prefix in its name"
}

variable "subnets" {
    type = list
    description = "Input variable with the IPs that will be used for the gateways of the Bridge Domains."

}


