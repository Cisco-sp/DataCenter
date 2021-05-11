##Tenant creation
resource "aci_tenant" "tenant" {
    name = "${var.env_prefix}tenant"
}

##VRF creation, and attachment to the tenant above.
resource "aci_vrf" "prod_vrf" {
    tenant_dn = aci_tenant.tenant.id
    name = "${var.env_prefix}prod_vrf"
}

##VRF creation, and attachment to the tenant above.
resource "aci_vrf" "qa_vrf" {
    tenant_dn = aci_tenant.tenant.id
    name = "${var.env_prefix}qa_vrf"
}

##VRF creation, and attachment to the tenant above.
resource "aci_vrf" "dev_vrf" {
    tenant_dn = aci_tenant.tenant.id
    name = "${var.env_prefix}dev_vrf"
}

