# TERRAFORM

![Terraform](https://img.icons8.com/color/144/000000/terraform.png)      ![AWS](https://img.icons8.com/color/144/000000/amazon-web-services.png)

## Overview

This Terraform configuration provisions a highly available web server infrastructure on AWS, featuring an Application Load Balancer (ALB), Auto Scaling Group, and multi-AZ deployment.

## Architecture 
![Architecture Diagram](./architecture.jfif)

- **VPC** with public and private subnets across 2 Availability Zones (AZs).
- **NAT Gateways** for outbound internet access from private subnets.
- **Internet Gateway**: To allow internet access to the public subnets.
- **Application Load Balancer (ALB)** distributing traffic to EC2 instances.
- **Auto Scaling Group** with launch template for automatic scaling.
- **CloudWatch Alarms** to trigger scaling based on CPU usage.

## Features
- 🛡️ Security groups restricting traffic to HTTP/SSH only.
- 🔄 Auto Scaling maintains 2-4 EC2 instances across private subnets.
- 🌐 Public-facing ALB with health checks.
- 🔑 SSH key pair auto-generated for EC2 access.

## Prerequisites
1. **AWS Account**: Configured with CLI credentials (`aws configure`).
2. **Terraform**: [Installed](https://www.terraform.io/downloads.html) (v1.0+ recommended).
3. **Key Pair**: Terraform will generate an `ec2.pem` file automatically.

## Usage

To deploy the Terraform configuration from the **Day-2** branch, follow these steps:

1. **Checkout the Day-2 branch and pull the latest changes:**
    ```sh
    git checkout Day-2
    git pull origin Day-2
    ```

2. **Initialize Terraform:**
    ```sh
    terraform init
    ```

3. **Apply the Terraform configuration:**
    ```sh
    terraform apply
    ```
