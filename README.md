# AWS EC2 Instance (Virtual Machines) (Manual + Terraform)

This README describes two ways to create an EC2 (virtual machine) on AWS:

- **Manual** — using the AWS Management Console (with helpful AWS CLI/local commands listed)
- **Terraform** — Infrastructure as Code with short steps and example configuration

---
## Prerequisites

- An AWS account with permissions to create EC2 resources.
- A region selected for all resources (example: `ap-south-1`).
- Optional but recommended: enable MFA (Multi-Factor Authentication) on your AWS account.

For Terraform provisioning, you also need:
- Terraform installed (`terraform -v`).
- AWS CLI installed (`aws --version`).
- AWS credentials configured (via `aws configure`).

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
- create a key pair and save private key locally.
```bash 
aws ec2 create-key-pair --key-name my-key --query 'KeyMaterial' --output text > my-key.pem
```
- security-groups my-sg` — launch one EC2 instance via AWS CLI
```bash 
aws ec2 run-instances --image-id <ami-id> --count 1 --instance-type t2.micro --key-name my-key
```
- list running instances and details.
```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"
```
- stop and terminate an instance when done.
```bash 
aws ec2 terminate-instances --instance-ids i-0123456789abcdef0
```
-  add an SSH rule to a security group
```bash 
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxx --protocol tcp --port 22 --cidr <your-ip>/32
```
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



---

## ⚠️ Notes & Tips
- Costs: EC2 instances may incur charges; terminate resources or `terraform destroy` to avoid ongoing costs. ✅
- Permissions: Ensure your AWS credentials have appropriate IAM permissions for EC2 operations.
- Key safety: Keep private keys secure and never commit them to source control.
- Regions & AMIs: AMI IDs are region-specific — always select the correct AMI for your region.
