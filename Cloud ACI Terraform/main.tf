provider aws {
    region = var.aws_region
    share_credentials_file = "C:/Users/heprado/Documents/Github/DataCenter/Cloud ACI Terraform/aws_credentials"
    profile = "default"
}

resource "aws_key_pair" "deployer" {
  key_name   = "itau_terraform_test_key"
  public_key = file()
}

resource "aws_instance" "itau_instance" {
    ami = "ami-0c3c87b7d583d618f"
    vpc_security_group_ids = [aws_security_group.allow_all_sg.id]
    key_name = aws_key_pair.deployer.key_name
    subnet_id = aws_subnet.heprado_subnet.id
    associate_public_ip_address = true
    instance_type = "t3.micro"
    tags = {
        Name = "ITAU_Cloud-HOST1"
    }
}


provider aci {
    username = var.capic_username
    password = var.capic_password
    url = var.capic_url
}

data "aci_tenant" "cisco_tenant" {
  name  = "CISCO1"
}

resource "aci_vrf" "cisco_vrf" {
  tenant_dn              = aci_tenant.cisco_tenant.id
  name                   = "cisco_dev_vrf"
}

resource "aci_cloud_context_profile" "cisco_ctx_profile" {
    name                     = "cisco_dev_ctx"
    description              = "Cisco Context Profile"
    tenant_dn                = aci_tenant.cisco_tenant.id
    primary_cidr             = "10.251.0.0/16"
    region                   = var.aws_region
    cloud_vendor             = "aws"
    relation_cloud_rs_to_ctx = aci_vrf.cisco_vrf.id
}

resource "aci_cloud_subnet" "cisco_subnet1" {
    cloud_cidr_pool_dn = aci_cloud_cidr_pool.cisco_cidr_pool.id
    description        = "cisco_dev_subnet1"
    ip                 = "10.251.1.0/24"
    name_alias         = "cisco_dev_subnet1"
}

resource "aci_cloud_subnet" "cisco_subnet2" {
    cloud_cidr_pool_dn = aci_cloud_cidr_pool.cisco_cidr_pool.id
    description        = "cisco_dev_subnet2"
    ip                 = "10.251.2.0/24"
    name_alias         = "cisco_dev_subnet2"
}

resource "aci_cloud_cidr_pool" "cisco_cidr_pool" {
    cloud_context_profile_dn = aci_cloud_context_profile.cisco_ctx_profile.id
    description              = "cloud CIDR"
    addr                     = "10.251.0.0/16"
    annotation               = "tag_cidr"
    name_alias               = "%s"
    primary                  = "yes"
}

resource "aci_cloud_providers_region" "foocloud_providers_region" {
    cloud_provider_profile_dn = "${aci_cloud_provider_profile.example.id}"
    description               = "aws region"
    name                      = "us-east-1"
    annotation                = "tag_region"
    name_alias                = "default_reg"
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
  name             = "Itau_Cloud-HOST2"
  compute_cluster =  data.vsphere_compute_cluster.compute_cluster.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

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