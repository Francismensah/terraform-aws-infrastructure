locals {
  cidr              = "10.0.0.0/16"
  azs               = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets    = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets  = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
  ubuntu_ami        = "ami-07a0715df72e58928"
  ec2_instance_type = "t3.micro"
  db_username       = "francis"
}
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "3.19.0"
  cidr                   = local.cidr
  azs                    = local.azs
  private_subnets        = local.private_subnets
  public_subnets         = local.public_subnets
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  name                   = "MY-VPC"
  tags = {
    name = "MY-VPC"
  }
  database_subnet_group_name = "db"
  database_subnets           = local.database_subnets
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
module "auth_service_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = "auth-service"
  description = "Security group for auth service"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "auth service port"
      cidr_blocks = local.cidr
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all outbound connections"
      cidr_blocks = local.cidr
    }
  ]
  tags = {
    name = "auth_service_sg"
  }
}
module "ui_service_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = "ui-service"
  description = "Security group for ui service"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      description = "ui service port"
      cidr_blocks = local.cidr
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all outbound connections"
      cidr_blocks = local.cidr
    }
  ]
  tags = {
    name = "ui_service_sg"
  }
}
module "weather_service_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = "weather-service"
  description = "Security group for weather service"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      description = "weather service port"
      cidr_blocks = local.cidr
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all outbound connections"
      cidr_blocks = local.cidr
    }
  ]
  tags = {
    name = "weather_service_sg"
  }
}
module "ssh_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = "ssh-service"
  description = "Security group for SSH access"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh service port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all outbound connections"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = {
    name = "ssh_sg"
  }
}
module "db_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = "db"
  description = "Security group for the RDS instance"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within the VPC"
      cidr_blocks = local.cidr
    }
  ]
}
resource "aws_key_pair" "devops" {
  key_name   = "devops-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDT2qhwl/aT5yCI7s92Eooh19BrBEFahVsYVFweluHg6NTP9twsGnE6w6J+9NZVzgR0BvRUX7MTu0VJssRNG+3d/CMa0umjnZeVetdeoH6zntRXvz7WsRNY9WwLT2ApLuL20ttOGO+aMBpCxPWKvlBGMIaPPW840ndwyiaZZOX1ljQoV9MAyQApZcYa7OCArqtD94z8VAaquU0CWUNy7a4BpKH21opRLOyE9b3nIb7jl1uwBFq4ICp5++Wa17dJiRJJ3suyAgSuVnBeUpvs7XHqcHHSCeQBgt64G8S+oEv/ugWoMC/7edvid10U9Fbpo0A4mgGHMLiT8KbRblPLfJhbgiYIHJrtIQ7e3a1T4JUmv6xCzcAVmyEvHeCG2sy+kl2GMQ83z5kAlGnMFVz4iHp+FD9v9vT4bZuvCouxR9tutUrqMyyT8rSA45U+1Bwe4u3uebCYhqnzTEhF44+BoSQikwBoNiwGHUBwh+aCKAGgBgiMGAzgS+iUffFk3VfldCM= root@rancard231-ThinkPad-X270"
}
module "auth-ec2-instance" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  version       = "4.3.0"
  name          = "auth-instance"
  ami           = local.ubuntu_ami
  instance_type = local.ec2_instance_type
  key_name      = "devops-key"
  monitoring    = true
  vpc_security_group_ids = [
    module.auth_service_sg.security_group_id,
    module.ssh_sg.security_group_id
  ]
  subnet_id = element(module.vpc.private_subnets, 0)
}
module "ui-ec2-instance" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  version       = "4.3.0"
  name          = "ui-instance"
  ami           = local.ubuntu_ami
  instance_type = local.ec2_instance_type
  key_name      = "devops-key"
  monitoring    = true
  vpc_security_group_ids = [
    module.ui_service_sg.security_group_id,
    module.ssh_sg.security_group_id
  ]
  subnet_id = element(module.vpc.private_subnets, 1)
}
module "weather-ec2-instance" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  version       = "4.3.0"
  name          = "weather-instance"
  ami           = local.ubuntu_ami
  instance_type = local.ec2_instance_type
  key_name      = "devops-key"
  monitoring    = true
  vpc_security_group_ids = [
    module.weather_service_sg.security_group_id,
    module.ssh_sg.security_group_id
  ]
  subnet_id = element(module.vpc.private_subnets, 2)
}
module "bastion-ec2-instance" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  version       = "4.3.0"
  name          = "bastion-instance"
  ami           = local.ubuntu_ami
  instance_type = local.ec2_instance_type
  key_name      = "devops-key"
  monitoring    = true
  vpc_security_group_ids = [
    module.ssh_sg.security_group_id
  ]
  subnet_id = element(module.vpc.public_subnets, 0)
}
module "db" {
  source                          = "terraform-aws-modules/rds/aws"
  version                         = "5.3.0"
  identifier                      = "moderndevopsdb"
  engine                          = "mysql"
  engine_version                  = "8.0"
  family                          = "mysql8.0"
  major_engine_version            = "8.0"
  instance_class                  = "db.t4g.small"
  allocated_storage               = 5
  max_allocated_storage           = 5
  db_name                         = "moderndevopsdb"
  username                        = local.db_username
  port                            = 3306
  multi_az                        = false
  db_subnet_group_name            = module.vpc.database_subnet_group
  vpc_security_group_ids          = [module.db_sg.security_group_id]
  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]
  create_cloudwatch_log_group     = true
  skip_final_snapshot             = true
  deletion_protection             = false
}
resource "aws_ssm_parameter" "db_endpoint" {
  name      = "moderndevops.db.endpoint"
  type      = "String"
  value     = module.db.db_instance_endpoint
  overwrite = true
}
resource "aws_ssm_parameter" "db_username" {
  name  = "moderndevops.db.username"
  type  = "String"
  value = local.db_username
}
resource "aws_secretsmanager_secret" "db_password" {
  name = "moderndevops.db.password"
}
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = module.db.db_instance_password
}
module "alb" {
  source          = "terraform-aws-modules/alb/aws"
  version         = "8.3.1"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.vpc.default_security_group_id]
  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 3000
      protocol    = "tcp"
      description = " HTTP web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  target_groups = [
    {
      name                 = "h1"
      backend_protocol     = "HTTP"
      backend_port         = 3000
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      targets = {
        ui = {
          target_id = module.ui-ec2-instance.id
          port      = 3000
        }
      }
    }
  ]
}
