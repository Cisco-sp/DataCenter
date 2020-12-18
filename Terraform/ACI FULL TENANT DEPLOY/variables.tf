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

