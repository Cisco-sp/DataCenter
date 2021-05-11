##ANP creation 
resource "aci_application_profile" "anp" {
    tenant_dn  = aci_tenant.tenant.id
    name       = "${var.env_prefix}MEAN-STACK_anp"
}


##EPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "base_prod_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}base_prod_epg"
    relation_fv_rs_bd = aci_bridge_domain.prod_bd.id
}

##EPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "base_qa_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}base_qa_epg"
    relation_fv_rs_bd = aci_bridge_domain.qa_bd.id
}

##EPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "base_dev_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}base_dev_epg"
    relation_fv_rs_bd = aci_bridge_domain.dev_bd.id
}



