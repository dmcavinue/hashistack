
// ssh keys used to auth against environments provisioned instances
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Generate a new key pair for each service
module "key_pair" {
  source          = "terraform-aws-modules/key-pair/aws"
  version         = "1.0.0"
  key_name        = var.environment
  public_key      = tls_private_key.ssh_key.public_key_openssh
  create_key_pair = true
  tags = {
    terraform   = "true"
    environment = var.environment
  }
}

// lookup latest ubuntu image
data "aws_ami" "image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}
