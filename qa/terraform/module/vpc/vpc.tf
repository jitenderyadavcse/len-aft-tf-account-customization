data "aws_vpc_ipam_pool" "qa-ipam-pool" {
  provider = aws.network_management

  filter {
    name   = "description"
    values = ["*QA*"]
  }
  filter {
    name   = "address-family"
    values = ["ipv4"]
  }
}

data "aws_ssm_parameter" "app_code" {
  provider = aws.vended_account
  name = "/aft/account-request/custom-fields/app_code"
}

locals {
  app_id = data.aws_ssm_parameter.app_code
}

resource "aws_vpc" "main" {
  provider = aws.vended_account

  ipv4_ipam_pool_id                = data.aws_vpc_ipam_pool.qa-ipam-pool.id
  ipv4_netmask_length              = var.vpc_ipv4_netmask_length
  
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  enable_dns_support   = var.vpc_enable_dns_support
  instance_tenancy     = var.vpc_instance_tenancy

  tags = merge(
    { Name = "len-primary-vpc-pd" },
    var.common_tags
  )
}

resource "aws_subnet" "workload_connectivity" {
  provider = aws.vended_account
  for_each = { for idx,az in var.availability_zones: idx => az }
  availability_zone = each.value
  cidr_block                                     = cidrsubnet(aws_vpc.main.cidr_block,6,each.key)
  enable_resource_name_dns_a_record_on_launch    = true
  vpc_id                                         = aws_vpc.main.id

  tags = merge(
    { Name = "len-${local.app_id.value}-connectivity-subnet-${each.value}-pd" },
    var.common_tags
  )

  depends_on = [ aws_vpc.main ]
}

resource "aws_subnet" "workload_services" {
  provider = aws.vended_account
  for_each = { for idx,az in var.availability_zones: idx => az }
  availability_zone = each.value
  cidr_block                                     = cidrsubnet(aws_vpc.main.cidr_block,6,each.key + 2)
  enable_resource_name_dns_a_record_on_launch    = true
  vpc_id                                         = aws_vpc.main.id

  tags = merge(
    { Name = "len-${local.app_id.value}-services-subnet-${each.value}-pd" },
    var.common_tags
  )

  depends_on = [ aws_vpc.main ]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "len-aws-tgwa-pd" {
  provider = aws.vended_account
  transit_gateway_id  = var.transit_gateway_id
  vpc_id              = aws_vpc.main.id
  subnet_ids          = values(aws_subnet.workload_connectivity)[*].id

  tags = merge(
    { Name = "len-${local.app_id.value}-primary-vpc-tgw-attachment-pd" },
    var.common_tags
  )
}

# resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "tgw-accepter" {
#   provider = aws.network_management
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.len-aws-tgwa-pd.id

#   tags = var.common_tags
# }

