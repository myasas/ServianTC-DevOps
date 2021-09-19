# ServianTC-DevOps

Introduction
-------------------------------
This set up aims to build and deploy Servian's TechChallengeApp to AWS Cloud infrastructure while adhering to following guidelines. 

### **Prerequisites**
* AWS IAM Account with Priviledged access for following services
  * EC2, EKS, ELB, S3, SSM, RDS, IAM, etc.
* AWS CLI
* Terraform Core installed
* Makefile runtime (Ability to run Makefile)
* CLI Utilities: envsubst, etc.
* Network reachability to "http://ipv4.icanhazip.com" (in evaluating public IP of Terraform Core workstation for whitelisting)


## Architecture
* Architecture Design Records (ADR) are recorded in  [DesignRecords.md](DesignRecords.md) - this file.
* **Decision Tree.** (More details in [DesignRecords.md#5-finalize-design-decisions--network--resiliency](DesignRecords.md))
![Dicision Tree](https://drive.google.com/uc?export=view&id=1rIwPT1eiqitH_zlGjG48x0JhVPLbRKvu)
* **Architecture Diagram.** (More details in [DesignRecords.md#6-finalize-architecture](DesignRecords.md))
![Architecture Diagram](https://drive.google.com/uc?export=view&id=1Alyc_8pXIag2RCma3BkUI7tkGjUi6wor)

## Directory Structure
| Directory                | Purpose/Description                                                                                                                                              |
|--------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [terraform](./terraform) | Contains Terraform modules and scripts needed to spin up infrastructure needed to implement infrastructure on which TechChallengeApp will be deplyed on.
| [k8-manifests](./k8-manifests)     | Contains palceholder view of k8-manifests required to deploy and run TechChallengeApp in EKS Fargate.                                                                   |
| [aws-s3-be-policy](./aws-s3-be-policy)     | Contains bucket policy template for Terraform backend s3 bucket.                                                                   |



## Process and Instructions - Infrastructure Creation and Configuration

### Requirements to define a new environment

Requirements to create a new environment are:
- Create an S3 bucket to store data and states.

Remember to create two files that define an environment within the folder "terraform/envs/#ENV#/".
- backend.conf
- default.tfvars
Note: Here environment is considered as PreProd.

### Common steps
* AWS "access key ID", "secret access key" for user with nessasary permissions
* Prepare s3 bucket with neccessary permissions to act as Terraforms state bucket

### Steps to follow if Terraform command process is chosen
1. Simple command to see functionality of terraform core
```shell
terraform
```

### Steps to follow if Make file process is chosen?

1. Simple command to see functionality of makefile
```shell
make
```




Work Breakdown
-------------------------------
**Immediate**
- [x] Used proper Git workflow: [Gitflow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [X] Prepared level architectural overview of my deployment.
- [X] Security (Network segmentation (if applicable to the implementation), Secret storage, Platform security features)
- [X] Resiliency (Auto scaling and highly available frontend, Highly available Database)
**Todo**
- [ ] Prepared process instructions for provisioning my solution.

**Noticed**
- [X] If you are setting up the database using RDS, do not run the ./TechChallengeApp updatedb command. Instead run ./TechChallengeApp updatedb -s