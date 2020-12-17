provider aci {
    username = "admin"
    password = "1234Qwer"
    url = "https://10.97.39.125"
    insecure = "true"
}

provider vsphere {

}

resource aci_tenant "VoE_Tenant" {
    name = "VoE_Tenant"
}

