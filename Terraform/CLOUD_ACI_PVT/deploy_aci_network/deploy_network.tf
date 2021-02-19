terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
      version = "0.5.4"
    }
  }
}


provider aci {
    url = "https://18.234.11.53"
    username = "admin"
    password = file(var.cloudapic_password)
}


resource "aci_tenant" "pvt_tenant"{
    name = var.cloudtenant_name
    description = "Created by Terraform"
}

resource "aci_cloud_provider_profile" "aws_provider_profile" {
        description = "cloud provider profile"
        vendor      = "aws"
        annotation  = "pvt_aws_prof"
    }