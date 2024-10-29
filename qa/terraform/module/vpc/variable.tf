variable "vpc_name" {
    type = string
    default = "first_tf_vpc"
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = "Indicates whether the instances launched in the VPC get DNS hostnames. If enabled, instances in the VPC get DNS hostnames; otherwise, they do not. Disabled by default for nondefault VPCs."
  default     = true
}

variable "vpc_enable_dns_support" {
  type        = bool
  description = "Indicates whether the DNS resolution is supported for the VPC. If enabled, queries to the Amazon provided DNS server at the 169.254.169.253 IP address, or the reserved IP address at the base of the VPC network range \"plus two\" succeed. If disabled, the Amazon provided DNS service in the VPC that resolves public DNS hostnames to IP addresses is not enabled. Enabled by default."
  default     = true
}

variable "vpc_instance_tenancy" {
  type        = string
  description = "The allowed tenancy of instances launched into the VPC."
  default     = "default"
}

variable "vpc_ipv4_ipam_pool_id" {
  description = "Set to use IPAM to get an IPv4 CIDR block."
  type        = string
  default     = null
}

variable "vpc_ipv4_netmask_length" {
  description = "Set to use IPAM to get an IPv4 CIDR block using a specified netmask. Must be set with var.vpc_ipv4_ipam_pool_id."
  type        = string
  default     = 22
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "transit_gateway_id" {
  type        = string
  description = "Transit gateway id to attach the VPC to. Required when `transit_gateway` subnet is defined."
  default     = null
}

variable "transit_gateway_routes" {
  description = <<-EOF
  Configuration of route(s) to transit gateway.
  For each `public` and/or `private` subnets named in the `subnets` variable,
  Optionally create routes from the subnet to transit gateway. Specify the CIDR range or a prefix-list-id that you want routed to the transit gateway.
  Example:
  ```
  transit_gateway_routes = {
    public  = "10.0.0.0/8"
    private = "pl-123"
  }
  ```
EOF
  type        = any
  default     = {}
}

variable "core_network" {
  type = object({
    id  = string
    arn = string
  })
  description = "AWS Cloud WAN's core network information - to create a VPC attachment. Required when `cloud_wan` subnet is defined. Two attributes are required: the `id` and `arn` of the resource."

  default = {
    id  = null
    arn = null
  }
}

variable "core_network_routes" {
  description = <<-EOF
  Configuration of route(s) to AWS Cloud WAN's core network.
  For each `public` and/or `private` subnets named in the `subnets` variable, optionally create routes from the subnet to the core network.
  You can specify either a CIDR range or a prefix-list-id that you want routed to the core network.
  Example:
  ```
  core_network_routes = {
    public  = "10.0.0.0/8"
    private = "pl-123"
  }
  ```
EOF
  type        = any
  default     = {}
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "availability_zones" {
  description = "The availability zones in which the default subnets need to be created."
  type        = list(string)
}