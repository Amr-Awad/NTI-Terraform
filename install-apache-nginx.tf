
module "install-nginx" {
    source = "./modules/install-nginx-module"
    public-instance-ips = local.public_instance_ips
    ec2-private-key = module.ssh-key-create.private_key
    private-lb-dns = module.private-alb.alb-dns
    public-ec2-instance-ids = local.public_instance_ids
    private-ec2-instance-ids = local.private_instance_ids
    lb-ids = [module.public-alb.alb-id, module.private-alb.alb-id]
  
}

module "install-apache" {
    source = "./modules/install-apache-module"
    public-instance-ips = local.public_instance_ips
    private-instance-ips = local.private_instance_ips
    ec2-private-key = module.ssh-key-create.private_key
    private-lb-dns = module.private-alb.alb-dns
    public-ec2-instance-ids = local.public_instance_ids
    private-ec2-instance-ids = local.private_instance_ids
}