/*This file has all the configuration for the MicroEPG that will be configured in ACI, the is_attr_based_epg is the variable that defines the EPG
as a MicroEPG*/


locals {
    prod_tag = "PROD"
    prod_nodejs_microepg_filter = "NODEJS"
    prod_expressjs_microepg_filter = "EXPRESSJS"
    prod_angular_microepg_filter = "ANGULAR"
    prod_mongo_microepg_filter = "MONGO"
    qa_tag = "QA"
    qa_nodejs_microepg_filter = "NODEJS"
    qa_expressjs_microepg_filter = "EXPRESSJS"
    qa_angular_microepg_filter = "ANGULAR"
    qa_mongo_microepg_filter = "MONGO"
    dev_tag = "DEV"
    dev_nodejs_microepg_filter = "NODEJS"
    dev_expressjs_microepg_filter = "EXPRESSJS"
    dev_angular_microepg_filter = "ANGULAR"
    dev_mongo_microepg_filter = "MONGO"
    
}

##################### *********PROD Micro EPGS*********** ###############################################

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "prod_nodejs_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}prod_nodejs_epg"
    relation_fv_rs_bd = aci_bridge_domain.prod_bd.id
    is_attr_based_epg = "yes"
}

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "prod_angular_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}prod_angular_epg"
    relation_fv_rs_bd = aci_bridge_domain.prod_bd.id
    is_attr_based_epg = "yes"
}

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "prod_expressjs_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}prod_expressjs_epg"
    relation_fv_rs_bd = aci_bridge_domain.prod_bd.id
    is_attr_based_epg = "yes"
}

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "prod_mongodb_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}prod_mongodb_epg"
    relation_fv_rs_bd = aci_bridge_domain.prod_bd.id
    is_attr_based_epg = "yes"
}

##################### *********QA Micro EPGS*********** ###############################################

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "qa_nodejs_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}qa_nodejs_epg"
    relation_fv_rs_bd = aci_bridge_domain.qa_bd.id
    is_attr_based_epg = "yes"
}

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "qa_angular_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}qa_angular_epg"
    relation_fv_rs_bd = aci_bridge_domain.qa_bd.id
    is_attr_based_epg = "yes"
}

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "qa_expressjs_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}qa_expressjs_epg"
    relation_fv_rs_bd = aci_bridge_domain.qa_bd.id
    is_attr_based_epg = "yes"
}

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "qa_mongodb_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}qa_mongodb_epg"
    relation_fv_rs_bd = aci_bridge_domain.qa_bd.id
    is_attr_based_epg = "yes"
}

##################### *********DEV Micro EPGS*********** ###############################################

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "dev_nodejs_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}dev_nodejs_epg"
    relation_fv_rs_bd = aci_bridge_domain.dev_bd.id
    is_attr_based_epg = "yes"
}

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "dev_angular_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}dev_angular_epg"
    relation_fv_rs_bd = aci_bridge_domain.dev_bd.id
    is_attr_based_epg = "yes"
}

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "dev_expressjs_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}dev_expressjs_epg"
    relation_fv_rs_bd = aci_bridge_domain.dev_bd.id
    is_attr_based_epg = "yes"
}

##MicroEPG creation and and attaching the EPG to one Bridge Domain.
resource "aci_application_epg" "dev_mongodb_epg" {
    application_profile_dn = aci_application_profile.anp.id
    name = "${var.env_prefix}dev_mongodb_epg"
    relation_fv_rs_bd = aci_bridge_domain.dev_bd.id
    is_attr_based_epg = "yes"
}

##################### *********PROD uSEG Filters*********** ###############################################

resource "aci_rest" "prod_nodejs_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_nodejs_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_nodejs_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_nodejs_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.prod_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_nodejs_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.prod_nodejs_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}

resource "aci_rest" "prod_expressjs_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_expressjs_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_expressjs_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_expressjs_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.prod_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_expressjs_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.prod_nodejs_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}

resource "aci_rest" "prod_angular_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_angular_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_angular_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_angular_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.prod_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_angular_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.prod_angular_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}


resource "aci_rest" "prod_mongo_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_mongodb_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_mongodb_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_mongodb_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.prod_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.prod_mongodb_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.prod_mongo_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}

##################### *********QA uSEG Filters*********** ###############################################

resource "aci_rest" "qa_nodejs_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_nodejs_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_nodejs_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_nodejs_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.qa_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_nodejs_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.qa_nodejs_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}

resource "aci_rest" "qa_expressjs_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_expressjs_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_expressjs_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_expressjs_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.qa_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_expressjs_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.qa_nodejs_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}

resource "aci_rest" "qa_angular_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_angular_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_angular_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_angular_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.qa_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_angular_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.qa_angular_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}


resource "aci_rest" "qa_mongo_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_mongodb_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_mongodb_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_mongodb_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.qa_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.qa_mongodb_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.qa_mongo_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}


##################### *********DEV uSEG Filters*********** ###############################################

resource "aci_rest" "dev_nodejs_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_nodejs_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_nodejs_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_nodejs_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.dev_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_nodejs_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.dev_nodejs_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}

resource "aci_rest" "dev_expressjs_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_expressjs_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_expressjs_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_expressjs_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.dev_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_expressjs_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.dev_nodejs_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}

resource "aci_rest" "dev_angular_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_angular_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_angular_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_angular_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.dev_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_angular_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.dev_angular_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}


resource "aci_rest" "dev_mongo_useg_filter" {
  path       = "${var.apic_address}/api/node/mo/uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_mongodb_epg.name}/crtrn.json"
  payload = <<EOF
{
   "fvCrtrn":{
      "attributes":{
         "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_mongodb_epg.name}/crtrn",
         "name":"default",
         "match":"all",
         "prec":"0",
         "childAction":"deleteNonPresent",
         "status":"created,modified"
      },
      "children":[
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_mongodb_epg.name}/crtrn/vmattr-0",
                  "name":"0",
                  "type":"tag",
                  "operator":"equals",
                  "value":"${local.dev_tag}",
                  "category":"enviroment",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         },
         {
            "fvVmAttr":{
               "attributes":{
                  "dn":"uni/tn-${aci_tenant.tenant.name}/ap-${aci_application_profile.anp.name}/epg-${aci_application_epg.dev_mongodb_epg.name}/crtrn/vmattr-1",
                  "name":"1",
                  "type":"vm-name",
                  "operator":"contains",
                  "value":"${local.dev_mongo_microepg_filter}",
                  "childAction":"deleteNonPresent",
                  "status":"created,modified"
               },
               "children":[
                  
               ]
            }
         }
      ]
   }
}
  EOF
}