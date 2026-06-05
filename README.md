# Flask-Express Terraform Deployment

A complete Infrastructure-as-Code solution for deploying a Flask backend and Express frontend application on AWS using Terraform.

## Project Overview

This project provisions a production-ready AWS infrastructure with:
- **Flask Backend** (Python): RESTful API running on port 5000
- **Express Frontend** (Node.js): Web server running on port 3000
- **Networking**: VPC with public subnets, Internet Gateway, and route tables
- **Security**: Security groups with controlled ingress/egress rules
- **Container Registry**: Amazon ECR for Docker images
- **State Management**: Remote state stored in S3 with DynamoDB locking

## Architecture

```
┌─────────────────────────────────────────────┐
│         AWS VPC (10.0.0.0/16)               │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────────┐  ┌──────────────────┐ │
│  │  Public Subnet A │  │  Public Subnet B │ │
│  │  (10.0.1.0/24)   │  │  (10.0.2.0/24)   │ │
│  │                  │  │                  │ │
│  │ ┌──────────────┐ │  │ ┌──────────────┐ │ │
│  │ │  Frontend    │ │  │ │  Backend     │ │ │
│  │ │  EC2 :3000   │ │  │ │  EC2 :5000   │ │ │
│  │ └──────────────┘ │  │ └──────────────┘ │ │
│  └──────────────────┘  └──────────────────┘ │
│           │                      │           │
│  ┌────────┴──────────────────────┴────────┐ │
│  │   Internet Gateway (IGW)                 │ │
│  │   Route: 0.0.0.0/0 → IGW                │ │
│  └────────┬──────────────────────┬────────┘ │
│           │                      │           │
└───────────┼──────────────────────┼───────────┘
            │                      │
   (Public Internet)    (Public Internet)
```

## Prerequisites

### Local Requirements
- **Terraform** >= 1.0
- **AWS CLI** v2
- **Git**
- **SSH key pair** (create one or use existing)

### AWS Requirements
- AWS account with IAM permissions
- S3 bucket for state (auto-created by `backend.tf`)
- DynamoDB table for locking (auto-created by `backend.tf`)
- EC2, VPC, Security Group permissions

## Project Structure

```
seperate-ec2/
├── main.tf                 # Main infrastructure resources (EC2, VPC, Security Groups)
├── backend.tf              # Remote state configuration (S3 + DynamoDB)
├── variable.tf             # Input variables
├── outputs.tf              # Output values
├── backend.sh              # Flask backend initialization script
├── frontend.sh             # Express frontend initialization script
├── BACKEND_CONFIG.md       # State management setup guide
└── README.md               # This file
```

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/your-repo/terraform.git
cd terraform/seperate-ec2
```

### 2. Configure AWS Credentials

```bash
aws configure
```

Provide:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., `us-east-1`)
- Output format: `json`

### 3. Update Variables (Optional)

Edit `variable.tf` to customize:

```hcl
variable "region" {
  default = "us-east-1"  # Change your region
}

variable "ecs_execution_role_arn" {
  default = "arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole"
}
```

### 4. Initialize Terraform

```bash
terraform init
```

This:
- Downloads AWS provider plugins
- Creates local state directory
- Validates backend configuration

### 5. Review the Plan

```bash
terraform plan
```

Outputs all resources that will be created:
- 2 EC2 instances
- 1 VPC
- 2 public subnets
- 1 Internet Gateway
- Security groups
- S3 bucket & DynamoDB table

### 6. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes ~5-10 minutes.

### 7. Get Output Values

```bash
terraform output
```

Returns:
- Frontend public IP
- Backend public IP
- ECR repository URLs
- S3 bucket name
- DynamoDB table name

## Configuration Files

### `main.tf`
Contains all AWS resources:
- EC2 instances (backend + frontend)
- VPC networking
- Security groups
- ECR repositories

### `backend.tf`
Terraform remote state configuration:
- S3 bucket for state storage
- DynamoDB table for state locking
- Encryption and versioning enabled

### `variable.tf`
Input variables:
- AWS region
- IAM execution role ARN

### `outputs.tf`
Output values for easy access to resource information.

### `backend.sh` & `frontend.sh`
Cloud-init scripts for EC2 user data:
- Package installation
- Git repo cloning
- Application startup
- Logging

## Application Details

### Backend (Flask)
- **Repository**: https://github.com/jha-aditya67/FLASK-EXPRESS-DOCKER-PROJECT.git
- **Port**: 5000
- **Endpoint**: `/submit` (POST)
- **Request Body**:
  ```json
  {
    "name": "John",
    "email": "john@example.com"
  }
  ```

### Frontend (Express)
- **Port**: 3000
- **Backend URL**: Injected via Terraform template
- **Endpoint**: `/` (GET) - serves form
- **Endpoint**: `/submit` (POST) - submits to backend

## Deployment Workflow

### Step 1: Backend Resources First
```bash
terraform apply -target=aws_s3_bucket.terraform_state \
                 -target=aws_dynamodb_table.terraform_locks
```

### Step 2: Update Backend Configuration
Add to `terraform {}` block in `main.tf`:
```hcl
backend "s3" {
  bucket         = "terraform-state-ACCOUNT-ID-REGION"
  key            = "app/terraform.tfstate"
  region         = "your-region"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

### Step 3: Reinitialize & Deploy
```bash
terraform init
terraform plan
terraform apply
```

## Accessing the Application

1. Get frontend public IP:
   ```bash
   terraform output frontend_public_ip
   ```

2. Open in browser:
   ```
   http://<frontend-public-ip>:3000
   ```

3. Submit the form to test backend connectivity.

## State Management

### Remote State (S3 + DynamoDB)

**Benefits:**
- Team collaboration
- State locking prevents concurrent modifications
- Versioning and history
- Encryption at rest

**Bucket Name Format:**
```
terraform-state-{ACCOUNT_ID}-{REGION}
```

**Verify Remote State:**
```bash
terraform state list
terraform state show aws_instance.backend
```

## Troubleshooting

### Issue: "Can't reach this page"

**Cause**: Instance not fully initialized

**Solution**:
1. SSH into instance:
   ```bash
   ssh -i your-key.pem ubuntu@<public-ip>
   ```

2. Check application logs:
   ```bash
   sudo cat /var/log/cloud-init-output.log
   sudo cat /home/ubuntu/backend.log
   sudo cat /home/ubuntu/frontend.log
   ```

3. Check running processes:
   ```bash
   ps aux | grep python
   ps aux | grep node
   ```

### Issue: "Error connecting to backend"

**Cause**: Frontend cannot reach backend private IP

**Solution**:
1. Verify backend private IP:
   ```bash
   terraform output backend_private_ip
   ```

2. SSH to frontend and test connectivity:
   ```bash
   curl http://<backend-private-ip>:5000/submit
   ```

3. Check security group rules:
   ```bash
   aws ec2 describe-security-groups --group-ids <sg-id>
   ```

### Issue: "Network unreachable"

**Cause**: No internet access for package installation

**Solution**:
1. Verify Internet Gateway is attached:
   ```bash
   aws ec2 describe-internet-gateways
   ```

2. Check route table:
   ```bash
   aws ec2 describe-route-tables
   ```

3. Ensure subnets have `map_public_ip_on_launch = true`

## Manual App Restart

SSH into instance and restart services:

```bash
# Stop services
pkill -f "python3 app.py"
pkill -f "node server.js"

# Backend
cd /home/ubuntu/app/backend
source venv/bin/activate
nohup python app.py --host=0.0.0.0 --port=5000 > backend.log 2>&1 &

# Frontend
cd /home/ubuntu/app/frontend
nohup node server.js > frontend.log 2>&1 &
```

## Monitoring & Debugging

### View Cloud-init Output
```bash
ssh -i your-key.pem ubuntu@<public-ip>
sudo cat /var/log/cloud-init-output.log
```

### Check Application Logs
```bash
cat /home/ubuntu/backend.log
cat /home/ubuntu/frontend.log
```

### Test Backend Endpoint
```bash
curl -X POST http://<backend-ip>:5000/submit \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@example.com"}'
```

## Cleanup

### Destroy All Resources
```bash
terraform destroy
```

### Keep State in S3
State will remain in S3 bucket. To preserve history:
```bash
aws s3 ls s3://terraform-state-ACCOUNT-ID-REGION/
```

### Delete Remote State
```bash
aws s3 rm s3://terraform-state-ACCOUNT-ID-REGION/app/terraform.tfstate
aws dynamodb delete-table --table-name terraform-locks
```

## Security Best Practices

1. **Restrict SSH Access**: Update CIDR blocks in security group
2. **Use IAM Roles**: Assign roles instead of access keys to instances
3. **Enable S3 Encryption**: Already enabled in `backend.tf`
4. **Version Control**: Don't commit sensitive data (keys, secrets)
5. **State File**: Always use remote state with encryption
6. **Backup**: Enable S3 versioning (already enabled)

## Advanced Configuration

### Custom VPC CIDR
Edit in `main.tf`:
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"  # Change CIDR
}
```

### Add Private Subnets
Add to `main.tf`:
```hcl
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}a"
}
```

### Scale to Multiple Regions
Use `terraform workspace`:
```bash
terraform workspace new us-west-2
terraform apply -var="region=us-west-2"
```

## Contributing

1. Create a feature branch
2. Make changes
3. Run `terraform plan` and review
4. Submit pull request
5. Merge after approval
6. Deploy with `terraform apply`

## Support

For issues or questions:
1. Check troubleshooting section
2. Review logs with SSH
3. Open an issue in the repository

## License

MIT License - See LICENSE file

## Author

Aditya Jha

## Changelog

### v1.0.0
- Initial setup with Flask backend and Express frontend
- VPC networking with public subnets
- Remote state management with S3 + DynamoDB
- Security groups with appropriate ingress rules
- Auto-scaling initialization scripts
