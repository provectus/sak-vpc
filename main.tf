locals {
  zones   = coalescelist(var.availability_zones, data.aws_availability_zones.available.names)
  cidr    = var.cidr != null ? var.cidr : "10.${var.network}.0.0/16"
  private = var.cidr != null ? [for i, z in local.zones : cidrsubnet(local.cidr, var.network_delimiter, i)] : data.template_file.private.*.rendered
  public  = var.cidr != null ? [for i, z in local.zones : cidrsubnet(local.cidr, var.network_delimiter, pow(2, var.network_delimiter) - i)] : data.template_file.public.*.rendered
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



  enable_flow_log                                 = var.enable_flow_log
  create_flow_log_cloudwatch_log_group            = var.enable_flow_log && var.flow_log_destination_arn == ""
  create_flow_log_cloudwatch_iam_role             = var.enable_flow_log && var.flow_log_cloudwatch_iam_role_arn == ""
  flow_log_cloudwatch_log_group_retention_in_days = var.flow_log_cloudwatch_log_group_retention_in_days
  flow_log_traffic_type                           = var.flow_log_traffic_type
  flow_log_destination_arn                        = (var.enable_flow_log && var.flow_log_destination_arn != "") ? var.flow_log_destination_arn : ""
  flow_log_cloudwatch_iam_role_arn                = (var.enable_flow_log && var.flow_log_cloudwatch_iam_role_arn != "") ? var.flow_log_cloudwatch_iam_role_arn : ""
  flow_log_cloudwatch_log_group_name_prefix       = var.flow_log_cloudwatch_log_group_name_prefix
  vpc_flow_log_tags = {
    Name        = "${var.environment}-${var.cluster_name}"
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name                                        = "${var.environment}-${var.cluster_name}-public"
    KubernetesCluster                           = var.cluster_name
    Environment                                 = var.environment
    Project                                     = var.project
    "kubernetes.io/role/elb"                    = ""
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    Name                                        = "${var.environment}-${var.cluster_name}-private"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = {
    Name        = "${var.environment}-${var.cluster_name}"
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }
}
