# ServianTC-DevOps

Introduction
-------------------------------
This set up aims to build and deploy Servian's TechChallengeApp to AWS Cloud infrastructure while adhering to following guidelines. 

**Immediate**
- [x] Used proper Git workflow: [Gitflow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [X] Prepared level architectural overview of my deployment.
- [X] Security (Network segmentation (if applicable to the implementation), Secret storage, Platform security features)

**Todo**
- [ ] Resiliency (Auto scaling and highly available frontend, Highly available Database)
- [ ] Prepared process instructions for provisioning my solution.

**Noticed**
- [ ] If you are setting up the database using RDS, do not run the ./TechChallengeApp updatedb command. Instead run ./TechChallengeApp updatedb -s

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
| [ansible](./ansible)     | Contains Ansible scripts required to configure the servers to run TechChallengeApp with my configuration                                                                   |
| [terraform](./terraform) | Contains Terraform modules and scripts needed to spin up infrastructure needed to implement infrastructure on which TechChallengeApp will run 
| [ecs](./ecs)             | Terraform generates a task definition JSON file for each task definition we create. Those JSON files are stored in this location to be used by pipelines |


## Infrastructure Creation and Configuration

1. Simple command to see functionality of makefile
```shell
make
```
