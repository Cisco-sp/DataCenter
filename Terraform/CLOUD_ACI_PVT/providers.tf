/*You need to use the AWS provider, the cloud_apic module will inherit the provider from here. */
provider aws {
    region = var.aws_region
    shared_credentials_file = var.aws_credentials
    profile = var.aws_credentials_profile
}

/*You need to use the ACI Provider, the deploy_aci_network will inherit the provider from here. */
