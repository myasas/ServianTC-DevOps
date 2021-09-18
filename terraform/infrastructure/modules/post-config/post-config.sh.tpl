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

echo "-- ****** DEPLOY SERVIAN TECH CHALLENGE APP ****** --"
cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: Namespace
# metadata:
#   name: servian
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: servian-conf
data:
  DbName: "postgres"
  DbPort: ${app_backend_db_port}
  DbHost: ${app_backend_db_host}
  ListenHost: "0.0.0.0"
  ListenPort: "3000"
---
apiVersion: v1
kind: Secret
metadata:
  name: serviantc-secret
data:
  # You can include additional key value pairs as you do with Opaque Secrets
  dbuser: ${app_backend_db_user}
  dbpassword: ${app_backend_db_password}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: serviantc
  namespace: default
spec:
  replicas: 2
  strategy:
    type: Recreate
  selector:
    matchLabels:
      deployment: serviantc
      product: serviantcapp
  template:
    metadata:
      labels:
        deployment: serviantc
        product: serviantcapp
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9201"
        prometheus.io/path: /metric-service/metrics
    spec:
      securityContext:
          runAsUser: 0
          runAsGroup: 0
          fsGroup: 0
      containers:
        - image: servian/techchallengeapp:latest
          name: servian
          args: ['serve']
          imagePullPolicy: Always
          livenessProbe:
            exec:
              command: ["/bin/sh", "-c", "nc -z localhost 3000"]
            initialDelaySeconds: 20
            failureThreshold: 15
            periodSeconds: 10
          readinessProbe:
            exec:
              command: ["/bin/sh", "-c", "nc -z localhost 3000"]
            initialDelaySeconds: 20
            failureThreshold: 15
            periodSeconds: 10
          # lifecycle:
            # postStart:
            #   exec:
            #     command: ["/bin/sh", "-c", "./TechChallengeApp updatedb -s"]
          resources:
            requests:
              memory: 64Mi
              cpu: 100m
            limits:
              memory: 200Mi
              cpu: 150m
          ports:
            - containerPort: 3000
              protocol: "TCP"
          env:
            # Define the environment variable
            - name: WATCH_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: NODE_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
            - name: VTT_DBUSER
              valueFrom:
                secretKeyRef:
                  name: serviantc-secret
                  key: dbuser
            - name: VTT_DBPASSWORD
              valueFrom:
                secretKeyRef:
                  name: serviantc-secret
                  key: dbpassword

            - name: VTT_DBNAME
              valueFrom:
                configMapKeyRef:
                  name: servian-conf
                  key: DbName
            - name: VTT_DBPORT
              valueFrom:
                configMapKeyRef:
                  name: servian-conf
                  key: DbPort
            - name: VTT_DBHOST
              valueFrom:
                configMapKeyRef:
                  name: servian-conf
                  key: DbHost
            - name: VTT_LISTENHOST
              valueFrom:
                configMapKeyRef:
                  name: servian-conf
                  key: ListenHost
            - name: VTT_LISTENPORT
              valueFrom:
                configMapKeyRef:
                  name: servian-conf
                  key: ListenPort
      # serviceAccountName: servian-svc-account
---
apiVersion: v1
kind: Service
metadata:
  name: serviantc
  namespace: default
spec:
  selector:
    deployment: serviantc
    product: serviantcapp
  type: NodePort
  ports:
    - name: http
      protocol: TCP
      port: 3000
      targetPort: 3000

EOF

echo "-- ****** DEPLOY APPLICATION LOAD BALANCER ****** --"
cat <<EOF | kubectl apply -f -
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: serviantc-ext-gws
  namespace: default
  annotations:
    # TO - AUTO UPDATE FROM TERRAFORM
    alb.ingress.kubernetes.io/certificate-arn: >-
      ${eks_alb_ing_ssl_cert_arn}
    # Health Check Settings
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
    alb.ingress.kubernetes.io/healthcheck-port: "3000"
    alb.ingress.kubernetes.io/healthcheck-path: /healthcheck/
    alb.ingress.kubernetes.io/backend-protocol: HTTP

    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/tags: >-
      Type=NoManual,Client=Servian,Project=Servian-Test,Environment=preprod,App=serviantc-ext-gws
    alb.ingress.kubernetes.io/target-type: ip
    # external-dns.alpha.kubernetes.io/hostname: a1-ext-gws.atom.servian-Test.com
    kubernetes.io/ingress.class: alb


    # Security Settings -
      # TODO - FUTURE ENHANCEMENT- WHITELIST IPS FROM ALB SECURITY GROUPS
    # alb.ingress.kubernetes.io/inbound-cidrs: 10.227.245.60/32
      # TODO - FUTURE ENHANCEMENT-BIND ALB TO A WAF FOR IMPROVED SECURITY
    # alb.ingress.kubernetes.io/wafv2-acl-arn: arn:aws:wafv2:ap-southeast-2:176325838707:regional/webacl/waf-external-web-acl/e075cd0c-dac9-44c2-b9b0-4997a8d53832

    # Logging
      # TODO - FUTURE ENHANCEMENT-ENABLE ALB LOGGING AND STORE IN S3 BUCKET. ENABLE DELETE PROTECTION FOR ALB
    # alb.ingress.kubernetes.io/load-balancer-attributes: access_logs.s3.enabled=true,access_logs.s3.bucket=preprod-servian-Test-alb-access-logs,routing.http.drop_invalid_header_fields.enabled=true,routing.http2.enabled=true,idle_timeout.timeout_seconds=60,deletion_protection.enabled=true

spec:
  rules:
    - http:
        paths:
          - path: /*
            backend:
              serviceName: serviantc
              servicePort: 3000
EOF

echo "-- ****** CONFIGURE DB TABLES IN INITIAL RUN ****** --"
sleep 60
kubectl exec -it --namespace=default $(kubectl get pods -o name -A | grep -m1 servian) -- sh -c "./TechChallengeApp updatedb -s"

rm /home/ec2-user/.kube/config
