data "aws_vpc_ipam_pool" "dev-ipam-pool" {
  provider = aws.network_management

  filter {
    name   = "description"
    values = ["*DevTest*"]
  }
  filter {
    name   = "address-family"
    values = ["ipv4"]
  }
}

data "aws_ssm_parameter" "app_code" {
  provider = aws.vended_account
  name     = "/aft/account-request/custom-fields/app_code"
}

locals {
  app_id = data.aws_ssm_parameter.app_code
}

resource "aws_vpc" "main" {
  provider = aws.vended_account

  ipv4_ipam_pool_id   = data.aws_vpc_ipam_pool.dev-ipam-pool.id
  ipv4_netmask_length = var.vpc_ipv4_netmask_length

  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  enable_dns_support   = var.vpc_enable_dns_support
  instance_tenancy     = var.vpc_instance_tenancy

  tags = merge(
    { Name = "len-primary-vpc-pd" },
    var.common_tags
  )
}

resource "aws_subnet" "workload_connectivity" {
  provider                                    = aws.vended_account
  for_each                                    = { for idx, az in var.availability_zones : idx => az }
  availability_zone                           = each.value
  cidr_block                                  = cidrsubnet(aws_vpc.main.cidr_block, 6, each.key)
  enable_resource_name_dns_a_record_on_launch = true
  vpc_id                                      = aws_vpc.main.id

  tags = merge(
    { Name = "len-${local.app_id.value}-connectivity-subnet-${each.value}-pd" },
    var.common_tags
  )

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "workload_services" {
  provider                                    = aws.vended_account
  for_each                                    = { for idx, az in var.availability_zones : idx => az }
  availability_zone                           = each.value
  cidr_block                                  = cidrsubnet(aws_vpc.main.cidr_block, 6, each.key + 2)
  enable_resource_name_dns_a_record_on_launch = true
  vpc_id                                      = aws_vpc.main.id

  tags = merge(
    { Name = "len-${local.app_id.value}-services-subnet-${each.value}-pd" },
    var.common_tags
  )

  depends_on = [aws_vpc.main]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "len-aws-tgwa-pd" {
  provider           = aws.vended_account
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.main.id
  subnet_ids         = values(aws_subnet.workload_connectivity)[*].id

  tags = merge(
    { Name = "len-${local.app_id.value}-primary-vpc-tgw-attachment-pd" },
    var.common_tags
  )
}



#############################################
#
# Update below for future accounts after solving the perms issue 2/29
#
# Error: creating Route in Route Table (rtb-0dde59ef7736c04e7) with destination (0.0.0.0/0): 
# UnauthorizedOperation: You are not authorized to perform this operation. 
# User: arn:aws:sts::339713102869:assumed-role/AWSAFTAdmin/AWSAFT-Session is not authorized to perform: ec2:CreateRoute on resource: arn:aws:ec2:us-east-1:339713102869:route-table/* because no identity-based policy allows the ec2:CreateRoute action. 
# Encoded authorization failure message: ...   status code: 403, request id: 171c5766-7164-40c6-b2b5-ec8691a3759b
#
# resource "aws_route" "static_route" {
#   route_table_id         = aws_vpc.main.main_route_table_id
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_id	 = var.transit_gateway_id

#   depends_on = [ aws_vpc.main ]
# }
#
#############################################




# resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "tgw-accepter" {
#   provider = aws.network_management
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.len-aws-tgwa-pd.id

#   tags = var.common_tags
# }

