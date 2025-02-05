locals {
  public_instance_ids  = flatten([for instance in module.ec2_create_public_instances : instance.instance_ids])
  private_instance_ids = flatten([for instance in module.ec2_create_private_instances : instance.instance_ids])
  public_instance_ips = flatten([for instance in module.ec2_create_public_instances : instance.instance_ips])
    private_instance_ips = flatten([for instance in module.ec2_create_private_instances : instance.instance_ips])
}

# Create public instances
module "ec2_create_public_instances" {
  for_each            = { for idx, subnet_id in module.vpc-create.public_subnet_ids : idx => subnet_id }
  source              = "./modules/ec2-module"
  subnet-id           = each.value
  instance-type       = "t2.micro"
  ssh-key             = module.ssh-key-create.ssh-key
  sg-id               = module.public-security-group.sg-id
  is-public           = true
  linux-type          = "ubuntu"
}

# Create private instances
module "ec2_create_private_instances" {
  for_each            = { for idx, subnet_id in module.vpc-create.private_subnet_ids : idx => subnet_id }
  source              = "./modules/ec2-module"
  subnet-id           = each.value
  instance-type       = "t2.micro"
  ssh-key             = module.ssh-key-create.ssh-key
  sg-id               = module.private-security-group.sg-id
  is-public           = false
  linux-type          = "amazon-linux"
  
}