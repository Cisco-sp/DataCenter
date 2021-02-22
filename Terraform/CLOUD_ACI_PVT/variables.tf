variable "CLOUD_APIC_PASSWORD" {
    type = string
    description = "You forgot to run the credentials.sh, configure it and run like this ---> \". credentials.sh\""
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
variable "CLOUD_APIC_ACCOUNT_SECRET_KEY_ID" {
  type = string
  description = "You forgot to run the credentials.sh, configure it and run like this ---> \". credentials.sh\""
}
variable "CLOUD_APIC_ACCOUNT_ACCESS_KEY" {
  type = string
  description = "You forgot to run the credentials.sh, configure it and run like this ---> \". credentials.sh\""
}

variable "tenant_region" {
    type = string
    description = "Region where your Tenant will be created"

}

variable "cloud_apic_region" {
  type = string
  description = "Region where your Cloud APIC will be created"
}