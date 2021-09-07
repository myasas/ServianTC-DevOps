# ServianTC-DevOps - Architecture Design Records

- [ServianTC-DevOps - Architecture Design Records](#serviantc-devops---architecture-design-records)
- [1. Record architecture decisions](#1-record-architecture-decisions)
  - [Details](#details)
- [2. Selection of cloud provider](#2-selection-of-cloud-provider)
  - [Details](#details-1)
- [3. Cloud Region Selection](#3-cloud-region-selection)
  - [Details](#details-2)
- [4. Prerequisites and Design decisions  (Network | Resiliency)](#4-prerequisites-and-design-decisions--network--resiliency)
  - [Details](#details-3)

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

# 4. Prerequisites and Design decisions  (Network | Resiliency)

## Details

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
    Auto scaling and highly available frontend | * Referrs to high availablity of application.<br /> *Consider use of containerized approach over the EC2/VM based approach (considering easy and efficient **Auto Scalability** of containers) <br /> *Cosider use of ECS or EKS for the container ochestration. [E.g: i) [ECS Auto Scaling](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html), ii) [EKS Cluster node and pod autoscaling](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html) iii) [EKS Fargate Autoscaling](https://aws.amazon.com/blogs/containers/autoscaling-eks-on-fargate-with-custom-metrics/)  ] </br> * Consider use if ALB for Load Balancing traffic to frontend application to gain **High Availablity** for the frontend. [E.g: i) [ECS Service load balancing](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-load-balancing.html), ii) [EKS Load balancer with Nginx Ingress Controller](https://aws.amazon.com/blogs/opensource/network-load-balancer-nginx-ingress-controller-eks/)]
    Highly available Database | * Reffers to availability of backend database, which might affect functionality of application. <br /> * Make use of [High availability (Multi-AZ) for Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html) with automatic failover.
