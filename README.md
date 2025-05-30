# AWS VPC, EC2, and ALB Setup
This Terraform project provisions a foundational AWS infrastructure, including a Virtual Private Cloud (VPC), two public subnets, an Internet Gateway, route tables, a security group, two EC2 instances, and an Application Load Balancer (ALB) to distribute traffic between the instances.

# Features
Custom VPC: A dedicated Virtual Private Cloud (VPC) for your resources.
Two Public Subnets: Resources deployed across two availability zones for high availability.
Internet Gateway: Enables communication between your VPC and the internet.
Route Tables: Configured to direct internet-bound traffic through the Internet Gateway.
Security Group: A flexible security group allowing inbound HTTP (80), HTTPS (443), and SSH (22) traffic, along with all outbound traffic.
Two EC2 Instances: t2.micro instances launched into different subnets, configured with user data scripts (userdata.sh and userdata1.sh).
Application Load Balancer (ALB): Distributes incoming HTTP traffic (port 80) to the EC2 instances, enhancing fault tolerance and scalability.
ALB Target Group & Listener: Configured to health-check and forward traffic to the EC2 instances.
# Prerequisites
Before you can deploy this infrastructure, ensure you have the following:

# Terraform: Install Terraform on your local machine.
AWS Account & CLI: An active AWS account and the AWS CLI configured with appropriate credentials.
userdata.sh and userdata1.sh files: These bash scripts will be executed on your EC2 instances upon launch. Create them in the root of your Terraform project directory.
Note: The AMI ID (ami-0261755bbcb8c4a84) is for us-east-1. If you are deploying to a different AWS region, you must update this AMI ID to a valid one for your chosen region. You can find valid AMIs in the EC2 console or by using the AWS CLI.
# Project Structure

```
.
├── main.tf             # Contains the core AWS resource definitions
├── variables.tf        # Defines input variables like CIDR blocks
├── outputs.tf          # (Optional, but recommended) Defines outputs for easy access to resource attributes
├── userdata.sh         # User data script for the first EC2 instance
└── userdata1.sh        # User data script for the second EC2 instance
└── README.md           # This file
```

# Usage
Follow these steps to deploy the infrastructure:

Clone the Repository:
```
git clone <repository_url>
cd <repository_directory>
```

Create User Data Scripts:
Create userdata.sh and userdata1.sh in the same directory as your .tf files. These scripts will run when your EC2 instances launch.

Example userdata.sh (for basic web server):

```
#!/bin/bash
sudo apt update -y
sudo apt install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Hello from EC2 Instance 1!</h1>" | sudo tee /var/www/html/index.html
```
Example userdata1.sh (for basic web server):

```
#!/bin/bash
sudo apt update -y
sudo apt install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Hello from EC2 Instance 2!</h1>" | sudo tee /var/www/html/index.html
```

Initialize Terraform:
Navigate to the project root directory and initialize Terraform. This downloads the necessary providers.

```
terraform init
```

Review the Plan:
See what Terraform plans to create without making any changes.

`terraform plan`

You will be prompted to provide values for cidr, sub1_cidr, and sub2_cidr.

Example Variable Values:
> cidr: 10.0.0.0/16
> sub1_cidr: 10.0.1.0/24
> sub2_cidr: 10.0.2.0/24

Apply the Configuration:
If the plan looks good, apply the configuration to provision the resources.

`terraform apply`

Confirm the action by typing yes when prompted.

After Deployment
Once terraform apply is complete, Terraform will output the ALB DNS name. You can use this DNS name in your browser to access the web servers running on your EC2 instances via the Load Balancer.

You can also use terraform output to retrieve specific values:

`terraform output # Lists all defined outputs`

Cleanup
To destroy all the provisioned resources, run:

`terraform destroy`

Type yes when prompted to confirm the deletion. This will tear down all the AWS resources managed by this Terraform configuration.
