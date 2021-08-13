
// tailscale-relay
module "tailscale-relay" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "tailscale-relay"
  instance_type          = "t2.nano"
  ami                    = data.aws_ami.image.id
  subnet_id              = module.vpc.private_subnets.0
  key_name               = module.key_pair.key_pair_key_name
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  user_data_base64       = base64encode(data.template_file.user_data.rendered)
  monitoring             = false
  tags                   = {
    Environment = var.environment
    Terraform   = "true"
  }
}

// tailscale startup script template
// we inject the tailscale apikey and
// list of private subnets here
data "template_file" "user_data" {
  template = file("./startup_scripts/tailscale-relay.sh.tmpl")
  vars     = {
    // pass the tailscale authkey to auto-register
    // with tailscale
    "TAILSCALE_AUTHKEY" = var.tailscale_authkey
    // pass a list of all private subnets to
    // the instance to setup subnet routing
    "PRIVATE_SUBNETS"   = join(",", local.aws_private_subnets)
  }
}
