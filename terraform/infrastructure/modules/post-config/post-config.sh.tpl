#!/bin/sh

set -e

echo "-- Load the system variables to connect to AWS --"
$(cat credentials.txt)
rm credentials.txt

echo "-- Connect to K8S with administration permissions --"
aws eks update-kubeconfig --name ${cluster_name}

echo "-- Show info of the cluster --"
kubectl cluster-info

echo "-- Configure the roles and allow the nodes to join --"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${eks_node_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${eks_fargate_role_arn}
      username: system:node:{{SessionName}}
      groups:
        - system:bootstrappers
        - system:nodes
        - system:node-proxier
    - rolearn: ${eks_k8s_masters_role_arn}
      username: user-admin::{{SessionName}}
      groups:
        - system:masters
    - rolearn: ${eks_k8s_readonly_role_arn}
      username: user-readonly::{{SessionName}}
      groups:
        - readonly
  mapUsers: |
%{ for user_arn in eks_arn_user_list_with_masters_user ~}
    - groups:
        - system:masters
      userarn: ${user_arn}
      username: user-admin::{{SessionName}}
%{ endfor ~}
EOF

echo "-- Set up roles for read-only access --"
cat <<EOF | kubectl apply -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: readonly
  namespace: default
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: readonly-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: readonly
subjects:
- kind: Group
  name: readonly
EOF

echo "-- Configure the POD's to have internet access --"
kubectl -n kube-system set env daemonset aws-node AWS_VPC_K8S_CNI_EXTERNALSNAT=true

echo "-- Reconfigured CoreDNS for Fargate --"
# kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]' || true
kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "add", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type", "value":"fargate"}]' || true

echo "-- Restart deploy CoreDNS --"
kubectl rollout restart -n kube-system deploy coredns

echo "-- Configure aws load balancer controller --"
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller \
  eks/aws-load-balancer-controller \
  --set clusterName=${cluster_name} \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.create=true \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${eks_lb_controller_role_arn}" \
  --set region=ap-southeast-2 \
  --set vpcId=${vpc_id} \
  -n kube-system -f alb_ing_helm_values.yaml --version=1.2.3

# kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
# helm upgrade -i aws-load-balancer-controller \
#   eks/aws-load-balancer-controller \
#   -n kube-system \
#   --set serviceAccount.create=true \
#   --set serviceAccount.name=aws-load-balancer-controller \
#   --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${eks_lb_controller_role_arn}" \
#   --set clusterName=${cluster_name} \
#   --set region=ap-southeast-2 \
#   --set vpcId=${vpc_id}

echo "-- Restart deploy AWS Load Balancer Controller --"
kubectl rollout restart -n kube-system deploy aws-load-balancer-controller

echo "-- Configure external dns --"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: ${eks_external_dns_role_arn}
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: external-dns
  namespace: kube-system
rules:
- apiGroups: [""]
  resources: ["services","endpoints","pods"]
  verbs: ["get","watch","list"]
- apiGroups: ["extensions","networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get","watch","list"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
  namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
  namespace: kube-system
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: k8s.gcr.io/external-dns/external-dns:v0.7.3
        args:
        - --source=service
        - --source=ingress
        - --domain-filter=${domain_name}
        - --provider=aws
        - --policy=upsert-only # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
        - --aws-zone-type=public # only look at public hosted zones (valid values are public, private or no value for both)
        - --registry=txt
        - --txt-owner-id=axa-gulf
      securityContext:
        fsGroup: 65534 # For ExternalDNS to be able to read Kubernetes and AWS token files
EOF

echo "-- Restart deploy external dns --"
kubectl rollout restart -n kube-system deploy external-dns

rm /home/ec2-user/.kube/config
