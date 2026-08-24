# Self-Healing AWS Infrastructure

Hey! This is a complete end-to-end self-healing infrastructure project on AWS using Terraform, Ansible, and Docker.

## Demo / Result

Watch the final working project and self-healing demonstration here:

<a href="https://youtu.be/z3V2TL9ySks?si=RzsVZYFPrkp_2egp">
  <img 
    src="https://img.youtube.com/vi/z3V2TL9ySks/hqdefault.jpg"
    alt="▶ Watch Project Demo"
    width="500"
  >
</a>

**▶️ Click to watch the complete project demo**

## Prerequisites
Before you start, make sure you have these installed on your machine:
- Docker
- Git
- Terraform
- Ansible
- AWS CLI

## Setup Instructions

**1. AWS CLI Login**
Open your terminal and configure your AWS credentials. Make sure the IAM user you are logging in with has `AdministratorAccess` permissions.
```powershell
aws configure
```
Enter your Access Key, Secret Key, and default region (e.g., `ap-south-1`).

**2. SSH Key Setup**
- Go to the AWS EC2 Console and create a new key pair (PEM format).
- Download the `.pem` file to a secure folder on your machine.
- Change its permissions to 400 (read-only for the owner).
- Set it as an environment variable in PowerShell so the deployment script knows where to find it:
```powershell
$env:ANSIBLE_PRIVATE_KEY_FILE="C:\path\to\your\key.pem"
```

**3. Configure Variables**
Create a `terraform/terraform.tfvars` file (you can copy from `terraform.tfvars.example`) and update the values:
- `aws_region`: Set your preferred region (e.g. "ap-south-1")
- `resume_bucket_name`: Give a globally unique name for the S3 bucket.
- `key_name`: The exact name of the key pair you created in AWS (without the .pem extension).

**4. Versions & Dependencies**
If you need to change the Terraform version or the AWS Provider version, you can find them in `terraform/backend.tf` and `terraform/main.tf` under the `required_providers` block.

## How to Run

**Open Powershell** and go to project directory
```powershell
cd C:\Path\To\ProjectDirectory
```

Set Temp Variable of path to pem file 
```powershell
$env:ANSIBLE_PRIVATE_KEY_FILE="C:\path\to\your\key.pem"
```

Deploy the entire architecture with one command
```powershell
& "C:\Program Files\Git\bin\bash.exe" scripts/deploy.sh
```
*(Grab a coffee, it takes a few minutes to provision AWS and configure Docker via Ansible.)*

## How to Destroy

To avoid unwanted AWS charges, tear down everything when you are done:
```powershell
& "C:\Program Files\Git\bin\bash.exe" scripts/destroy.sh
```
