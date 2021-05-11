terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
      version = " ~> 0.5.4"
    }
  }
}

provider "aci" {
    url = var.apic_address
    username = var.apic_user
    password = var.apic_password
    insecure = true
}