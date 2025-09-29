# Hybrid DNS between AWS and simulated ONPREM infra

## 🏗️ Architecture

- **VPC**: Isolated environment to launch AWS resources
- **EC2 Instances**: VM to provision ONPREM DNS servers and APP servers
- **Route53 Private Hosted Zone**: Private DNS zone for the AWS VPC
- **IN/OUT Route53 Resolver**: Enables DNS queries between VPC and external DNS servers
- **SSM Endpoints**: Allows EC2 instances in private subnets to communicate with AWS Systems Manager
- **S3 Gateway Endpoint**: Allows EC2 instances to be able  to download from Amazon S3 repolist

## 🚀 Quick Start

1. **Static Configuration**

    Select 2 static IP address to provision the INBOUND Route 53 Resolver to configure latter into the AWS infrastructure
    and the EC2 DNS servers ONPREM infrastructure. Example:
  
2. **Clone the repository**

   ```bash
   git clone <your-repo-url>
   cd terraform-hybrid-dns
   ```
3. **Configure AWS credentials**

   ```bash
   aws configure
   ```

4. **ONPREM infrastructure**

   ```bash
   cd /Environments/ONPREM
   terraform init
   ```
   Adjusts the variables from the terraform.example.tfvars as you needed

    ```bash
    name                 = "vpc-onprem"
    cidr_block           = "10.192.0.0/16"
    ami_id             = "ami-08982f1c5bf93d976"
    instance_type      = "t2.micro"

    subnets = [
        { name = "onprem-private-1a", cidr_block = "10.192.1.0/24", az = "us-east-1a" },
        { name = "onprem-private-1b", cidr_block = "10.192.2.0/24", az = "us-east-1b" }]

    inbound_r53_resolver_ip_1 = "192.168.1.200"
    inbound_r53_resolver_ip_2 = "192.168.2.200"
   ```
    Plan and then deploy the infrastructure

   ```bash
   terraform plan
   ```

   ```bash
   terraform apply
   ```

   Take the output and copy into a txt file. Example:
 
    ONPREM-CIDR_BLOCK = "10.192.0.0/16"
    ONPREM-DNS-1 = "10.192.1.27"
    ONPREM-DNS-2 = "10.192.2.107"
    ONPREM-RT_ID = "rtb-0d3a0bd1c33979d62"
    ONPREM-VPC_ID = "vpc-0fec92ec59d1da940"

5. **AWS infrastructure**

   ```bash
   cd /Environments/AWS
   terraform init
   ```
    Adjusts the variables from the terraform.example.tfvars as you needed

   ```bash
   terraform plan 
   terraform apply
   ```