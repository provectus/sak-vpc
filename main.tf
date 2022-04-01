locals {
  zones              = coalescelist(var.availability_zones, data.aws_availability_zones.available.names)
  cidr               = var.cidr != null ? var.cidr : "10.${var.network}.0.0/16"
  private            = var.cidr != null ? [for i, z in local.zones : cidrsubnet(local.cidr, var.network_delimiter, i)] : data.template_file.private.*.rendered
  public             = var.cidr != null ? [for i, z in local.zones : cidrsubnet(local.cidr, var.network_delimiter, pow(2, var.network_delimiter) - i)] : data.template_file.public.*.rendered

  public_subnet_tags = {
    Name                                        = "${var.environment}-${var.cluster_name}-public"
    KubernetesCluster                           = var.cluster_name
    Environment                                 = var.environment
    Project                                     = var.project
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                    = ""
  }

  private_subnet_tags = {
    Name                                        = "${var.environment}-${var.cluster_name}-private"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

data "aws_availability_zones" "available" {}

data "template_file" "public" {
  count    = length(local.zones)
  template = "10.${var.network}.${count.index}.0/24"
}

data "template_file" "private" {
  count    = length(local.zones)
  template = "10.${var.network}.20${count.index}.0/24"
}

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

  public_subnet_tags  = (
    length(var.additional_public_subnet_tags) > 0
      ? merge(local.public_subnet_tags, var.additional_public_subnet_tags)
      : local.public_subnet_tags
  )

  private_subnet_tags = (
    length(var.additional_private_subnet_tags) > 0
      ? merge(local.private_subnet_tags, var.additional_private_subnet_tags)
      : local.private_subnet_tags
  )

  tags = {
    Name        = "${var.environment}-${var.cluster_name}"
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }
}
