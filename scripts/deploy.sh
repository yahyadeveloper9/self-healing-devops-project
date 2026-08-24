#!/bin/bash
set -e

echo "============================================================"
echo "DEPLOYING SELF-HEALING RESUME PLATFORM"
echo "============================================================"

if ! command -v terraform &> /dev/null; then
    echo "Error: terraform is required but not installed."
    exit 1
fi



if [ -z "$ANSIBLE_PRIVATE_KEY_FILE" ]; then
    echo "Error: ANSIBLE_PRIVATE_KEY_FILE is not set."
    echo "Please set it: export ANSIBLE_PRIVATE_KEY_FILE=C:\xampp\htdocs\awspem\TerrformAnsibleProject.pem"
    exit 1
fi

echo "[1/4] Provisioning AWS Infrastructure with Terraform..."
cd terraform
terraform init
terraform validate
terraform apply -auto-approve

echo "[2/4] Generating Ansible Inventory..."
EC2_IP=$(terraform output -raw ec2_public_ip)
RESUME_BUCKET=$(terraform output -raw resume_bucket_name)
AWS_REGION=$(grep 'aws_region' terraform.tfvars | cut -d '"' -f 2 || echo "ap-south-1")
cd ..

cat <<EOF > ansible/inventory/hosts.ini
[webservers]
$EC2_IP ansible_user=ubuntu

[webservers:vars]
resume_bucket_name=$RESUME_BUCKET
aws_region=$AWS_REGION
EOF

echo "Inventory generated at ansible/inventory/hosts.ini"

echo "[3/4] Waiting for SSH to become available..."
until ssh -i "$ANSIBLE_PRIVATE_KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@$EC2_IP "echo 'SSH is available!'"; do
    echo "Waiting for SSH..."
    sleep 5
done

echo "[4/4] Configuring server with Ansible remotely on the EC2 instance..."
echo "Packaging files for upload..."
tar --exclude="website/backend/node_modules" -czf resume-deploy.tar.gz ansible website monitoring

echo "Uploading files to server..."
scp -i "$ANSIBLE_PRIVATE_KEY_FILE" -o StrictHostKeyChecking=no resume-deploy.tar.gz ubuntu@$EC2_IP:/tmp/
rm -f resume-deploy.tar.gz

ssh -i "$ANSIBLE_PRIVATE_KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$EC2_IP << EOF
  echo "Installing Ansible and Docker on server (please wait)..."
  export DEBIAN_FRONTEND=noninteractive
  export NEEDRESTART_MODE=a
  sudo yum install -y -q ansible > /dev/null 2>&1 || (sudo -E apt-get update -qq > /dev/null 2>&1 && sudo -E apt-get install -y -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" ansible docker.io > /dev/null 2>&1)
  
  sudo mkdir -p /opt/resume-platform
  echo "Extracting files..."
  sudo tar -xzf /tmp/resume-deploy.tar.gz -C /opt/resume-platform/
  sudo chown -R ubuntu:ubuntu /opt/resume-platform
  
  echo "Cleaning up any native processes blocking ports..."
  sudo docker rm -f resume-app-container resume-backend-container resume-apache-container resume-nginx-container || true
  sudo systemctl stop nginx || true
  sudo systemctl stop apache2 || true
  sudo systemctl stop resume-app || true
  sudo fuser -k 80/tcp || true
  sudo fuser -k 8080/tcp || true
  sudo fuser -k 8081/tcp || true
  sudo fuser -k 3000/tcp || true

  echo "Performing nuclear reset of OS firewall (iptables) to fix timeout issues..."
  sudo ufw disable || true
  sudo iptables -F || true
  sudo iptables -X || true
  sudo iptables -t nat -F || true
  sudo iptables -t nat -X || true
  sudo iptables -t filter -F || true
  sudo iptables -t filter -X || true
  sudo iptables -P INPUT ACCEPT || true
  sudo iptables -P FORWARD ACCEPT || true
  sudo iptables -P OUTPUT ACCEPT || true
  
  echo "Building Docker image (this will take 1-2 minutes, you will see progress below)..."
  sudo systemctl restart docker || true
  cd /opt/resume-platform/website
  sudo docker build -t resume-backend .
  
  cd /opt/resume-platform/ansible
  
  cat <<INV > inventory/hosts.ini
[webservers]
localhost ansible_connection=local

[webservers:vars]
resume_bucket_name=$RESUME_BUCKET
aws_region=$AWS_REGION
INV

  sudo ANSIBLE_ROLES_PATH=./roles ansible-playbook -i inventory/hosts.ini playbooks/site.yml -c local

  echo "Validating containers..."
  sleep 5 # Wait for containers to boot
  
  FAILED=0
  for container in resume-backend-container resume-apache-container resume-nginx-container; do
      if ! sudo docker ps --format '{{.Names}}' | grep -q "^\${container}$"; then
          echo "============================================================"
          echo "ERROR: \${container} FAILED TO START OR CRASHED!"
          echo "Logs for \${container}:"
          sudo docker logs \${container} || echo "No logs found."
          echo "============================================================"
          FAILED=1
      fi
  done
  
  if [ \$FAILED -eq 1 ]; then
      echo "DEPLOYMENT FAILED DUE TO CONTAINER CRASHES."
      exit 1
  fi
EOF

echo "============================================================"
echo "DEPLOYMENT COMPLETE"
echo "============================================================"
echo "Health Dashboard (Apache) : http://$EC2_IP:8080/"
echo "Nginx Dummy Website       : http://$EC2_IP/"
echo "Backend API (Node.js)     : http://$EC2_IP:3000/api/health"
echo "============================================================"
