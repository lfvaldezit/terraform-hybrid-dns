# Hybrid DNS between AWS and simulated ONPREM infra

## 🏗️ Architecture

**VPC**: Isolated environment to launch AWS resources
**EC2 Instances**: VM to provision ONPREM DNS servers and APP servers
**Route53 Private Hosted Zone**: Private DNS zone for the AWS VPC
**IN/OUT Route53 Resolver**: Enables DNS queries between VPC and external DNS servers
**SSM Endpoints**: Allows EC2 instances in private subnets to communicate with AWS Systems Manager
**S3 Gateway Endpoint**: Allows EC2 instances to be able  to download from Amazon S3 repolist

## 🚀 Quick Start

1. **Clone the repository**

   ```bash
   git clone <your-repo-url>
   cd terraform-hybrid-dns
   ```
2. **Configure AWS credentials**

   ```bash
   aws configure
   ```

3. **ONPREM infrastructure**

   ```bash
   cd /Environment/ONPREM
   terraform init
   ```
   Adjusts the variables from the terraform.example.tfvars as you needed

   ```bash
   terraform plan -var-file terraform.tfvars
   terraform apply -var-file terraform.tfvars
   ```
   Take the output and copy into a txt file. Example:
   
    ```bash
    ONPREM-CIDR_BLOCK = "10.192.0.0/16"
    ONPREM-DNS-1 = "10.192.1.27"
    ONPREM-DNS-2 = "10.192.2.107"
    ONPREM-RT_ID = "rtb-0d3a0bd1c33979d62"
    ONPREM-VPC_ID = "vpc-0fec92ec59d1da940"
   ```

5. **AWS infrastructure**

   ```bash
   cd /Environment/AWS
   terraform init
   ```