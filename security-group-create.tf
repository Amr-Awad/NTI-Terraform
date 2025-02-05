module "alb-security-group" {
  source = "./modules/security-groups-module"
  sg-name = "alb-sg"
  sg-description = "Security group for ALB"
  vpc-id = module.vpc-create.vpc-id
  ssh-make = false
  http-make = true
  https-make = true
}

module "public-security-group" {
  source = "./modules/security-groups-module"
  sg-name = "public-sg"
  sg-description = "Security group for public subnet"
  vpc-id = module.vpc-create.vpc-id
  ssh-make = true
  http-make = true
  https-make = true
}

module "private-security-group" {
  source = "./modules/security-groups-module"
  sg-name = "private-sg"
  sg-description = "Security group for private subnet"
  vpc-id = module.vpc-create.vpc-id
  ssh-make = true
  http-make = true
  https-make = false
}