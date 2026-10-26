<<<<<<< HEAD
provider "aws" {
  region = var.region
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  project  = var.project
  env      = var.env
}

module "subnet" {
  source       = "./modules/subnet"
  vpc_id       = module.vpc.vpc_id
  igw_id       = module.vpc.igw_id
  pri_sub_cidr = var.pri_sub_cidr
  pub_sub_cidr = var.pub_sub_cidr
  project      = var.project
}

module "sg" {
  source  = "./modules/sg"
  vpc_id  = module.vpc.vpc_id
  project = var.project
}

module "ec2" {
  source        = "./modules/ec2"
  ami           = var.image_id
  instance_type = var.instance_type
  subnet_id     = module.subnet.private_subnet_id
  sg_id         = module.sg.sg_id
  key_name      = var.key_pair
  project       = var.project
=======

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "multi_instance_sg" {
  name        = "terraform-multiple-instance-sg"
  description = "Security group for multiple EC2 instances"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-multiple-instance-sg"
  }
}

resource "aws_instance" "web" {
  count                  = 3
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.multi_instance_sg.id]

  tags = {
    Name = "terraform-server-${count.index + 1}"
  }
}

output "instance_ids" {
  value = aws_instance.web[*].id
}

output "public_ips" {
  value = aws_instance.web[*].public_ip
>>>>>>> 640295499f3bc3ac94799f4724a3b44471db349b
}
