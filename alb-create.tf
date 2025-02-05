module "public-alb" {
  source               = "./modules/alb-module"
  alb-type             = "application"
  alb-name             = "public-alb"
  subnet-ids           = module.vpc-create.public_subnet_ids
  vpc-id               = module.vpc-create.vpc-id
  is-internal          = false
  alb-sg-id            = module.alb-security-group.sg-id
  instance-ids         = local.public_instance_ids
  target-group-name    = "public-target-group"
  lb-listener-port     = "80"
  lb-listener-protocol = "HTTP"
}

module "private-alb" {
  source               = "./modules/alb-module"
  alb-type             = "application"
  alb-name             = "private-alb"
  subnet-ids           = module.vpc-create.private_subnet_ids
  vpc-id               = module.vpc-create.vpc-id
  is-internal          = true
  alb-sg-id            = module.alb-security-group.sg-id
  instance-ids         = local.private_instance_ids
  target-group-name    = "private-target-group"
  lb-listener-port     = "80"
  lb-listener-protocol = "HTTP"
}
