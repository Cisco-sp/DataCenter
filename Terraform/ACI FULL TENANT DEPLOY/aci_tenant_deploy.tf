provider aci {
    username = var.apic_user
    password = var.apic_pass
    url = "https://${var.apic_ip}"
    insecure = "true"
}

resource "aci_tenant" "terraform_tenant" {
    name = "${var.prefix_name}Tenant"
}

resource "aci_bridge_domain" "web_bd" {
    tenant_dn                   = aci_tenant.terraform_tenant.id
    name                        = "${var.prefix_name}WEB_BD"
    relation_fv_rs_ctx = aci_vrf.tenant_vrf.id
    }

resource "aci_bridge_domain" "app_bd" {
    tenant_dn                   = aci_tenant.terraform_tenant.id
    name                        = "${var.prefix_name}APP_BD"
    relation_fv_rs_ctx = aci_vrf.tenant_vrf.id
    }

resource "aci_bridge_domain" "db_bd" {
    tenant_dn                   = aci_tenant.terraform_tenant.id
    name                        = "${var.prefix_name}DB_BD"
    relation_fv_rs_ctx = aci_vrf.tenant_vrf.id
    }

resource "aci_subnet" "web_subnet" {
    parent_dn        = aci_bridge_domain.web_bd.id
    ip               = "192.168.1.1/24"
    } 

resource "aci_subnet" "app_subnet" {
    parent_dn        = aci_bridge_domain.app_bd.id
    ip               = "192.168.2.1/24"
    } 

resource "aci_subnet" "db_subnet" {
    parent_dn        = aci_bridge_domain.db_bd.id
    ip               = "192.168.3.1/24"
    } 

resource "aci_vrf" "tenant_vrf" {
    tenant_dn              = aci_tenant.terraform_tenant.id
    name                   = "${var.prefix_name}VRF"
}

resource "aci_application_profile" "anp" {
    tenant_dn  = aci_tenant.terraform_tenant.id
    name       = "${var.prefix_name}ANP"
}

resource "aci_application_epg" "web_epg" {
    application_profile_dn  = aci_application_profile.anp.id
    name                    = "${var.prefix_name}WEB_EPG"
    relation_fv_rs_bd = aci_bridge_domain.web_bd.id
  }

resource "aci_application_epg" "app_epg" {
    application_profile_dn  = aci_application_profile.anp.id
    name                    = "${var.prefix_name}APP_EPG"
    relation_fv_rs_bd = aci_bridge_domain.app_bd.id
  }

resource "aci_application_epg" "db_epg" {
    application_profile_dn  = aci_application_profile.anp.id
    name                    = "${var.prefix_name}DB_EPG"
    relation_fv_rs_bd = aci_bridge_domain.db_bd.id
  }



resource "aci_filter" "permit_all_filter" {
    tenant_dn   = aci_tenant.terraform_tenant.id
    name        = "${var.prefix_name}_PERMIT-ALL_FILTER"
    }

resource "aci_filter_entry" "permit_all_entry" {
    filter_dn     = aci_filter.permit_all_filter.id
    name          = "${var.prefix_name}ENTRY_PERMIT_ALL"
    d_from_port   = "unspecified"
    d_to_port     = "unspecified"
    s_from_port   = "unspecified"
    s_to_port     = "unspecified"
    }

resource "aci_contract_subject" "permit_all_web_to_app_subject" {
    contract_dn   = aci_contract.permit_all_web_to_app_contract.id
    name          = "${var.prefix_name}subject"
    relation_vz_rs_subj_filt_att = [aci_filter.permit_all_filter.id]
    }

resource "aci_contract_subject" "permit_all_app_to_db_subject" {
    contract_dn   = aci_contract.permit_all_app_to_db_contract.id
    name          = "${var.prefix_name}subject"
    relation_vz_rs_subj_filt_att = [aci_filter.permit_all_filter.id]
    }


resource "aci_contract" "permit_all_web_to_app_contract" {
    tenant_dn   = aci_tenant.terraform_tenant.id
    name        = "${var.prefix_name}WEB-APP_permit-all"
    scope       = "tenant"

    }

resource "aci_contract" "permit_all_app_to_db_contract" {
    tenant_dn   = aci_tenant.terraform_tenant.id
    name        = "${var.prefix_name}APP-DB_permit-all"
    scope       = "tenant"

    }

resource "aci_epg_to_contract" "web_to_app" {
    application_epg_dn = aci_application_epg.web_epg.id
    contract_dn  = aci_contract.permit_all_web_to_app_contract.id
    contract_type = "consumer"
}

resource "aci_epg_to_contract" "app_to_web" {
    application_epg_dn = aci_application_epg.app_epg.id
    contract_dn  = aci_contract.permit_all_web_to_app_contract.id
    contract_type = "provider"
}

resource "aci_epg_to_contract" "app_to_db" {
    application_epg_dn = aci_application_epg.app_epg.id
    contract_dn  = aci_contract.permit_all_app_to_db_contract.id
    contract_type = "consumer"
}

resource "aci_epg_to_contract" "db_to_app" {
    application_epg_dn = aci_application_epg.db_epg.id
    contract_dn  = aci_contract.permit_all_app_to_db_contract.id
    contract_type = "provider"
}


output "bd_ip_web" {
    value = aci_subnet.web_subnet.ip
}

output "bd_ip_app" {
    value = aci_subnet.app_subnet.ip
}

output "bd_ip_db" {
    value = aci_subnet.db_subnet.ip
}

