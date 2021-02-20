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


resource "aci_tenant" "cloud_tenant" {
    name = "PVT_TERRAFORM"
}

resource "aci_vrf" "cloud_vrf" {
    tenant_dn = aci_tenant.cloud_tenant.id
    name = var.cloudvrf_name
}

resource "aci_cloud_provider_profile" "tenant_provider_profile" {
        description = "Cloud ACI ${aci_tenant.cloud_tenant.name} aws provider profile"
        vendor      = "aws"
        annotation  = "Created by Terraform"
    }

resource "aci_cloud_providers_region" "tenant_providers_region" {
      cloud_provider_profile_dn = aci_cloud_provider_profile.tenant_provider_profile.id
      description               = "Cloud ACI ${aci_tenant.cloud_tenant.name} aws region"
      name                      = "us-east-1"
      annotation                = "tag_region"
      name_alias                = "default_reg"
    }

resource "aci_cloud_aws_provider" "tenant_aws_account" {
        provider_id = aci_cloud_provider_profile.tenant_provider_profile.id
        tenant_dn         = aci_tenant.cloud_tenant.id
        description       = "Cloud ACI ${aci_tenant.cloud_tenant.name} AWS Account"
        access_key_id     = var.TENANT_ACCOUNT_ACCESS_KEY
        account_id        = var.TENANT_ACCOUNT_ID
        secret_access_key = var.TENANT_ACCOUNT_SECRET_KEY_ID
    }

 resource "aci_cloud_context_profile" "tenant_context_profile" {
        name                     = "${aci_tenant.cloud_tenant.name}_tx_prof"
        description              = "Created by Terraform"
        tenant_dn                = aci_tenant.cloud_tenant.id
        primary_cidr             = var.tenant_cidr
        region                   = var.tenant_region
        cloud_vendor             = "aws"
        relation_cloud_rs_to_ctx = aci_vrf.cloud_vrf.id
    }

resource "aci_cloud_cidr_pool" "tenant_cidr_pool" {
        cloud_context_profile_dn = aci_cloud_context_profile.tenant_context_profile.id
        description              = "Created by Terraform"
        addr                     = var.tenant_cidr
    } 

resource "aci_cloud_availability_zone" "tenant_azs" {
        for_each = {for az in var.tenant_subnets["subnets"] : az.az => az}
        cloud_providers_region_dn = aci_cloud_providers_region.tenant_providers_region.id
        description               = "Created by Terraform"
        name                      = each.value.az
    }   

resource "aci_cloud_subnet" "tenant_subnets" {
        for_each = {for subnet in var.tenant_subnets["subnets"] : subnet.subnet => subnet}
        cloud_cidr_pool_dn = aci_cloud_cidr_pool.tenant_cidr_pool.id
        description        = "Created by Terraform"
        name               = each.value.name
        zone               = aci_cloud_availability_zone.tenant_azs[each.value.az].id
        ip                 = each.value.subnet
        scope              = "public"
    }

resource "aci_cloud_applicationcontainer" "cloud_anp" {
  tenant_dn  = aci_tenant.cloud_tenant.id
  name       = var.anp_name
}

 resource "aci_cloud_epg" "cloud_epg" {
    cloud_applicationcontainer_dn = aci_cloud_applicationcontainer.cloud_anp.id
    description                   = "EPG1"
    name                          = "cloud_epg"
    relation_cloud_rs_cloud_epg_ctx = aci_vrf.cloud_vrf.id
    }

resource "aci_cloud_endpoint_selector" "cloud_endpoint_selector" {
        cloud_epg_dn    = aci_cloud_epg.cloud_epg.id
        description      = "teste"
        name             = "PVT_TERRAFORM_EPG"
        match_expression = "custom:User=='heprado'"
        
    }

resource "aci_cloud_external_epg" "cloud_external_epg" {
        cloud_applicationcontainer_dn = aci_cloud_applicationcontainer.cloud_anp.id
        description                   = "cloud external epg to internet"
        name                          = "${aci_tenant.cloud_tenant.name}_internet_epg"
        relation_cloud_rs_cloud_epg_ctx = aci_vrf.cloud_vrf.id
    }

resource "aci_cloud_endpoint_selectorfor_external_epgs" "cloud_endpoint_selector_external_epgs" {
        cloud_external_epg_dn = aci_cloud_external_epg.cloud_external_epg.id
        description            = "endpoint selector for external epgs(internet)"
        name                   = "${aci_tenant.cloud_tenant.name}_selector_internet"
        is_shared              = "yes"
        subnet                 = "0.0.0.0/0"
    }

resource "aci_filter" "cloud_filter" {
        tenant_dn   = aci_tenant.cloud_tenant.id
        description = "permit_all"
        name        = "${aci_tenant.cloud_tenant.name}_filter"
    }

 resource "aci_filter_entry" "cloud_filter_entry" {
        filter_dn     = aci_filter.cloud_filter.id
        description   = "blablabla"
        name          = "${aci_tenant.cloud_tenant.name}_filter"
    }

resource "aci_contract" "cloud_contract" {
        tenant_dn   = aci_tenant.cloud_tenant.id
        description = "blablablalbal"
        name        = "demo_contract"
    }

 resource "aci_contract_subject" "foocontract_subject" {
        contract_dn   = aci_contract.cloud_contract.id
        description   = "blablabalbala"
        name          = "demo_subject"

    }
resource "aci_epg_to_contract" "attach_cloud_epg_contract" {
    application_epg_dn = aci_cloud_epg.cloud_epg.id
    contract_dn  = aci_contract.cloud_contract.id
    contract_type = "consumer"
}
resource "aci_epg_to_contract" "attach_cloud_ext_epg_contract" {
    application_epg_dn = aci_cloud_external_epg.cloud_external_epg.id
    contract_dn  = aci_contract.cloud_contract.id
    contract_type = "provider"
}

##Falta fazer esse contrato, estou morto por dentro