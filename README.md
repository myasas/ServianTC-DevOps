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

Note: Here environment is considered as preprod.

### Common steps

To configure the infrastructure it is necessary to declare the environment variables:

```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_DEFAULT_REGION=ap-southeast-2
export ENVIRONMENT=preprod
```

**Or you can also define** an AWS Profile (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) on your machine and use it:

```bash
export AWS_DEFAULT_REGION=ap-southeast-2
export AWS_PROFILE=preprod
export ENVIRONMENT=preprod
```

Following environment variables are required in S3 buicket creation,
```bash
export AWS_ACC_ID=
export AWS_S3_BUCKET=
```

### Steps to follow **if Make file process is chosen?**
**0. Create S3 Bucket**
* With make file, you are given with facility of simply creating s3 bucket with required permissions and policy. You can additionally define following paramers at the beginning if s3 bucket creation is required.

```bash
make init-s3
```

**1. Update dependancies**
```bash
make init
```

**2. Deploy of infrastructure**
```bash
make deploy
```

**3. Destroy of infrastructure**
```bash
make destroy
```

### Steps to follow **if Terraform command process is chosen?**
**0. Create S3 Bucket**
```bash
cd aws-s3-be-policy
aws s3 mb s3://${AWS_S3_BUCKET}
aws s3api put-public-access-block \
    --bucket ${AWS_S3_BUCKET} \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
envsubst < policy.json.template > mypolicy.json
aws s3api put-bucket-policy --bucket ${AWS_S3_BUCKET} --policy file://mypolicy.json
rm -rf mypolicy.json
```

**1. Update dependancies**

To update the dependencies and start the project execution, it is necessary to perform the following steps:

```bash
cd terraform/infrastructure
rm -rf .terraform
terraform get -update=true
terraform init -backend=true -backend-config=../envs/${ENVIRONMENT}/backend.conf
```
**Note:** This step must always be done before deploying or destroying the infrastructure.

**2. Deploy of infrastructure**


```bash
cd terraform/infrastructure
terraform plan -var-file="../envs/${ENVIRONMENT}/default.tfvars" -out=.terraform/terraform.tfplan
terraform apply .terraform/terraform.tfplan
```

**3. Destroy of infrastructure**

```bash
cd terraform/infrastructure
terraform destroy -var-file="../envs/${ENVIRONMENT}/default.tfvars"
```



My(Yasas's) Work Breakdown
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