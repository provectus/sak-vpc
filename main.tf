locals {
  zones   = coalescelist(var.availability_zones, data.aws_availability_zones.available.names)
  cidr    = var.cidr != null ? var.cidr : "10.${var.network}.0.0/16"
  private = var.cidr != null ? [for i, z in local.zones : cidrsubnet(local.cidr, var.network_delimiter, i)] : [ for i, _ in local.zones : "10.${var.network}.20${i}.0/24" ]
  public  = var.cidr != null ? [for i, z in local.zones : cidrsubnet(local.cidr, var.network_delimiter, pow(2, var.network_delimiter) - i)] : [ for i, _ in local.zones:"10.${var.network}.${i}.0/24" ]
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v2.64.0"

  name = "${var.environment}-${var.cluster_name}"

  cidr = local.cidr

  azs             = local.zones
  private_subnets = local.private
  public_subnets  = local.public

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name                                        = "${var.environment}-${var.cluster_name}-public"
    KubernetesCluster                           = var.cluster_name
    Environment                                 = var.environment
    Project                                     = var.project
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    Name                                        = "${var.environment}-${var.cluster_name}-private"
    "kubernetes.io/role/elb-internal"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  tags = {
    Name        = "${var.environment}-${var.cluster_name}"
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }
}
