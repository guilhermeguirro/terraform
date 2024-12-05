variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpn_cidr" {
  description = "VPN CIDR block"
  type        = string
  default     = "172.16.0.0/16"
}

variable "vpc_1_cidr" {
  description = "VPC 1 CIDR block"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_2_cidr" {
  description = "VPC 2 CIDR block"
  type        = string
  default     = "10.2.0.0/16"
}

variable "stacksync_ips" {
  description = "List of Stacksync IP addresses"
  type        = list(string)
  default     = ["192.168.1.0/32", "192.168.2.0/32"]
}
