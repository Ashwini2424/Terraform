# Terraform: Create Multiple AWS EC2 Instances

A beginner-friendly Terraform project using the official HashiCorp AWS provider. This project shows how to configure the provider, create a security group, launch three EC2 instances, display outputs, validate the configuration, and save the project to GitHub.

## Project files

Keep these files in the same folder:

```text
Terraform/
├── main.tf
├── provider.tf
├── out.tf
├── .gitignore
└── README.md
```

## 1. `provider.tf`

This file configures the official HashiCorp AWS provider. Keep the provider block here only; do not duplicate it in `main.tf`.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
```

The example uses the Asia Pacific (Tokyo) region. Change the region if your resources are in another region.

Official reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

## 2. `main.tf`

This configuration finds the default VPC and the latest Amazon Linux 2023 AMI, creates a security group, and creates three EC2 instances.

```hcl
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
  description = "Security group for Terraform EC2 instances"
  vpc_id      = data.aws_vpc.default.id

  # Allow outbound traffic.
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
```

The `count = 3` setting creates three instances named `terraform-server-1`, `terraform-server-2`, and `terraform-server-3`.

Official references:

- EC2 instance: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
- Security group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
- `count`: https://developer.hashicorp.com/terraform/language/meta-arguments/count

## 3. `out.tf`

Keep the outputs in this file only. Do not define these same output names in `main.tf`.

```hcl
output "instance_ids" {
  description = "IDs of the created EC2 instances"
  value       = aws_instance.web[*].id
}

output "public_ips" {
  description = "Public IP addresses of the EC2 instances, if assigned"
  value       = aws_instance.web[*].public_ip
}
```

Note: This configuration does not explicitly request public IP addresses. The `public_ips` output may contain empty values if AWS does not assign public IPs in the selected subnet.

## 4. `.gitignore`

Create a `.gitignore` file so local Terraform state and secret variable files are not committed.

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
crash.*.log
*.auto.tfvars
terraform.tfvars
.env
.env.*
```

Do not commit AWS access keys, secret keys, `.env` files, or Terraform state files. The Terraform dependency lock file (`.terraform.lock.hcl`) is generally useful to commit for repeatable provider selection.

## 5. Set up AWS authentication

AWS CLI must be installed and working. Use your organization's approved authentication method. For browser-based login, if supported by your AWS CLI version:

```powershell
aws login --profile browser-login
aws sts get-caller-identity --profile browser-login
$env:AWS_PROFILE = "browser-login"
```

If browser login is not supported or your organization requires IAM access keys, configure an authorized profile using `aws configure --profile browser-login`, then verify with `aws sts get-caller-identity --profile browser-login`.

Never paste credentials into source files or commit them to GitHub.

## 6. Validate and plan

Open PowerShell in the project folder:

```powershell
cd "$env:USERPROFILE\Desktop\Terraform"
```

Run the commands one at a time:

```powershell
terraform fmt
terraform init
terraform validate
terraform plan
```

Expected validation message:

```text
Success! The configuration is valid.
```

If `terraform init` reports a provider version conflict, review the provider version constraint and the existing `.terraform.lock.hcl` file.

Before applying, confirm that your AWS account has a default VPC in the selected region and that your account has permission to create EC2 instances, security groups, and read AMI/VPC information.

## 7. Create and verify the instances

Only after reviewing the plan and confirming it is correct, run:

```powershell
terraform apply
```

Review the plan and type `yes` only if you intend to create the resources. Running EC2 instances can incur AWS charges.

After a successful apply, display the outputs:

```powershell
terraform output instance_ids
terraform output public_ips
```

## 8. Destroy the resources when finished

If you have finished testing and want to remove the resources managed by this configuration, run:

```powershell
terraform destroy
```

Review the destruction plan and type `yes` only if you intend to delete the listed resources. Do not run destroy if you want to keep using the instances.

## 9. Save the project to GitHub

### A. Initialize Git and stage files

From the project folder:

```powershell
git init
git add main.tf provider.tf out.tf .gitignore README.md
git status
```

Check the staged files carefully. Make sure credentials, `.env` files, and Terraform state files are not staged.

Commit the files:

```powershell
git commit -m "Add Terraform configuration for multiple EC2 instances"
```

If Git asks for your identity, configure your own name and GitHub email:

```powershell
git config --global user.name "Your Name"
git config --global user.email "your-github-email@example.com"
```

Then run the commit command again.

### B. Connect to the GitHub repository

For the existing repository `Ashwini2424/Terraform`, check the remote:

```powershell
git remote -v
```

If `origin` is already configured for that repository, keep it. Otherwise, add it:

```powershell
git remote add origin https://github.com/Ashwini2424/Terraform.git
```

If `origin` exists but points to the wrong URL, update it:

```powershell
git remote set-url origin https://github.com/Ashwini2424/Terraform.git
```

### C. Pull before pushing if GitHub already has commits

If GitHub already contains a README or other commits that are missing locally, integrate them before pushing:

```powershell
git pull origin main --allow-unrelated-histories
```

If Vim opens for the merge message, press `Esc`, type `:wq`, and press `Enter`.

If Git reports conflicts, resolve them in VS Code, save the files, and then run:

```powershell
git add .
git commit -m "Merge remote changes"
```

Do not run the merge commit command if Git has already completed the merge and says there is nothing to commit.

### D. Push to GitHub

```powershell
git branch -M main
git push -u origin main
```

If the push is rejected because GitHub has new commits, pull and resolve any conflicts first. Avoid `git push --force`, which can overwrite remote history.

Verify:

```powershell
git status
git remote -v
```

Refresh https://github.com/Ashwini2424/Terraform to check that the files are visible.

## Troubleshooting

### Duplicate provider configuration

Keep the `provider "aws"` block only in `provider.tf`.

### Duplicate output definition

Keep `instance_ids` and `public_ips` only in `out.tf`. Remove duplicate definitions from `main.tf`.

### Undeclared resource

Terraform references must match the resource labels exactly. This project declares `aws_instance.web` and `aws_security_group.multi_instance_sg`.

### Default VPC not found

The selected AWS region must have a default VPC. If it does not, use an existing VPC ID and a suitable subnet instead of the default-VPC data source.

### Git push rejected (fetch first)

Run `git pull origin main --allow-unrelated-histories`, resolve conflicts if any, then push again. Do not force-push unless you deliberately intend to replace remote history and understand the consequences.
<img width="1894" height="679" alt="image" src="https://github.com/user-attachments/assets/2e084ed2-bd7d-48bd-8e15-0a702e747c73" />
