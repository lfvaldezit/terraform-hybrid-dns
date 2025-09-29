# Hybrid DNS between AWS and simulated ONPREM infra

## 🏗️ Architecture

- **VPC**: An isolated environment for launching AWS resources
- **EC2 Instances**: VM used to provision ON-PREM DNS servers and APP servers
- **Route53 Private Hosted Zone**: A private DNS zone for the AWS VPC
- **IN/OUT Route53 Resolver**: Enables DNS queries between the VPC and external DNS servers
- **SSM Endpoints**: Allow EC2 instances in private subnets to communicate with AWS Systems Manager
- **S3 Gateway Endpoint**: Allows EC2 instances to download from the Amazon S3 repository list

## ⚙️ Configuration

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

4. **ON-PREM infrastructure**

   ```bash
   cd /Environments/ONPREM
   terraform init
   ```
   Adjusts the variables in terraform.example.tfvars as needed

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
   ```bash
    terraform plan
   ```

   ```bash
    terraform apply
   ```

   Save the output  into a txt file. Example:
    ```hcl
    ONPREM-CIDR_BLOCK = "10.192.0.0/16"
    ONPREM-DNS-1 = "10.192.1.27"
    ONPREM-DNS-2 = "10.192.2.107"
    ONPREM-RT_ID = "rtb-0d3a0bd1c33979d62"
    ONPREM-VPC_ID = "vpc-0fec92ec59d1da940"
    ```

   Then configure the `/etc/systemd/resolved.conf` file in the EC2 application server to use the DNS servers:

    ```bash
    DNS= 
    Domains=~.
    ```

5. **AWS infrastructure**

   ```bash
   cd /Environments/AWS
   terraform init
   ```
    Adjusts the variables in terraform.example.tfvars as needed

    ```bash
    name       = "vpc-aws"
    cidr_block = "192.168.0.0/16"

    subnets = [{ name = "aws-private-1a", cidr_block = "192.168.1.0/24", az = "us-east-1a" },
    { name = "aws-private-1b", cidr_block = "192.168.2.0/24", az = "us-east-1b" }]

    ami_id        = "ami-08982f1c5bf93d976"
    instance_type = "t2.micro"

    domain_name = "example4life.org"

    inbound_r53_resolver_ip_1 = "192.168.1.200"
    inbound_r53_resolver_ip_2 = "192.168.2.200"

    # --------------- OUTPUT ONPREM INFRA ----------------- #

    target_domain_name    = "onprem.example4life.org"
    target_vpc_id         = "vpc-0fec92ec59d1da940" # ONPREM-VPC_ID
    target_cidr_block     = "10.192.0.0/16"         # ONPREM-CIDR_BLOCK
    target_route_table_id = "rtb-0d3a0bd1c33979d62" # ONPREM-RT_ID
    target_ip_primary     = "10.192.1.27"           # ONPREM-DNS-1
    target_ip_secondary   = "10.192.2.107"          # ONPREM-DNS-2
     ```

    ```bash
    terraform plan
    ```

    ```bash
    terraform apply
    ```