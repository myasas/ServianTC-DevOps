# ServianTC-DevOps - Decisions

- [ServianTC-DevOps - Decisions](#serviantc-devops---decisions)
- [1. Record architecture decisions](#1-record-architecture-decisions)
  - [Details](#details)
- [2. Selection of cloud provider](#2-selection-of-cloud-provider)
  - [Details](#details-1)
- [3. Cloud Region Selection](#3-cloud-region-selection)
  - [Details](#details-2)
- [4. Consider prerequisitess and obtain Design decisions  (Network | Resiliency)](#4-consider-prerequisitess-and-obtain-design-decisions--network--resiliency)

# 1. Record architecture decisions

Date: 2020-09-06

## Details

* Noticed importance of having ADR (Architecture Decision Records). 
* Yet considering time contraints I have with current projects decided to follow similar pattern with bulletpoints

# 2. Selection of cloud provider

Date: 2020-09-06

## Details

* Considered following cloud providers,
  * AWS
  * Azure
  * GCP
  * Huawei Cloud
* Selected |**AWS**| as cloud provider considering,
  * Best knowledgable area
  * Time constraints
  * Past expireinces with cloud provider


# 3. Cloud Region Selection

Date: 2020-09-06
## Details

* Chose Asia Pacific (Sydney)ap-southeast-2 also considering  
  * Least latency (closet geographical datacenters)
  * Availability of x3 availability zones.

# 4. Consider prerequisitess and obtain Design decisions  (Network | Resiliency)

Date: 2020-09-06

* Considered following requirements of the challange, and came up with design decisions.
  * Security 

    Reqirement| Decision |
    ---------|----------|
    Network segmentation | * Avoid use of defaul vpc<br /> *Take steps to create new VPC covering all AZs.
    Secret storage | * Store credentials, keys in SSM parameter store.
    Platform security features | * Avoid direct expose of port 80/ HTTP <br/> * Only expose port 443/HTTPS and Configure secure SSL certificate. <br/> * Change default SSH port 22 to 1986 (if applicable) 

  * Resiliency

    Reqirement | Decision
    ---------|----------
    Auto scaling and highly available frontend | * Referrs to high availablity of application.<br /> *Consider use of containerized approach over the EC2/VM based approach (considering easy and efficient scalability of containers) <br /> *Cosider use of ECS or EKS for the container ochestration.
    Highly available Database | * Reffers to availability of backend database, which might affect functionality of application. <br /> *
