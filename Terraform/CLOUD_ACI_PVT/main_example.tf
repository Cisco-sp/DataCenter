
module "cloud_apic" {
    source = "./cloud_apic_deploy"
    cloudapic_fabric_name = "CLOUD-ACI-PVT"
    cloudapic_az = "us-east-1a"
    cloudapic_instance_type  = "m5.2xlarge"
    cloudapic_allowed_extnet = "0.0.0.0/0"
    /*Just create a plain text file and write your own password and save it on the credentials folder, you can change the name of the file above.*/
    cloudapic_password = "./credentials/cloudapic_credentials"
    cloudapic_ssh_key = "cloudapic"
}