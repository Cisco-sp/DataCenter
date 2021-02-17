
resource "null_resource" "public_private_key" {
    provisioner "local-exec" {
        command = "ssh-keygen -f ${path.root}/credentials/${var.cloudapic_ssh_key}_terraform -m pem -N ''"
        }
    
    provisioner "local-exec" {
        when = destroy
        command = "rm ${path.root}/credentials/*_terraform"
    }
    
    provisioner "local-exec" {
        when = destroy
        command = "rm ${path.root}/credentials/*_terraform.pub"
    }

}

data "local_file" "read_key" {
   
    depends_on = [null_resource.public_private_key]
    filename = "${path.root}/credentials/${var.cloudapic_ssh_key}_terraform.pub"
}

data "local_file" "cloudapic_password" {
    filename = var.cloudapic_password
}


resource "aws_key_pair" "cloudapic_key" {
    key_name = var.cloudapic_ssh_key
    
    public_key = data.local_file.read_key.content
}


resource "aws_cloudformation_stack" "cloud_apic" {
    name = "CLOUD-APIC-TERRAFORM-DEPLOYED"
    capabilities = [ "CAPABILITY_NAMED_IAM" ]
    template_body = <<STACK
    {
    "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "This template creates the environment to launch a cloud APIC cluster in an AWS environment.    --AWSMP::6cad9a0e-821a-4f03-881e-fb1f66f4dc1f::1d7e0806-72e4-400a-0db4-78dd7c2c9a77",
    "Metadata": {
        "AWS::CloudFormation::Interface": {
            "ParameterGroups": [
                {
                    "Label": {"default" : "Cloud APIC Configuration"},
                    "Parameters": ["pFabricName", "pInfraVPCPool", "pAvailabilityZone", "pInstanceType", "pPassword", "pConfirmPassword", "pKeyName", "pExtNw"]
                }

            ],
            "ParameterLabels": {
                "pFabricName": {
                    "default": "Fabric Name"
                },
                "pInfraVPCPool": {
                    "default": "Infra VPC Pool"
                },
                "pAvailabilityZone": {
                    "default": "Availability Zone"
                },
                "pInstanceType": {
                    "default": "Instance Type"
                },
                "pExtNw": {
                    "default": "Access Control"
                },
                "pPassword": {
                    "default": "Password"
                },
                "pConfirmPassword": {
                    "default": "Confirm Password"
                },
                "pKeyName": {
                    "default": "SSH Key Pair"
                }
            }
        }
    },
    "Parameters": {
        "pInfraVPCPool": {
            "Description": "IP address pool for Infra VPCs (must be a /24 prefix)",
            "Type": "String",
            "MinLength": "9",
            "MaxLength": "18",
            "Default": "10.10.0.0/24",
            "AllowedPattern": "(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/24",
            "ConstraintDescription": "must be a valid IP CIDR range of the form x.x.x.x/24."
        },
        "pFabricName": {
            "Description": "Fabric Name (must be only alphanumeric chars separated by '-')",
            "Type": "String",
            "MinLength": "4",
            "MaxLength": "64",
            "AllowedPattern": "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$",
            "ConstraintDescription": "must be only alphanumeric (no spaces and special characters are allowed except for '-')",
            "Default": "${var.cloudapic_fabric_name}"
        },
        "pAvailabilityZone": {
            "Description": "Availability zone for Cloud APIC (Must select lexicographically lowest Availability zone)",
            "Type": "AWS::EC2::AvailabilityZone::Name",
            "AllowedPattern": ".+",
            "ConstraintDescription": "must be selected",
            "Default": "${var.cloudapic_az}"
        },
        "pInstanceType": {
            "Description": "Select one of the possible EC2 instance types",
            "Type": "String",
            "Default": "${var.cloudapic_instance_type}",
            "AllowedValues": ["m4.2xlarge", "m5.2xlarge"],
            "ConstraintDescription" : "must be a valid EC2 instance type."
        },
        "pExtNw": {
            "Description": "External network allowed to access Cloud APIC (x.x.x.x/x)",
            "Type": "String",
            "Default" : "${var.cloudapic_allowed_extnet}",
            "MinLength": "9",
            "MaxLength": "18",
            "AllowedPattern": "(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})",
            "ConstraintDescription": "must be a valid IP subnet of the form x.x.x.x/x"
        },
        "pPassword": {
            "Description": "Admin Password for Cloud APIC",
            "Default": "${data.local_file.cloudapic_password.content}",
            "Type": "String",
            "NoEcho": "true",
            "AllowedPattern":"^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$",
            "ConstraintDescription": "Password should contain 8 Characters or more, Atleast 1 letter, number and special character @$!%*#?&"
        },
        "pConfirmPassword": {
            "Description": "Re-Enter Admin Password for Cloud APIC",
            "Default": "${data.local_file.cloudapic_password.content}",
            "Type": "String",
            "NoEcho": "true",
            "AllowedPattern":"^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$",
            "ConstraintDescription": "Password should contain 8 Characters or more, Atleast 1 letter, number and special character @$!%*#?&"
        },
        "pKeyName": {
            "Description": "Name of an existing SSH KeyPair to enable SSH access to Cloud APIC",
            "Default" :"${aws_key_pair.cloudapic_key.key_name}" , 
            "Type": "AWS::EC2::KeyPair::KeyName",
            "AllowedPattern": ".+",
            "ConstraintDescription": "must be selected"
        }
    },
    "Conditions": {
        "cCreateInfraVPC": {
            "Fn::Not" : [{"Fn::Equals": [{"Ref": "pInfraVPCPool"}, "0.0.0.0/0"]}]
        }
    },
    "Rules" : {
      "rMatchPasswords" : {
          "Assertions" : [{
              "Assert" : {"Fn::Equals":[{"Ref":"pPassword"},{"Ref":"pConfirmPassword"}]},
              "AssertDescription" : "Passwords do not match"
            }]
        }
    },
    "Mappings": {
        "Constants": {
            "mTagValues": {
                "aciDnTagKey" : "AciDnTag",
                "aciOwnerTagKey" : "AciOwnerTag",
                "aciCreatedTagKey" : "CiscoAciCapic",
                "aciGCIgnoreTagKey" : "AciGCIgnore"
            }
        },
        "mAWSRegionCapicAmi": {
 		"us-east-1"        : {"amiId" : "ami-0b9b0bf7126bda19e"},
       "us-east-2"        : {"amiId" : "ami-099c5599f2651f0e8"},
       "us-west-1"        : {"amiId" : "ami-002ef3d85d45c9d88"},
       "us-west-2"        : {"amiId" : "ami-0e7cf4d6f35987341"},
       "ca-central-1"     : {"amiId" : "ami-0c87fd2e4808c650a"},
       "eu-central-1"     : {"amiId" : "ami-02f677f539f8f5ec0"},
       "eu-west-1"        : {"amiId" : "ami-0e65f873d92d8734f"},
       "eu-west-2"        : {"amiId" : "ami-04d246fa17bb7753f"},
       "eu-west-3"        : {"amiId" : "ami-09540ea6bd462fecc"},
	   "eu-north-1"       : {"amiId" : "ami-0488b6ce80d35f5b8"},	   
	   "eu-south-1"       : {"amiId" : "ami-08f7cfe26d347c134"},
	   "ap-east-1"       : {"amiId" : "ami-0367f40ccbd5bfa67"},
	   "me-south-1"       : {"amiId" : "ami-0eda24a58f8d9ab9c"},
	   "af-south-1"       : {"amiId" : "ami-00deee808c480c67e"},	   
       "ap-southeast-1"   : {"amiId" : "ami-04a21da72187e5429"},
       "ap-southeast-2"   : {"amiId" : "ami-0918aeb75ffabeca5"},
       "ap-south-1"       : {"amiId" : "ami-0b63af434e2ddd5a4"},
       "ap-northeast-1"   : {"amiId" : "ami-09c028b11fb7f418e"},
       "ap-northeast-2"   : {"amiId" : "ami-0d432b9c9298d9304"},
       "sa-east-1"        : {"amiId" : "ami-0a10c658b0acae23f"}, 
	   "us-gov-west-1"        : {"amiId" : "ami-0dad67d9a61c5591a"},
	   "us-gov-east-1"        : {"amiId" : "ami-013e65df8f6b6d16c"}
        }
    },
    "Resources": {
		"rApicAdminFullAccessPolicy": {
			"Type": "AWS::IAM::ManagedPolicy",
			"Properties": {
				"Description": "Full Access for ApicAdmin Role",
				"ManagedPolicyName": "ApicAdminFullAccess",
				"Path": "/",
				"PolicyDocument": {
					"Version": "2012-10-17",
					"Statement": [{
						"Effect": "Allow",
						"Action": "organizations:*",
						"Resource": "*"
                    }, {
                        "Action": "ec2:*",
                        "Effect": "Allow",
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": "s3:*",
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": "sqs:*",
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": "elasticloadbalancing:*",
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": "acm:*",
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": ["config:*"],
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": "cloudtrail:*",
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": "cloudwatch:*",
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": "logs:*",
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": "resource-groups:*",
                        "Resource": "*"
                    }, {
                        "Sid": "CloudWatchEventsFullAccess",
                        "Effect": "Allow",
                        "Action": "events:*",
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": "autoscaling:*",
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": "ram:*",
                        "Resource": "*"
                    }, {
                        "Effect": "Allow",
                        "Action": [
                            "iam:List*",
                            "iam:Get*",
                            "iam:CreateServiceLinkedRole",
                            "iam:DeleteServiceLinkedRole",
                            "iam:GetServiceLinkedRoleDeletionStatus",
                            "iam:AttachRolePolicy",
                            "iam:PutRolePolicy",
                            "iam:UpdateRoleDescription",
                            "iam:UploadServerCertificate",
                            "iam:DeleteServerCertificate",
                            "iam:UpdateRoleDescription",
                            "iam:PassRole"
                        ],
                        "Resource": "*"
                    }]
				}
			}
    },
    "rApicACMReadOnlyPolicy": {
        "Properties": {
            "Description": "Provides read only access to AWS Certificate Manager (ACM) for cAPIC",
            "ManagedPolicyName": "ApicACMReadOnlyPolicy",
            "Path": "/",
            "PolicyDocument": {
                "Statement": [
                    {
                      "Effect": "Allow",
                      "Action": [
                          "acm:DescribeCertificate",
                          "acm:ListCertificates",
                          "acm:GetCertificate",
                          "acm:ListTagsForCertificate"
                      ],
                      "Resource": "*"
                    }
                ],
                "Version": "2012-10-17"
            }
        },
        "Type": "AWS::IAM::ManagedPolicy"
    },
    "rApicTenantsAccessPolicy": {
			"Type": "AWS::IAM::ManagedPolicy",
			"Properties": {
				"Description": "Tenant Access Policy for ApicAdmin Role",
				"ManagedPolicyName": "ApicTenantsAccess",
				"Path": "/",
				"PolicyDocument": {
					"Version": "2012-10-17",
					"Statement": [{
						"Effect": "Allow",
						"Action": "sts:AssumeRole",
						"Resource": "*"
          }]
				}
			}
		},
		"rApicAdminRole": {
			"Type": "AWS::IAM::Role",
			"Description": "Admin role for C-Apic",
			"Properties": {
				"AssumeRolePolicyDocument": {
					"Version": "2012-10-17",
					"Statement": [{
						"Effect": "Allow",
						"Principal": {
							"Service": ["ec2.amazonaws.com","vpc-flow-logs.amazonaws.com"]
						},
						"Action": ["sts:AssumeRole"]
					}]
				},
				"ManagedPolicyArns": [
                    {
                        "Ref": "rApicAdminFullAccessPolicy"
                    },
                    {
                        "Ref": "rApicTenantsAccessPolicy"
                    }
                ],
                "Path": "/",
                "RoleName": "ApicAdmin"
            }
		},
		"rApicAdminReadOnlyRole": {
			"Type": "AWS::IAM::Role",
			"Description": "Admin role for C-Apic",
			"Properties": {
				"AssumeRolePolicyDocument": {
					"Version": "2012-10-17",
					"Statement": [{
						"Effect": "Allow",
						"Principal": {
							"Service": ["ec2.amazonaws.com","vpc-flow-logs.amazonaws.com"]
						},
						"Action": ["sts:AssumeRole"]
					}]
				},
				"ManagedPolicyArns": [
          "arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess",
					"arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
					"arn:aws:iam::aws:policy/IAMReadOnlyAccess",
          "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
          "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess",
          "arn:aws:iam::aws:policy/AWSCloudTrail_FullAccess",
          "arn:aws:iam::aws:policy/CloudWatchFullAccess",
          "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
          "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess",
          {
            "Ref": "rApicACMReadOnlyPolicy"
          }
        ],
        "Path": "/",
        "RoleName": "ApicAdminReadOnly"
       }
		},
		"rApicAdminInstanceProfile": {
			"Type": "AWS::IAM::InstanceProfile",
			"Properties": {
				"Path": "/",
				"Roles": [{
					"Ref": "rApicAdminRole"
				}]
			}
		},
		"rApicAdminReadOnlyInstanceProfile": {
			"Type": "AWS::IAM::InstanceProfile",
			"Properties": {
				"Path": "/",
				"Roles": [{
					"Ref": "rApicAdminReadOnlyRole"
				}]
			}
		},
        "rInfraVPC": {
            "Condition": "cCreateInfraVPC",
            "Type": "AWS::EC2::VPC",
            "Properties": {
                "EnableDnsSupport": "true",
                "EnableDnsHostnames": "true",
                "CidrBlock": { "Fn::Join" : ["/", [
                    {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]},
                    "25"
                ]]},
                "Tags": [
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciCreatedTagKey" ]},
                        "Value":""},
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciOwnerTagKey" ]},
                        "Value": {"Fn::Join": [ "", [{"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }, "_", {"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }] ] } },
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciGCIgnoreTagKey" ]},
                        "Value":""},
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciDnTagKey" ]},
                        "Value": {"Fn::Join": [ "", [ "acct-[infra]/region-[", { "Ref": "AWS::Region" }, "]/context-[overlay-1]-addr-[", { "Fn::Join" : ["/", [ {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]}, "25" ]]}, "]" ] ] } },
                    { "Key":"Name",
                        "Value": {"Fn::Join": [ "", [ "context-[overlay-1]-addr-[", { "Fn::Join" : ["/", [ {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]}, "25" ]]}, "]" ] ] } }
                ]
            }
        },
        "rInfraVPCInternetGateway": {
            "Type": "AWS::EC2::InternetGateway",
            "Properties": {
                "Tags": [
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciCreatedTagKey" ]},
                        "Value":""},
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciOwnerTagKey" ]},
                        "Value": {"Fn::Join": [ "", [{"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }, "_", {"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }] ] } },
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciGCIgnoreTagKey" ]},
                        "Value":""},
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciDnTagKey" ]},
                        "Value": {"Fn::Join": [ "", [ "acct-[infra]/region-[", { "Ref": "AWS::Region" }, "]/context-[overlay-1]-addr-[", { "Fn::Join" : ["/", [ {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]}, "25" ]]}, "]/igw" ] ] } },
                    {"Key":"Name", "Value": "igw" }
                ]
            },
            "DependsOn": ["rInfraVPC"]
        },
        "rInfraVPCIgwAttachment": {
            "Type": "AWS::EC2::VPCGatewayAttachment",
            "Properties": {
                "InternetGatewayId": {"Ref": "rInfraVPCInternetGateway"},
                "VpcId": {"Ref": "rInfraVPC"}
            }
        },
        "rInfraVPCPublicRouteTable": {
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {"Ref": "rInfraVPC"},
                "Tags": [
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciCreatedTagKey" ]},
                        "Value":""},
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciOwnerTagKey" ]},
                        "Value": {"Fn::Join": [ "", [{"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }, "_", {"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }] ] } },
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciGCIgnoreTagKey" ]},
                        "Value":""},
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciDnTagKey" ]},
                        "Value": {"Fn::Join": [ "", [ "acct-[infra]/region-[", { "Ref": "AWS::Region" }, "]/context-[overlay-1]-addr-[", { "Fn::Join" : ["/", [ {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]}, "25" ]]}, "]/routetable-[", { "Fn::Join" : [".", [ {"Fn::Select" :[0,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]}, {"Fn::Select" :[1,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]}, {"Fn::Select" :[2,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]}, "16/28" ]]}, "]" ] ] } },
                    {"Key":"Name", "Value": {"Fn::Join": [ "", [ "routetable-[", { "Fn::Join" : [".", [ {"Fn::Select" :[0,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]}, {"Fn::Select" :[1,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]}, {"Fn::Select" :[2,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]}, "16/28" ]]}, "]" ] ] } }
                ]
            }
        },
        "rInfraVPCPublicRoute": {
            "Type": "AWS::EC2::Route",
            "Properties": {
                "DestinationCidrBlock": "0.0.0.0/0",
                "RouteTableId": {"Ref": "rInfraVPCPublicRouteTable"},
                "GatewayId": {"Ref": "rInfraVPCInternetGateway"}
            },
            "DependsOn": ["rInfraVPCIgwAttachment"]
        },
        "rCAPICOOBSecurityGroup": {
            "Type": "AWS::EC2::SecurityGroup",
            "Properties": {
                "VpcId": {"Ref": "rInfraVPC"},
                "GroupDescription": "uni/tn-infra/cloudapp-cloud-infra/cloudepg-controllers",
                "GroupName": "uni/tn-infra/cloudapp-cloud-infra/cloudepg-controllers",
                "Tags": [
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciCreatedTagKey" ]},
                        "Value":""},
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciOwnerTagKey" ]},
                        "Value": {"Fn::Join": [ "", [{"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }, "_", {"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }] ] } },
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciGCIgnoreTagKey" ]},
                        "Value":""},
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciDnTagKey" ]},
                        "Value": {"Fn::Join": [ "", [ "acct-[infra]/region-[", { "Ref": "AWS::Region" }, "]/context-[overlay-1]-addr-[", { "Fn::Join" : ["/", [ {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]}, "25" ]]}, "]/sgroup-[uni/tn-infra/cloudapp-cloud-infra/cloudepg-controllers]" ] ] } },
                    {"Key":"Name", "Value": "sgroup-[uni/tn-infra/cloudapp-cloud-infra/cloudepg-controllers]"}
                ]
            }
        },
        "rCAPICInfraSecurityGroup": {
            "Type": "AWS::EC2::SecurityGroup",
            "Properties": {
                "VpcId": {"Ref": "rInfraVPC"},
                "GroupDescription": "Allow All Traffic"
            }
        },
        "rCAPICInfraAllTrafficRule": {
            "Type": "AWS::EC2::SecurityGroupIngress",
            "Properties":{
                "CidrIp": "0.0.0.0/0",
                "IpProtocol": "-1",
                "FromPort": "-1",
                "ToPort": "-1",
                "GroupId": { "Ref": "rCAPICInfraSecurityGroup" }
            }
        },
        "rCAPICOOBSecurityGroupHTTPSIngressRuleCidr": {
          "Type": "AWS::EC2::SecurityGroupIngress",
          "Properties":{
              "CidrIp": {"Ref": "pExtNw"},
              "IpProtocol": "tcp",
              "FromPort": "443",
              "ToPort": "443",
              "GroupId": { "Ref": "rCAPICOOBSecurityGroup" }
            }
        },
        "rCAPICOOBSecurityGroupSSHIngressRuleCidr": {
            "Type": "AWS::EC2::SecurityGroupIngress",
            "Properties":{
                "CidrIp": {"Ref": "pExtNw"},
                "IpProtocol": "tcp",
                "FromPort": "22",
                "ToPort": "22",
                "GroupId": { "Ref": "rCAPICOOBSecurityGroup" }
            }
        },
        "rCAPICOOBSecurityGroupICMPIngressRuleCidr": {
            "Type": "AWS::EC2::SecurityGroupIngress",
            "Properties":{
                "CidrIp": {"Ref": "pExtNw"},
                "IpProtocol": "icmp",
                "FromPort": "-1",
                "ToPort": "-1",
                "GroupId": { "Ref": "rCAPICOOBSecurityGroup" }
            }
        },
        "rCAPICOOBSecurityGroupAllEgressRule": {
            "Type": "AWS::EC2::SecurityGroupEgress",
            "Properties":{
                "CidrIp": "0.0.0.0/0",
                "IpProtocol": "-1",
                "GroupId": { "Ref": "rCAPICOOBSecurityGroup" }
            }
        },
        "rCAPICInfraSubnet": {
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {"Ref" : "rInfraVPC"},
                "CidrBlock": { "Fn::Join" : ["/", [
                    {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]},
                    "28"
                ]]},
                "AvailabilityZone": {"Ref": "pAvailabilityZone"},
                "Tags": [
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciCreatedTagKey" ]},
                        "Value":""},
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciOwnerTagKey" ]},
                        "Value": {"Fn::Join": [ "", [{"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }, "_", {"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }] ] } },
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciGCIgnoreTagKey" ]},
                        "Value":""},
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciDnTagKey" ]},
                        "Value": {"Fn::Join": [ "", [ "acct-[infra]/region-[", { "Ref": "AWS::Region" }, "]/context-[overlay-1]-addr-[", { "Fn::Join" : ["/", [ {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]}, "25" ]]}, "]/cidr-[", {"Fn::GetAtt":["rInfraVPC", "CidrBlock"]}, "]/subnet-[",  { "Fn::Join" : ["/", [ {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]}, "28" ]]}, "]" ] ] } },
                    {"Key":"Name", "Value": {"Fn::Join": [ "", [ "subnet-[",  { "Fn::Join" : ["/", [ {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]}, "28" ]]}, "]" ] ] } }
                ]
            }
        },
        "rCAPICOOBSubnet":{
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {"Ref" : "rInfraVPC"},
                "CidrBlock": { "Fn::Join" : [".", [
                    {"Fn::Select" :[0,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                    {"Fn::Select" :[1,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                    {"Fn::Select" :[2,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                    "16/28"
                ]]},
                "AvailabilityZone": {"Ref": "pAvailabilityZone"},
                "Tags": [
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciCreatedTagKey" ]},
                        "Value":""},
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciOwnerTagKey" ]},
                        "Value": {"Fn::Join": [ "", [{"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }, "_", {"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }] ] } },
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciGCIgnoreTagKey" ]},
                        "Value":""},
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciDnTagKey" ]},
                        "Value": {"Fn::Join": [ "", [ "acct-[infra]/region-[", { "Ref": "AWS::Region" }, "]/context-[overlay-1]-addr-[", { "Fn::Join" : ["/", [ {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]}, "25" ]]}, "]/cidr-[", {"Fn::GetAtt":["rInfraVPC", "CidrBlock"]}, "]/subnet-[",  { "Fn::Join" : [".", [ {"Fn::Select" :[0,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]}, {"Fn::Select" :[1,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},       {"Fn::Select" :[2,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]}, "16/28" ]]}, "]" ] ] } },
                    {"Key":"Name", "Value": {"Fn::Join": [ "", [ "subnet-[",  { "Fn::Join" : [".", [ {"Fn::Select" :[0,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]}, {"Fn::Select" :[1,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]}, {"Fn::Select" :[2,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]}, "16/28" ]]}, "]" ] ] } }
                ]
            }
        },
        "rOOBSubnetRouteTableAssociation": {
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "RouteTableId": {"Ref" : "rInfraVPCPublicRouteTable"},
                "SubnetId": {"Ref": "rCAPICOOBSubnet"}
            }
        },
        "rCAPICOOBInterface":{
            "Type" : "AWS::EC2::NetworkInterface",
            "Properties":{
                "Description" :"CAPIC-1 Interface for OOB management",
                "SubnetId": { "Ref": "rCAPICOOBSubnet"},
                "GroupSet": [{"Ref": "rCAPICOOBSecurityGroup"}],
                "PrivateIpAddress": { "Fn::Join" : [".", [
                    {"Fn::Select" :[0,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                    {"Fn::Select" :[1,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                    {"Fn::Select" :[2,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                    "29"
                ]]},
                "Tags": [{"Key":"type", "Value":"OOB"},
                         {"Key":"cloud-controller", "Value":"capic"}
                ]
            }
        },
        "rCAPICInfraInterface":{
            "Type" : "AWS::EC2::NetworkInterface",
            "Properties":{
                "Description" :"CAPIC-1 Interface for Infra Communication",
                "SubnetId": { "Ref": "rCAPICInfraSubnet"},
                "GroupSet": [{"Ref": "rCAPICInfraSecurityGroup"}],
                "PrivateIpAddress": { "Fn::Join" : [".", [
                    {"Fn::Select" :[0,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                    {"Fn::Select" :[1,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                    {"Fn::Select" :[2,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                    "13"
                ]]},
                "Tags": [{"Key":"type", "Value":"INFRA"},
                         {"Key":"cloud-controller", "Value":"capic"}
                ]
            }
        },
        "rCAPICInstance": {
            "Type": "AWS::EC2::Instance",
            "Properties": {
                "InstanceType": { "Ref": "pInstanceType" },
                "BlockDeviceMappings" : [
                    {
                        "DeviceName" : "/dev/xvda",
                        "Ebs" : { "VolumeType" : "gp2" }
                    },
                    {
                        "DeviceName" : "/dev/xvdb",
                        "Ebs" : { "VolumeType" : "gp2" }
                    }
                ],
                "Tags": [
                    { "Key": "Name", "Value": "Capic-1"},
                    { "Key":{ "Fn::FindInMap" : [ "Constants", "mTagValues", "aciCreatedTagKey" ]},
                        "Value":""},
                    { "Key": { "Fn::FindInMap" : [ "Constants", "mTagValues", "aciOwnerTagKey" ]},
                        "Value": {"Fn::Join": [ "", [{"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }, "_", {"Ref": "AWS::AccountId"}, "_", { "Ref": "AWS::Region" }] ] } }
                ],
                "ImageId": {"Fn::FindInMap": ["mAWSRegionCapicAmi",{"Ref": "AWS::Region"},"amiId"]},
                "KeyName" : { "Ref" : "pKeyName" },
                "NetworkInterfaces": [
                    {"NetworkInterfaceId" : {"Ref" : "rCAPICOOBInterface"}, "DeviceIndex" : "0"},
                    {"NetworkInterfaceId" : {"Ref" : "rCAPICInfraInterface"}, "DeviceIndex": "1"}
                ],
                "IamInstanceProfile": {
                  "Ref": "rApicAdminInstanceProfile"
                },
                "UserData": {"Fn::Base64": { "Fn::Sub":[ "{\"site_id\": \"$${SiteId}\", \"domain\": \"$${FabricName}\",\"cluster_size\": $${ClusterSize},\"ifc_id\": $${IFCId},\"password\": \"$${Password}\",\"tep_pool\": \"$${TepPool}\",\"infra_subnet\": \"$${InfraSubnet}\", \"account_id\": \"$${AwsAccountId}\", \"region\": \"$${AwsRegion}\", \"infra_nic_tag\": \"$${InfraNicTag}\", \"oob_nic_tag\": \"$${OobNicTag}\", \"oob_public_ip\": \"$${OobPublicIp}\",\"external_networks\":\"$${ExternalNetworks}\", \"infra_vpc_pool\":\"$${InfraVpcPool}\", \"user_subnet\":\"$${UserSubnet}\", \"oob_subnet\": \"$${OobSubnet}\"}",
                                                        {
                                                          "SiteId": "1",
                                                          "FabricName": {"Ref": "pFabricName"},
                                                          "ClusterSize": "1",
                                                          "IFCId": "1",
                                                          "Password": {"Ref": "pPassword"},
                                                          "TepPool": { "Fn::Join" : [".", [
                                                              {"Fn::Select" :[0,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                                                              {"Fn::Select" :[1,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                                                              {"Fn::Select" :[2,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                                                              "12/30"
                                                          ]]},
                                                          "InfraSubnet": { "Fn::Join" : ["/", [
                                                              {"Fn::Select" :[0,{"Fn::Split" : [ "/", {"Ref": "pInfraVPCPool"}]}]},
                                                              "28"
                                                          ]]},
                                                          "AwsAccountId": {"Ref": "AWS::AccountId"},
                                                          "AwsRegion": {"Ref": "AWS::Region"},
                                                          "InfraNicTag": "type:INFRA",
                                                          "OobNicTag": "type:OOB",
                                                          "OobPublicIp": {"Ref": "rCAPICElasticIP"},
                                                          "ExternalNetworks": {"Ref": "pExtNw"},
                                                          "InfraVpcPool": {"Fn::GetAtt":["rInfraVPC", "CidrBlock"]},
                                                          "UserSubnet": {"Ref": "pInfraVPCPool"},
                                                          "OobSubnet": { "Fn::Join" : [".", [
                                                              {"Fn::Select" :[0,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                                                              {"Fn::Select" :[1,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                                                              {"Fn::Select" :[2,{"Fn::Split" : [ ".", {"Ref": "pInfraVPCPool"}] }]},
                                                              "16/28"
                                                          ]]}
                                                      }
                                                    ]
                    }
                }
            }
        },
        "rCAPICElasticIP": {
            "Type" : "AWS::EC2::EIP",
            "Properties" : {
                "Domain" : {"Ref": "rInfraVPC"}
            },
            "DependsOn" : ["rInfraVPCInternetGateway","rCAPICOOBInterface"]
        },
        "rCAPICElasticIPAssociation":{
            "Type" : "AWS::EC2::EIPAssociation",
            "Properties" : {
                "AllocationId" : { "Fn::GetAtt" : [ "rCAPICElasticIP", "AllocationId" ]},
                "NetworkInterfaceId": {"Ref": "rCAPICOOBInterface"}
            }
        }
    },
    "Outputs": {
        "CAPICElasticIP": {
            "Description": "Public IP address of CAPIC-1",
            "Value" : {"Ref": "rCAPICElasticIP"}
        }
    }
}

    STACK
}
