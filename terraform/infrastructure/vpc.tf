
locals {
  aws_cidr            = "10.0.0.0/16"
  aws_azs             = ["us-east-2a"]
  aws_public_subnets  = ["10.0.1.0/24"]
  aws_private_subnets = ["10.0.2.0/24"]
}

// spin up a new VPC for our environment
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 3.0"

  name                   = var.environment
  cidr                   = local.aws_cidr
  azs                    = local.aws_azs
  public_subnets         = local.aws_public_subnets
  private_subnets        = local.aws_private_subnets
  create_igw             = true  // create our IGW
  enable_nat_gateway     = true  // create our NAT-GW
  single_nat_gateway     = true  // shared NAT gateway private subnet(s)
  one_nat_gateway_per_az = false // shared NAT gateway for all AZs
  enable_dns_support     = true  // enable dns support within our subnets
  enable_dns_hostnames   = true  // enable dns hostnames within our subnets

  // some tags to associate with our resources
  tags = {
    terraform   = "true"
    environment = var.environment
  }
}
