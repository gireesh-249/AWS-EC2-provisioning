# AWS EC2 Instance (Virtual Machines) (Manual + Terraform)

This README describes two ways to create an EC2 (virtual machine) on AWS:

- **Manual** — using the AWS Management Console (with helpful AWS CLI/local commands listed)
- **Terraform** — Infrastructure as Code with short steps and example configuration

---

## 🔧 Part - 1: Manual (AWS Console)

### Step-by-step (Console)
1. **Sign in to the AWS Management Console** and open the **EC2** service in your chosen region.
2. **Launch Instance** → Click **Launch instances**.
3. **Choose an AMI (Amazon Machine Image)** — pick a Linux/Windows image and region-specific AMI.
4. **Choose an Instance Type** — e.g., `t2.micro` (free tier eligible) or other types depending on CPU/ram needs.
5. **Configure Instance Details** — set VPC, subnet, auto-assign public IP, IAM role, user data (optional).
6. **Add Storage** — define root volume size and type (EBS).
7. **Add Tags** — e.g., `Name = my-ec2-instance` to identify the instance.
8. **Configure Security Group** — add rules (e.g., SSH 22 from your IP, HTTP 80 if web server).
9. **Key Pair** — create a new key pair or choose an existing one; **download the private key (`.pem`)** if creating.
10. **Review and Launch** — confirm settings and click **Launch**.
11. **Connect** — use **EC2 Instance Connect**, SSH, or Session Manager to access the instance.

> Note: AMI IDs vary by region; pick the one appropriate for your region and OS.

### Useful commands (AWS CLI and local client)
- `aws ec2 create-key-pair --key-name my-key --query 'KeyMaterial' --output text > my-key.pem` — create a key pair and save private key locally.
- `chmod 400 my-key.pem` — restrict private key permissions (Linux/macOS/WSL) so SSH will accept it.
- `aws ec2 run-instances --image-id <ami-id> --count 1 --instance-type t2.micro --key-name my-key --security-groups my-sg` — launch one EC2 instance via AWS CLI.
- `aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"` — list running instances and details.
- `aws ec2 terminate-instances --instance-ids i-0123456789abcdef0` — stop and terminate an instance when done.
- `aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxx --protocol tcp --port 22 --cidr <your-ip>/32` — add an SSH rule to a security group.
- `ssh -i my-key.pem ec2-user@<public-ip>` — SSH into Amazon Linux/AMI instance (replace user if Ubuntu/other).
- `aws ec2 allocate-address` / `aws ec2 associate-address` — allocate and attach an Elastic IP if you need a static public IP.

---

## 🌱 Part-2: Terraform (Infrastructure as Code)

### High-level Steps
1. **Install Terraform** (https://www.terraform.io/downloads).
2. **Configure AWS credentials** (e.g., `aws configure` or environment variables: `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`).
3. **Create working directory** and a `main.tf` file with `provider` and an `aws_instance` resource (and security group/key pair).
4. **Initialize** the working directory: `terraform init`.
5. **Review plan**: `terraform plan` to preview changes.
6. **Apply**: `terraform apply` and confirm to create resources.
7. **Connect** to the instance (SSH using the created key or as configured).
8. **Destroy**: `terraform destroy` when you no longer need the instance.

### Key Terraform commands (one-line descriptions)
- `terraform init` — initialize plugins and backend for the working directory.
- `terraform validate` — check the syntax and internal consistency of the configuration.
- `terraform plan -out tfplan` — create an execution plan and save it to `tfplan`.
- `terraform apply tfplan` — apply the saved plan (or `terraform apply` to apply interactively).
- `terraform fmt` — format Terraform files to canonical style.
- `terraform destroy` — destroy the resources created by your configuration.

### Minimal example `main.tf`
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # restrict in production
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95c71c99" # example: region-specific
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  tags = {
    Name = "terraform-ec2-example"
  }
}
```

> Replace the `ami` with a valid AMI for your region and tighten security group rules for production (do not use 0.0.0.0/0 unless needed).

---

## ⚠️ Notes & Tips
- Costs: EC2 instances may incur charges; terminate resources or `terraform destroy` to avoid ongoing costs. ✅
- Permissions: Ensure your AWS credentials have appropriate IAM permissions for EC2 operations.
- Key safety: Keep private keys secure and never commit them to source control.
- Regions & AMIs: AMI IDs are region-specific — always select the correct AMI for your region.

---

If you want, I can also add a complete, ready-to-run Terraform example that creates a key pair, security group, and EC2 instance tailored to a specific region. 💡
