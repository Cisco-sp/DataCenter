provider aci {
    username = var.apic_user
    password = var.apic_pass
    url = "https://${var.apic_ip}"
    insecure = "true"
}



resource aci_tenant "terraform_tenant" {
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

data "aci_vmm_domain" "vmm_domain" {
  provider_profile_dn  = "uni/vmmp-VMware" 
  name                 = var.vmm_domain_name
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

resource "aci_epg_to_domain" "web_epg_domain" {

  application_epg_dn    = aci_application_epg.web_epg.id
  tdn                   = data.aci_vmm_domain.vmm_domain.id

}

resource "aci_epg_to_domain" "app_epg_domain" {

  application_epg_dn    = aci_application_epg.app_epg.id
  tdn                   = data.aci_vmm_domain.vmm_domain.id
  
}

resource "aci_epg_to_domain" "db_epg_domain" {

  application_epg_dn    = aci_application_epg.db_epg.id
  tdn                   = data.aci_vmm_domain.vmm_domain.id
  
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

####################################################################################################################


provider vsphere {
    user = var.vsphere_user
    password = var.vsphere_password
    vsphere_server = var.vsphere_server
    allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_dc
}
data "vsphere_compute_cluster" "cluster" {
  name = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore1" {
  name          = "Storage 2 - 10.97.39.155"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore2" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}


data "vsphere_host" "host1" {
  name          = var.vsphere_host1
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host2" {
  name          = var.vsphere_host2
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host3" {
  name          = var.vsphere_host3
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host4" {
  name          = var.vsphere_host4
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "web_port_group" {
  name          = "${aci_tenant.terraform_tenant.name}|${aci_application_profile.anp.name}|${aci_application_epg.web_epg.name}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "app_port_group" {
  name          = "${aci_tenant.terraform_tenant.name}|${aci_application_profile.anp.name}|${aci_application_epg.app_epg.name}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "db_port_group" {
  name          = "${aci_tenant.terraform_tenant.name}|${aci_application_profile.anp.name}|${aci_application_epg.db_epg.name}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "web_template" {
  name          = "VM_EPG_WEB"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "app_template" {
  name          = "VM_EPG_APP"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "db_template" {
  name          = "VM_EPG_DB"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "web_vm" {
  name             = "FRONTEND-1"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore2.id
  guest_id = data.vsphere_virtual_machine.web_template.guest_id
  scsi_type = data.vsphere_virtual_machine.web_template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.web_port_group.id
  }
disk {
    label            = "disk0"
    size             = "10"
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.web_template.id
  }
}

resource "vsphere_virtual_machine" "app_vm" {
  name             = "FRONTEND-1"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore2.id
  guest_id = data.vsphere_virtual_machine.app_template.guest_id
  scsi_type = data.vsphere_virtual_machine.app_template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.app_port_group.id
  }

disk {
    label            = "disk0"
    size             = "10"
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.app_template.id
  }
}

resource "vsphere_virtual_machine" "db_vm" {
  name             = "MONGODB-1"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore1.id
  guest_id = data.vsphere_virtual_machine.db_template.guest_id
  scsi_type = data.vsphere_virtual_machine.db_template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.db_port_group.id
  }
  disk {
    label            = "disk0"
    size             = "10"
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.db_template.id
  }
}