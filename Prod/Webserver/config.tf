terraform  {
  backend "s3" {
    bucket = "acs730-group6-s3bucket1"         
    key    = "prod/webserver/terraform.tfstate" 
    region = "us-east-1"
  }
}