terraform {
  required_version = "~> 1.3"
  required_providers {
    local    = "~> 2.4"
    null     = "~> 3.2"
    aws      = "~> 5.33"
    external = "~> 2.3"
  }
}

locals {
  default_vpc_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = var.name
  cidr = var.cidr

  azs = local.aws_availability_zone_names

  map_public_ip_on_launch = true
  private_subnets         = var.private_subnetwork_cidrs
  public_subnets          = var.public_subnetwork_cidrs

  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  enable_dns_hostnames   = true

  tags = merge(local.default_vpc_tags, var.tags)

  public_subnet_tags = merge(
    {
      for cluster_name in var.names_of_kubernetes_cluster_integrated_with_subnets :
      "kubernetes.io/cluster/${cluster_name}" => "shared"
    },
    {
      "kubernetes.io/role/elb" = "1"
    }
  )

  private_subnet_tags = merge(
    {
      for cluster_name in var.names_of_kubernetes_cluster_integrated_with_subnets :
      "kubernetes.io/cluster/${cluster_name}" => "shared"
    },
    {
      "kubernetes.io/role/internal-elb" = "1"
    }
  )

}

resource "aws_vpc_ipv4_cidr_block_association" "extra" {
  for_each   = toset(var.extra_ipv4_cidr_blocks)
  vpc_id     = module.vpc.vpc_id
  cidr_block = each.value
}
