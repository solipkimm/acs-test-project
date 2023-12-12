variable "instance_type" {
  default = {
    "prod"    = "t2.micro"
    "dev"     = "t2.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  description = "The list of availability zones"
}

variable "default_tags" {
  default = {
    "Owner" = "Group6"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

variable "ansible_tags" {
  default = {
    "Owner" = "Group6Ansible"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Ansible tags to be appliad to all AWS resources"
}

variable "prefix" {
  default     = "Group6"
  type        = string
  description = "Name prefix"
}

variable "env" {
  default     = "prod"
  type        = string
  description = "Deployment Environment"
}
