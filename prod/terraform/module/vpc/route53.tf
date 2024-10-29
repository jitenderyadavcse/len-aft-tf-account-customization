locals {
	rules = {
	"lennar.lennarcorp.com" = {
    name = "Forwarder for lennar-lennarcorp-com"
    target_ips = ["10.81.0.13", "10.85.0.13"]
   }
	"lennarcorp.com" = {
    name = "Forwarder for lennarcorp-com"
    target_ips = ["10.81.0.13", "10.85.0.13"]
    }
  "database.windows.net" = {
    name = "Forwarder for database-windows-net"
    target_ips = ["10.81.0.13", "10.85.0.13"]
    }
  }
}

resource "aws_security_group" "allow_dns" {
  provider    = aws.vended_account
  name        = "allow_dns"
  description = "Allow DNS"
  vpc_id      = aws_vpc.main.id

  tags = merge({
    Name = "allow_dns"
    }, var.common_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "allow_dns_inbound_tcp" {
  provider          = aws.vended_account
  security_group_id = aws_security_group.allow_dns.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 53
  ip_protocol       = "tcp"
  to_port           = 53
}

resource "aws_vpc_security_group_ingress_rule" "allow_dns_inbound_udp" {
  provider          = aws.vended_account
  security_group_id = aws_security_group.allow_dns.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 53
  ip_protocol       = "udp"
  to_port           = 53
}

resource "aws_vpc_security_group_egress_rule" "allow_dns_outbound_tcp" {
  provider          = aws.vended_account
  security_group_id = aws_security_group.allow_dns.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 53
  ip_protocol       = "tcp"
  to_port           = 53
}

resource "aws_vpc_security_group_egress_rule" "allow_dns_outbound_udp" {
  provider          = aws.vended_account
  security_group_id = aws_security_group.allow_dns.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 53
  ip_protocol       = "udp"
  to_port           = 53
}

resource "aws_route53_resolver_endpoint" "rslvr_endpoint" {
  provider = aws.vended_account
  name = "rslvr-dns-outbound-endpoint"

  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.allow_dns.id
  ]

  ip_address {
    subnet_id = aws_subnet.workload_connectivity[0].id
  }
  ip_address {
    subnet_id = aws_subnet.workload_connectivity[1].id
  }

  protocols = ["Do53"]

  tags = var.common_tags
}

resource "aws_route53_resolver_rule" "rslvr_rule" {
  for_each             = local.rules
  provider             = aws.vended_account
  domain_name          = each.key
  name                 = each.value.name
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.rslvr_endpoint.id

  dynamic "target_ip" {
    for_each = { for ip in each.value.target_ips : ip => ip }
    content {
      ip = target_ip.value
    }
  }

  tags = var.common_tags
}

resource "aws_route53_resolver_rule_association" "rslvr_association" {
  for_each         = aws_route53_resolver_rule.rslvr_rule
  provider         = aws.vended_account
  resolver_rule_id = each.value.id
  vpc_id           = aws_vpc.main.id
}