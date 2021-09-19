short_name = "preprod-servian"

default_tags = {
  "Client" = "servian",
  "Project" = "servian-demo",
  "Environment" = "preprod"
}

# FRONTS - Not configured since no cert available, and ALB ingress controller not supporting ACME/Letsencrypt
domain_name     = "preprod-dev.servian.cloud"
subdomain_names = ["serviantc-dev"]
certificate_arn = "arn:aws:acm:ap-southeast-2:185922747583:certificate/ab57e501-9c4f-4002-bf57-17fd83077c75"

# EKS
eks_version = "1.18"
# Allows you to give administration permissions to the EKS
# cluster using your normal access credentials.
# You can view the cluster from the AWS console.
eks_arn_user_list_with_masters_user = [
  "arn:aws:iam::185922747583:user/yasas-Ay"
]
# It allows you to give administration permissions to the EKS
# cluster using your normal access credentials and using a
# particular role. It only works through the kubectl command.
eks_arn_user_list_with_masters_role = [
 "arn:aws:iam::185922747583:user/yasas-Ay"
]
# It allows you to give read-only permissions to the EKS
# cluster using your normal access credentials and using a
# particular role. It only works through the kubectl command.
eks_arn_user_list_with_readonly_role = [
 "arn:aws:iam::185922747583:user/yasas-Ay"
]

# NETWORKS
vpc_cidr                = "10.34.16.0/20"
vpc_az_size             = "3"
vpc_subnet_public_cidr  = ["10.34.16.0/24", "10.34.19.0/24", "10.34.22.0/24"]
vpc_subnet_private_cidr = ["10.34.17.0/24", "10.34.20.0/24", "10.34.23.0/24"]
vpc_subnet_storage_cidr = ["10.34.18.0/24", "10.34.21.0/24", "10.34.24.0/24"]

nat_gateway_size = "1"

# STORAGE
storage_instance_class = "db.t2.micro"

# TRANSIT GATEWAY
#transit_gateway_id = "tgw-044a0b177f6fae82c"

# BASTION ALLOWED
bastion_allowed_port = "22"
bastion_allowed_cidrs = ["175.157.44.79/32"]

# ACM Certificate related
cert_dns_name = "*.ap-southeast-2.elb.amazonaws.com"
cert_org_name = "servian"