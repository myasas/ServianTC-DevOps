# ServianTC-DevOps - Demo

## Accessing the Servan TC App

* THe app can be Accessed using following url
  * [https://k8s-default-serviant-cdf7ccb486-753701826.ap-southeast-2.elb.amazonaws.com/](https://k8s-default-serviant-cdf7ccb486-753701826.ap-southeast-2.elb.amazonaws.com/)
  
## Screenshots of the Servian TC App

* Following screenshot shows how the app is being accessed using above public URL.

![APP UI](https://drive.google.com/uc?export=view&id=1RNjabWxCYJJgpFVg0CD3ZAyzNMmULbzr)

* Following screenshot shows how the SSL certificate of the public URL.

![APP UI with Certificate](https://drive.google.com/uc?export=view&id=1Yy85dxuzzm2wNITwxM3aPa51VMd2RtKj)


## Screenshots of the Kubernetes Platform

* Following screenshot shows summarzed view of EKS Fargate K8s cluster.
![K8s UI-Summary](https://drive.google.com/uc?export=view&id=1hWVILbuJcugzm-EmpQyUB3aPjxIzYqn2)


* Following screenshot shows deployment view of EKS Fargate K8s cluster. 
  * Highligted is the deployment of Servian TC App
![K8s UI-Deployments](https://drive.google.com/uc?export=view&id=11LO-sj2mLmhmjGMaaCbID2Qlun_Odniw)

* Following screenshot shows pod view of EKS Fargate K8s cluster. 
  * Highligted is the pods related Servian TC App deployment.
![K8s UI-Pods](https://drive.google.com/uc?export=view&id=1ZxEICQheqVzdSJdrd8oAdAJH8SOugws-)

* Following screenshot shows secrets of EKS Fargate K8s cluster.
  * Highligted is the DB credential related to RDS based DB created for Servian TC App
![K8s UI-Credentials](https://drive.google.com/uc?export=view&id=1DYiP3Fi9_Qj8KyMsBSzu9T5np6ZIe39f)

* Following screenshot shows how HPA or the Horizontal Pod Autoscaller has been deployed to the EKS Fargate K8s cluster.
  * Highlighted is how the HPA is configured to keep Servian App's replica count between 2-5, depending on the load it gets.
![K8s CLI-HPA](https://drive.google.com/uc?export=view&id=1a0ArC_vKjvUqiNAvnFTl2rdx3BqithDp)