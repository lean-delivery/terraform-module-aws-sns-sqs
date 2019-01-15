variable "project" {
  description = "Project name will be used for naming resources in pattern %PROJECT_NAME%-%ENVIRONMENT_NAME%"
  default     = "project"
}

variable "environment" {
  description = "Environment name will be used for naming resources in pattern %PROJECT_NAME%-%ENVIRONMENT_NAME%"
  default     = "test"
}

variable "service_name" {
  description = "Service name will be used for naming resources in pattern %PROJECT_NAME%-%ENVIRONMENT_NAME%-%SERVICE_NAME%"
  default     = "None"
}

variable "notification_source_arns" {
  description = ""
  type        = "list"
  default     = ["*"]
}

variable "sqs_dead_letter_redrive_max_receive_count" {
  description = ""
  default     = 5
}

variable "module_enabled" {
  description = "Trigger to enable/disable module"
  default     = "true"
}
