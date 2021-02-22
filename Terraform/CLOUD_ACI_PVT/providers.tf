/*This is needed because the ACI provider is not in the Official Hashicorp Repository, so we need to specify the path to the provider*/
terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
      version = "0.5.4"
      
    }
  }
}

provider aci {
      url = "https://34.196.161.124"
      username = "admin"
      password = var.CLOUD_APIC_PASSWORD
}

/*You need to use the AWS provider, the cloud_apic module will inherit the provider from here. */
provider aws {
    alias = "cloud_apic_deploy"
    region = var.cloud_apic_region
    access_key = var.CLOUD_APIC_ACCOUNT_ACCESS_KEY
    secret_key = var.CLOUD_APIC_ACCOUNT_SECRET_KEY_ID
}



provider aws {
    alias = "deploy_cloud_aci_tenant"
    region = var.tenant_region
    access_key = var.TENANT_ACCOUNT_ACCESS_KEY
    secret_key = var.TENANT_ACCOUNT_SECRET_KEY_ID
}