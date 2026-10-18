1. main.tf has a missing closing brace }.
2. The AWS provider is declared in both main.tf and provider.tf.
Let's fix both.
Step 1: Fix provider.tf
Keep the provider configuration only in provider.tf.
Replace its contents with:

provider "aws" {
  region = "ap-northeast-1"
}



Step 2: Fix main.tf
Delete the existing contents of main.tf and paste this complete configuration. It includes all closing braces and creates three EC2 instances.

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
}



Important: If out.tf contains old outputs referencing aws_eip.test_tag, remove those outdated output blocks or update them to match the resources above. Otherwise, Terraform validation will still fail.
Step 3: Run these commands
Run them one at a time in PowerShell:
terraform fmt
terraform validate
terraform init
terraform plan


If validation succeeds and the plan is correct, create the instances:
terraform apply
