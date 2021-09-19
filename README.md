# ServianTC-DevOps

Introduction
-------------------------------
This set up aims to build and deploy Servian's TechChallengeApp to AWS Cloud infrastructure while adhering to following guidelines. 

#### **Prerequisites**
* Terraform
* AWS Cli 
* AWS "access key ID", "secret access key" for user with nessasary permissions
* Run time environment for make file
* Prepare s3 bucket with neccessary permissions to act as Terraforms state bucket

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




## Infrastructure Creation and Configuration

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