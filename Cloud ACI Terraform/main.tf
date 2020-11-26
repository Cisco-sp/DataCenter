provider aws {
    region = var.aws_region
    share_credentials_file = "C:/Users/heprado/Documents/Github/DataCenter/Cloud ACI Terraform/aws_credentials"
    profile = "default"
}


provider mso {
    username = var.mso_username
    password = var.mso_password
    url = var.mso_url
}


provider vsphere {
    user = var.vsphere_username
    password = var.vsphere_password
    vsphere_server = var.vsphere_url
}

data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_dc_name
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vsphere_cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "public"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "Itau-Teste"
  compute_cluster =  data.vsphere_compute_cluster.compute_cluster.id
  datastore_id     = data.vsphere_datastore.datastore.id}

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
}