variable "prefix" {
  type        = string
  description = "A string to be prefixed to the name of all new resources."
  default     = "lacework-agentless-scanning"
}

variable "suffix" {
  type        = string
  description = "A string to be appended to the end of the name of all new resources."
}

variable "agentless_scan_ecs_task_role_arn" {
  type        = string
  description = "ECS task role ARN."
}

variable "external_id" {
  type        = string
  description = "The external ID configured inside the IAM role used for cross account access."
}
