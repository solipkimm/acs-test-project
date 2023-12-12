variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  description = "The list of availability zones where the resources will be deployed"
}

variable "prefix" {
  default     = "Group6"
  type        =  string
  description = "Name prefix"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Deployment Environment"
}

variable "private_subnet_cidrs" {
  default     = ["10.1.5.0/24", "10.1.6.0/24"]
  type        = list(string)
  description = "Private Subnet CIDRs"
}

variable "public_cidr_blocks" {
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

variable "default_tags" {
  default = {
    "Owner"     = "Group6",
    "Project"   = "Final Project"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}