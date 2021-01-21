# Annotation

VPC module for creating networks, load balancers and gateways

# Feature
- `Set availability_zones` - Your need set availability_zones for region where deploy EKS cluster.
- `Choice network CIDR` - change variable network to change CIDR (default 10.10.0.0/16)

## Usage
```
module "network" {
  source = "https://github.com/provectus/sak-vpc.git"

  availability_zones = var.availability_zones
  environment        = local.environment
  project            = local.project
  cluster_name       = local.cluster_name
  network            = 10
}
```