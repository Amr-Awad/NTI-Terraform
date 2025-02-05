# TERRAFORM

![Terraform Icon](/assetes/icons8-terraform.svg)

## Overview

This project uses Terraform to create and manage AWS infrastructure. The main components of the infrastructure include a Virtual Private Cloud (VPC), subnets, an internet gateway, a NAT gateway, security groups, and EC2 instances.

## Architecture
![Diagram](./day1-architecture.png)

## Files

- `Day 1/terraform-files/vpc.tf`: This file contains the Terraform configuration for setting up the AWS infrastructure.

## AWS Infrastructure Details

### VPC

The VPC is defined with the following configuration:
- CIDR Block: `10.0.0.0/16`
- Tags: `Name = "Terraform VPC"`

### Subnets

Two subnets are created within the VPC:
- Public Subnet:
  - CIDR Block: `10.0.1.0/24`
  - Tags: `Name = "public_tf_subnet"`
- Private Subnet:
  - CIDR Block: `10.0.2.0/24`
  - Tags: `Name = "private_tf_subnet"`

### Internet Gateway

An internet gateway is attached to the VPC:
- Tags: `Name = "igw-terraform"`

### NAT Gateway

A NAT gateway is created in the public subnet to allow instances in the private subnet to access the internet:
- Tags: `Name = "gw NAT"`

### Security Groups

A security group is created to allow inbound TLS and SSH traffic and all outbound traffic:
- Name: `allow_tls`
- Description: `Allow TLS inbound traffic and all outbound traffic`

### EC2 Instances

Two EC2 instances are created:
- Public Instance:
  - AMI: Latest Ubuntu 22.04
  - Instance Type: `t3.micro`
  - Subnet: Public Subnet
  - Tags: `Name = "HelloTerraForm"`
- Private Instance:
  - AMI: Latest Ubuntu 22.04
  - Instance Type: `t3.micro`
  - Subnet: Private Subnet
  - Tags: `Name = "ByeTerraForm"`

### Key Pair

A key pair is generated for SSH access to the EC2 instances:
- Key Name: `my-terraform-key`
- Private Key: Stored locally as `my_terraform_key.pem`

## Usage

To apply the Terraform configuration and create the infrastructure, run the following commands:

```sh
cd Day\ 1/terraform-files
terraform init
terraform apply