variable "cidr" {
  type        = string
  description = "TBD"
  default     = null
}

variable "network_delimiter" {
  type        = string
  description = "TBD"
  default     = "8"
}

variable "network" {
  type        = string
  description = "Number would be used to template CIDR 10.X.0.0/16."
  default     = "10"
}

variable "single_nat" {
  type        = bool
  description = "Use single Nat gateway or separeta for all AZ"
  default     = true
}

variable "environment" {
  type        = string
  default     = null
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable "project" {
  type        = string
  default     = null
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "cluster_name" {
  type        = string
  default     = "cluster-name"
  description = "A name of the Amazon EKS cluster"
}

variable "availability_zones" {
  description = "Availability zones for project"
  type        = list(any)
  default     = []
}



variable "enable_flow_log" {
  description = "Enable flow logs"
  type        = bool
  default     = false
}



variable "flow_log_cloudwatch_log_group_retention_in_days" {
  description = "Retention days cloudwatch logs"
  type        = number
  default     = 90
}



variable "flow_log_traffic_type" {
  description = "Traffic type (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ALL"
}



variable "flow_log_destination_arn" {
  description = "cloudwatch destination arn"
  type        = string
  default     = ""
}


variable "flow_log_cloudwatch_iam_role_arn" {
  description = "Iam role to use to push to cloudwatch"
  type        = string
  default     = ""
}


variable "flow_log_cloudwatch_log_group_name_prefix" {
  description = "cloudwatch log group prefix"
  type        = string
  default     = "/aws/vpc-flow-log/"
}
