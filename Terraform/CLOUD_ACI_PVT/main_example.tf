module "cloud_apic" {
    providers = { 
        aws = aws.cloud_apic_deploy
    }
    source = "./cloud_apic_deploy"
    cloudapic_fabric_name = "CLOUD-ACI-PVT"
    cloudapic_az = "us-east-1a"
    cloudapic_instance_type  = "m5.2xlarge"
    cloudapic_allowed_extnet = "0.0.0.0/0"
    cloudapic_ssh_key = "cloudapic"
    CLOUD_APIC_PASSWORD = var.CLOUD_APIC_PASSWORD
}

module "deploy_cloud_aci_tenant" {
    providers = {
        aws = aws.deploy_cloud_aci_tenant
    } 
    TENANT_ACCOUNT_ID = var.TENANT_ACCOUNT_ID
    TENANT_ACCOUNT_ACCESS_KEY = var.TENANT_ACCOUNT_ACCESS_KEY
    TENANT_ACCOUNT_SECRET_KEY_ID = var.TENANT_ACCOUNT_SECRET_KEY_ID
    source = "./deploy_cloud_aci_tenant"
    cloudvrf_name= "PVT_Terraform-VRF"
    anp_name = "PVT_ANP"
    tenant_region = "us-east-1"
    tenant_cidr = "192.168.0.0/16"
    tenant_subnets = {
        "subnets" : [

            { 
            "name":"Subnet1"   
            "subnet":"192.168.1.0/24",
            "az":"us-east-1a"
            },

            {  
            "name" : "Subnet2"  
            "subnet":"192.168.2.0/24",
            "az":"us-east-1b"

            }

        ]
    }
    ec2_ssh_key_name = "PVT_EC2"
    endpoint_sel_tag_epg1 = "NGINX"
    endpoint_sel_tag_epg2 = "Backend"
}

output "ec2_epg1_public_ip" {
    value = module.deploy_cloud_aci_tenant.public_ip_ec2_epg1
}

output "ec2_epg2_public_ip" {
    value = module.deploy_cloud_aci_tenant.public_ip_ec2_epg2
}

output "ec2_epg1_private_ip" {
    value = module.deploy_cloud_aci_tenant.private_ip_ec2_epg1
}

output "ec2_epg2_private_ip" {
    value = module.deploy_cloud_aci_tenant.private_ip_ec2_epg2
}

