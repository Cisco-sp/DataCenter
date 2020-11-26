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
    
}