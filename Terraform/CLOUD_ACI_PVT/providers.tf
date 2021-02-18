/*This is needed because the ACI provider is not in the Official Hashicorp Repository, so we need to specify the path to the provider*/
terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
      version = "0.5.4"
    }
  }
}

/*You need to use the AWS provider, the cloud_apic module will inherit the provider from here. */
provider aws {
    region = var.aws_region
    shared_credentials_file = var.aws_credentials
    profile = var.aws_credentials_profile
}

/*You need to use the ACI Provider, the deploy_aci_network will inherit the provider from here. */

provider aci {

}