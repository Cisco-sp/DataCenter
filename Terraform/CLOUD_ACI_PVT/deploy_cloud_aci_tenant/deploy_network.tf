terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
      version = "0.5.4"
    }
  }
}

resource "null_resource" "public_private_key" {
    provisioner "local-exec" {
        command = "ssh-keygen -f ${path.root}/credentials/${var.ec2_ssh_key_name}_terraform -m pem -N ''"
        }
    
    provisioner "local-exec" {
        when = destroy
        command = "rm ${path.root}/credentials/*_terraform"
    }
    
    provisioner "local-exec" {
        when = destroy
        command = "rm ${path.root}/credentials/*_terraform.pub"
    }

}

data "local_file" "read_key" {
   
    depends_on = [null_resource.public_private_key]
    filename = "${path.root}/credentials/${var.ec2_ssh_key_name}_terraform.pub"
}

resource "aws_key_pair" "cloudapic_key" {
    key_name = var.ec2_ssh_key_name
    
    public_key = data.local_file.read_key.content
}

resource "aws_instance" "ec2_epg1" {
    ami = "ami-03d315ad33b9d49c4"
    subnet_id = data.aws_subnet.subnet_epg1.id
    key_name = var.ec2_ssh_key_name
    associate_public_ip_address = true
    instance_type = "t3.micro"
    tags = {
        Type = var.endpoint_sel_tag_epg1
    }
}

resource "aws_instance" "ec2_epg2" {
    ami = "ami-03d315ad33b9d49c4"
    key_name = var.ec2_ssh_key_name
    subnet_id = data.aws_subnet.subnet_epg2.id
    associate_public_ip_address = true
    instance_type = "t3.micro"
    tags = {
        Type = var.endpoint_sel_tag_epg2
    }
}



data "aws_subnet" "subnet_epg1" {
    depends_on = [aci_cloud_subnet.tenant_subnets,aci_cloud_availability_zone.tenant_azs]
  filter {
    name   = "tag:Name"
    values = ["subnet-[192.168.1.0/24]"]
  }
}

data "aws_subnet" "subnet_epg2" {
  filter {
    name   = "tag:Name"
    values = ["subnet-[192.168.2.0/24]"]
  }
}


resource "aci_tenant" "cloud_tenant" {
    name = "PVT_TERRAFORM"
}

resource "aci_vrf" "cloud_vrf" {
    tenant_dn = aci_tenant.cloud_tenant.id
    name = var.cloudvrf_name
}

resource "aci_cloud_provider_profile" "tenant_provider_profile" {
        description = "Created by Terraform"
        vendor      = "aws"
        annotation  = "Created by Terraform"
    }

resource "aci_cloud_providers_region" "tenant_providers_region" {
      cloud_provider_profile_dn = aci_cloud_provider_profile.tenant_provider_profile.id
      description               = "Created by Terraform"
      name                      = "us-east-1"
      annotation                = "tag_region"
      name_alias                = "default_reg"
    }

resource "aci_cloud_aws_provider" "tenant_aws_account" {
        provider_id = aci_cloud_provider_profile.tenant_provider_profile.id
        tenant_dn         = aci_tenant.cloud_tenant.id
        description       = "Created by Terraform"
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

 resource "aci_cloud_epg" "cloud_epg1" {
    cloud_applicationcontainer_dn = aci_cloud_applicationcontainer.cloud_anp.id
    description                   = "Created by Terraform"
    name                          = "PVT_EPG_WEB"
    relation_cloud_rs_cloud_epg_ctx = aci_vrf.cloud_vrf.id
    }

resource "aci_cloud_epg" "cloud_epg2" {
    cloud_applicationcontainer_dn = aci_cloud_applicationcontainer.cloud_anp.id
    description                   = "Created by Terraform"
    name                          = "PVT_EPG_APP"
    relation_cloud_rs_cloud_epg_ctx = aci_vrf.cloud_vrf.id
    }

resource "aci_cloud_endpoint_selector" "cloud_endpoint_selector1" {
        cloud_epg_dn    = aci_cloud_epg.cloud_epg1.id
        description      = "Created by Terraform"
        name             = "PVT_TERRAFORM_EP"
        match_expression = "custom:Type=='${var.endpoint_sel_tag_epg1}'"
        
    }
resource "aci_cloud_endpoint_selector" "cloud_endpoint_selector2" {
        cloud_epg_dn    = aci_cloud_epg.cloud_epg2.id
        description      = "Created by Terraform"
        name             = "PVT_TERRAFORM_EP"
        match_expression = "custom:Type=='${var.endpoint_sel_tag_epg2}'"
        
    }

resource "aci_cloud_external_epg" "cloud_external_epg" {
        cloud_applicationcontainer_dn = aci_cloud_applicationcontainer.cloud_anp.id
        description                   = "Created by Terraform"
        name                          = "${aci_tenant.cloud_tenant.name}_internet_extepg"
        relation_cloud_rs_cloud_epg_ctx = aci_vrf.cloud_vrf.id
        route_reachability = "internet"
    }

resource "aci_cloud_endpoint_selectorfor_external_epgs" "cloud_endpoint_selector_external_epgs" {
        cloud_external_epg_dn = aci_cloud_external_epg.cloud_external_epg.id
        description            = "Created by Terraform"
        name                   = "EXT_EPG_Internet"
        subnet                 = "0.0.0.0/0"
    }

resource "aci_contract" "epg1_to_internet_contract" {
        tenant_dn   = aci_tenant.cloud_tenant.id
        description = "Created by Terraform"
        name        = "epg1_internet_contract"
        scope       = "context"
    }
resource "aci_contract" "epg2_to_internet_contract" {
        tenant_dn   = aci_tenant.cloud_tenant.id
        description = "Created by Terraform"
        name        = "epg2_internet_contract"
        scope       = "context"
    }

resource "aci_contract" "between_epgs_contract" {
        tenant_dn   = aci_tenant.cloud_tenant.id
        description = "Created by Terraform"
        name        = "between_epgs_contract"
        scope       = "context"
    }

 resource "aci_contract_subject" "epg1_to_internet_contract_subject" {
        contract_dn   = aci_contract.epg1_to_internet_contract.id
        description   = "Created by Terraform"
        name          = "to_internet_subject"
        relation_vz_rs_subj_filt_att = [aci_filter.to_internet_filter.id]
    }

 resource "aci_contract_subject" "epg2_to_internet_contract_subject" {
        contract_dn   = aci_contract.epg2_to_internet_contract.id
        description   = "Created by Terraform"
        name          = "to_internet_subject"
        relation_vz_rs_subj_filt_att = [aci_filter.to_internet_filter.id]
    }

 resource "aci_contract_subject" "between_egps_contract_subject" {
        contract_dn   = aci_contract.between_epgs_contract.id
        description   = "Created by Terraform"
        name          = "between_epgs_subject"
        relation_vz_rs_subj_filt_att = [aci_filter.between_epgs_filter.id]
    }

resource "aci_filter" "to_internet_filter" {
    tenant_dn   = aci_tenant.cloud_tenant.id
    description = "Created by Terraform"
    name = "to_internet_filter"
}

 resource "aci_filter_entry" "to_internet_filter_entry" {
        filter_dn     = aci_filter.to_internet_filter.id
        description   = "Created by Terraform"
        name          = "permit_all_internet"
        d_from_port   = "unspecified"
        d_to_port     = "unspecified"
        ether_t       = "unspecified"
        prot          = "unspecified"
        s_from_port   = "unspecified"
        s_to_port     = "unspecified"
    }

resource "aci_filter" "between_epgs_filter" {
    tenant_dn   = aci_tenant.cloud_tenant.id
    description = "Created by Terraform"
    name = "between_epgs_filter"
}

 resource "aci_filter_entry" "between_epgs_filter_https_entry" {
        filter_dn     = aci_filter.between_epgs_filter.id
        description   = "Created by Terraform"
        name          = "permit_https"
        d_from_port   = "443"
        d_to_port     = "443"
        ether_t       = "ipv4"
        prot          = "tcp"
        s_from_port   = "unspecified"
        s_to_port     = "unspecified"
    }

 resource "aci_filter_entry" "between_epgs_filter_http_entry" {
        filter_dn     = aci_filter.between_epgs_filter.id
        description   = "Created by Terraform"
        name          = "permit_http"
        d_from_port   = "80"
        d_to_port     = "80"
        ether_t       = "ipv4"
        prot          = "tcp"
        s_from_port   = "unspecified"
        s_to_port     = "unspecified"
    }

resource "aci_epg_to_contract" "ext_epg_internet_consumer1" {
    application_epg_dn = aci_cloud_external_epg.cloud_external_epg.id
    contract_dn  = aci_contract.epg1_to_internet_contract.id
    contract_type = "consumer"
}

resource "aci_epg_to_contract" "ext_epg_internet_provider1" {
    application_epg_dn = aci_cloud_external_epg.cloud_external_epg.id
    contract_dn  = aci_contract.epg1_to_internet_contract.id
    contract_type = "provider"
}

resource "aci_epg_to_contract" "ext_epg_internet_consumer2" {
    application_epg_dn = aci_cloud_external_epg.cloud_external_epg.id
    contract_dn  = aci_contract.epg2_to_internet_contract.id
    contract_type = "consumer"
}

resource "aci_epg_to_contract" "ext_epg_internet_provider2" {
    application_epg_dn = aci_cloud_external_epg.cloud_external_epg.id
    contract_dn  = aci_contract.epg2_to_internet_contract.id
    contract_type = "provider"
}

resource "aci_epg_to_contract" "epg1_to_internet_provider" {
    application_epg_dn = aci_cloud_epg.cloud_epg1.id
    contract_dn  = aci_contract.epg1_to_internet_contract.id
    contract_type = "provider"
}

resource "aci_epg_to_contract" "epg1_to_internet_consumer" {
    application_epg_dn = aci_cloud_epg.cloud_epg1.id
    contract_dn  = aci_contract.epg1_to_internet_contract.id
    contract_type = "consumer"
}

resource "aci_epg_to_contract" "epg2_to_internet_provider" {
    application_epg_dn = aci_cloud_epg.cloud_epg2.id
    contract_dn  = aci_contract.epg2_to_internet_contract.id
    contract_type = "provider"
}

resource "aci_epg_to_contract" "epg2_to_internet_consumer" {
    application_epg_dn = aci_cloud_epg.cloud_epg2.id
    contract_dn  = aci_contract.epg2_to_internet_contract.id
    contract_type = "consumer"
}

resource "aci_epg_to_contract" "epg1_to_epg2_provider" {
    application_epg_dn = aci_cloud_epg.cloud_epg1.id
    contract_dn  = aci_contract.between_epgs_contract.id
    contract_type = "provider"
}

resource "aci_epg_to_contract" "epg1_to_epg2_consumer" {
    application_epg_dn = aci_cloud_epg.cloud_epg2.id
    contract_dn  = aci_contract.between_epgs_contract.id
    contract_type = "consumer"
}