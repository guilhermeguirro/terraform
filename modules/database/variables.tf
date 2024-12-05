variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Aurora cluster"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for Aurora cluster"
  type        = string
}

variable "instance_class" {
  description = "Instance class for Aurora instances"
  type        = string
  default     = "db.t4g.medium"
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
}
