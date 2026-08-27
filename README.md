# 🚀 Self-Healing AWS Infrastructure

[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)

A complete end-to-end self-healing infrastructure project on AWS using Terraform, Ansible, and Docker. This project automatically provisions infrastructure, deploys applications, monitors health, and recovers automatically from failures.

## 🎥 Demo / Result

Watch the final working project and self-healing demonstration here:

<a href="https://youtu.be/z3V2TL9ySks?si=RzsVZYFPrkp_2egp">
  <img 
    src="https://img.youtube.com/vi/z3V2TL9ySks/hqdefault.jpg"
    alt="Watch Project Demo"
    width="600"
  >
</a>

**[👉 Click to watch the complete project demo](https://youtu.be/z3V2TL9ySks?si=RzsVZYFPrkp_2egp)**

## 🏗️ Architecture

`mermaid
graph TD
    A[Terraform] -->|Provisions| B(AWS VPC, EC2, SG, S3)
    C[Ansible] -->|Configures| B
    B -->|Runs| D[Docker Containers]
    D --> E[Nginx Reverse Proxy]
    D --> F[Health Monitor Script]
    F -->|Detects Failure| G[Restarts Services]
    G -->|Self-Heals| D
`

## ✨ Key Features
- **Infrastructure as Code (IaC):** Automated AWS provisioning using Terraform.
- **Configuration Management:** Server configuration and Docker deployment using Ansible.
- **Self-Healing:** Custom health monitoring scripts that detect service crashes and automatically restore them without manual intervention.
- **Security First:** Strict Security Groups, IAM roles, and SSH key management.

## 🛠️ Prerequisites
Before you start, make sure you have these installed on your machine:
- [Docker](https://www.docker.com/products/docker-desktop)
- [Git](https://git-scm.com/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [AWS CLI](https://aws.amazon.com/cli/)

## 🚀 Setup Instructions

**1. AWS CLI Login**
Open your terminal and configure your AWS credentials. Make sure the IAM user you are logging in with has AdministratorAccess permissions.
\\\ash
aws configure
\\\
Enter your Access Key, Secret Key, and default region (e.g., p-south-1).

**2. SSH Key Setup**
- Go to the AWS EC2 Console and create a new key pair (PEM format).
- Download the .pem file to a secure folder on your machine.
- Change its permissions to 400 (read-only for the owner).
- Set it as an environment variable in PowerShell so the deployment script knows where to find it:
\\\powershell
$env:ANSIBLE_PRIVATE_KEY_FILE="C:\path\to\your\key.pem"
\\\

**3. Configure Variables**
Create a 	erraform/terraform.tfvars file (you can copy from 	erraform.tfvars.example) and update the values:
- ws_region: Set your preferred region (e.g. "ap-south-1")
- esume_bucket_name: Give a globally unique name for the S3 bucket.
- key_name: The exact name of the key pair you created in AWS (without the .pem extension).

## 🏃 How to Run

**Open Powershell** and go to the project directory:
\\\powershell
cd C:\Path\To\ProjectDirectory
\\\

Set the path to your PEM file:
\\\powershell
$env:ANSIBLE_PRIVATE_KEY_FILE="C:\path\to\your\key.pem"
\\\

Deploy the entire architecture with one command:
\\\powershell
& "C:\Program Files\Git\bin\bash.exe" scripts/deploy.sh
\\\
*(Grab a coffee, it takes a few minutes to provision AWS and configure Docker via Ansible.)*

## 🗑️ How to Destroy

To avoid unwanted AWS charges, tear down everything when you are done:
\\\powershell
& "C:\Program Files\Git\bin\bash.exe" scripts/destroy.sh
\\\

## 📜 License
This project is licensed under the MIT License.
