module "vpc-prod" {
  source      = "../../Modules/aws_network"
  env         = "prod"
}