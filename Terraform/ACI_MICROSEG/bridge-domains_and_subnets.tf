##Bridge Domain creation and attaching to VRF.
resource "aci_bridge_domain" "prod_bd" {
    tenant_dn = aci_tenant.tenant.id
    name = "${var.env_prefix}bd_1"
    relation_fv_rs_ctx = aci_vrf.prod_vrf.id
}

##Bridge Domain creation and attaching to VRF.
resource "aci_bridge_domain" "qa_bd" {
    tenant_dn = aci_tenant.tenant.id
    name = "${var.env_prefix}bd_2"
    relation_fv_rs_ctx = aci_vrf.qa_vrf.id
}

##Bridge Domain creation and attaching to VRF.
resource "aci_bridge_domain" "dev_bd" {
    tenant_dn = aci_tenant.tenant.id
    name = "${var.env_prefix}dev_bd"
    relation_fv_rs_ctx = aci_vrf.dev_vrf.id
}

##Subnet creation and attaching to a bridge domain, this is used as the gateway outside of the Bridge Domain.
resource "aci_subnet" "prod_subnet" {
    parent_dn = aci_bridge_domain.prod_bd.id
    ip = var.subnets[0]
}

##Subnet creation and attaching to a bridge domain, this is used as the gateway outside of the Bridge Domain.
resource "aci_subnet" "qa_subnet" {
    parent_dn = aci_bridge_domain.qa_bd.id
    ip = var.subnets[1]
}

##Subnet creation and attaching to a bridge domain, this is used as the gateway outside of the Bridge Domain.
resource "aci_subnet" "dev_subnet" {
    parent_dn = aci_bridge_domain.dev_bd.id
    ip = var.subnets[2]
}