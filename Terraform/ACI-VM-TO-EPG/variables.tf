variable vmm_domain_name {

}

variable prefix_name {

}

variable apic_user {
    type = string
    description = "Usuário do APIC"
}

variable apic_pass {
    type = string
    description = "Senha do APIC"
    sensitive = true
}

variable apic_ip {

}

variable vsphere_user {
    type = string
    description = "Usuário do vCenter"
}

variable vsphere_password {
    type = string
    description = "Senha do vCenter"
}

variable vsphere_server {

}

variable vsphere_dc {

}

variable vsphere_cluster {

}

variable web_template_name {

}

variable app_template_name {
    
}

variable db_template_name {
}

variable vsphere_host1{

}
variable vsphere_host2{
    
}
variable vsphere_host3{
    
}
variable vsphere_host4{
    
}