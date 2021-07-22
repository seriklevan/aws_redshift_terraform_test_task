variable "region" {
  description = "Please Enter AWS Region to deploy Server"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Please Enter Projectname"
  type        = string
  default     = "Test"
}

variable "environment" {
  description = "Please Enter Environment"
  type        = string
  default     = "DEV"
}

variable "tags" {
  default = {
    Project = "Test-project"
  }
}
