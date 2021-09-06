# ServianTC-DevOps

Introduction
-------------------------------
This set up aims to build and deploy Servian's TechChallengeApp to AWS Cloud infrastructure while adhering to following guidelines. 

**Immediate**
- [x] Used proper Git workflow: [Gitflow Workflow](https://www.atlassian.com/git/tustorials/comparing-workflows/gitflow-workflow)
- [ ] Prepared level architectural overview of my deployment.

**Todo**
- [ ] Security (Network segmentation (if applicable to the implementation), Secret storage, Platform security features)
- [ ] Resiliency (Auto scaling and highly available frontend, Highly available Database)
- [ ] Prepared process instructions for provisioning my solution.

**Noticed**
- [ ] If you are setting up the database using RDS, do not run the ./TechChallengeApp updatedb command. Instead run ./TechChallengeApp updatedb -s

#### **Prerequisites**
* Run time environment for make file
* Terraform

## Architecture
[TBD]

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
