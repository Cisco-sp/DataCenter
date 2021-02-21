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
}

module "deploy_cloud_aci_tenant" {
    depends_on = [ module.cloud_apic ]
    providers = {
        aws = aws.deploy_cloud_aci_tenant
    } 
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

