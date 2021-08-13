locals {
  consul_instance_count = 3
  inventory = jsonencode({
    "all": [for i,host in module.hashistack.private_dns : "${host} ansible_host=${module.hashistack.private_ip[i]}"],
    "vault_instances": [module.hashistack.private_dns[0]],
    "traefik_instances": [module.hashistack.private_dns[0]],
    "nomad_deployer": [module.hashistack.private_dns[0]],
    "nomad_instances": [module.hashistack.private_dns[0]],
    "consul_instances": [for i,host in module.hashistack.private_dns : "${host}"],
    "docker_instances": [for i,host in module.hashistack.private_dns : "${host}"]
  })
}

// consul
module "hashistack" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "hashistack"
  instance_type          = "t2.micro"
  instance_count         = local.consul_instance_count
  ami                    = data.aws_ami.debian.id
  subnet_id              = module.vpc.private_subnets.0
  key_name               = module.key_pair.key_pair_key_name
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  monitoring             = false
  tags                   = {
    Environment = var.environment
    Terraform   = "true"
  }
  depends_on = [
    module.tailscale-relay
  ]
}

data "template_file" "ansible_inventory" {
  template = file("./templates/inventory.yml.tmpl")
  vars     = {
    hosts = join(",", module.hashistack.private_dns)
    ips   = join(",", module.hashistack.private_ip)
  }
}
