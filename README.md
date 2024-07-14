# Terraform AWS Infrastructure Project

This project sets up a multi-tier architecture on AWS using Terraform. The infrastructure includes a Virtual Private Cloud (VPC), subnets, security groups, EC2 instances, a Relational Database Service (RDS) instance, and an Application Load Balancer (ALB). The project is configured to use an S3 backend for state management and a DynamoDB table for state locking, ensuring that the state is safely stored and managed.

## Overview

### Infrastructure Components

1. **VPC and Subnets**:
   - Creates a VPC with private, public, and database subnets across three availability zones (AZs) in the `eu-north-1` region.
   - Configures NAT gateways to allow instances in the private subnets to access the internet.

2. **Security Groups**:
   - Defines security groups for different services, including authentication, UI, weather service, SSH access, and the database.
   - Manages ingress and egress rules to control traffic to and from these services.

3. **EC2 Instances**:
   - Deploys EC2 instances for the authentication service, UI service, weather service, and a bastion host for SSH access.
   - Configures instances to use a specified AMI and instance type (`t3.micro`).

4. **RDS Instance**:
   - Sets up a MySQL RDS instance within the database subnets.
   - Configures database settings, including username, allocated storage, and backup windows.

5. **Application Load Balancer**:
   - Creates an ALB to distribute incoming traffic to the UI service EC2 instances.
   - Configures listeners and target groups for load balancing HTTP traffic.

6. **SSM Parameters and Secrets Manager**:
   - Manages sensitive information such as database credentials using AWS Systems Manager (SSM) Parameter Store and AWS Secrets Manager.
   - Stores the database endpoint, username, and password securely.

### State Management

- Utilizes an S3 bucket (`morkeh-terraform-state`) for storing Terraform state files.
- Implements a DynamoDB table (`Terraform-backend-lock`) to handle state locking and prevent concurrent modifications.

## Objectives

- **Scalability**: The architecture is designed to be scalable across multiple availability zones, ensuring high availability and fault tolerance.
- **Security**: Implements security best practices with properly configured security groups and IAM roles for accessing AWS resources.
- **Automation**: Uses Terraform to automate the provisioning and management of AWS infrastructure, making the process repeatable and consistent.
- **State Management**: Ensures safe and reliable state management using S3 and DynamoDB for storing and locking the Terraform state.

This project serves as a robust foundation for deploying and managing a multi-tier application on AWS, with a focus on best practices in infrastructure as code (IaC).