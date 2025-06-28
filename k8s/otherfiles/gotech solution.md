gotech solution
gkm it 
arcgate
kensoft
keddelabs
econnect


Pending - Env, arg, config, secret, backup, what happened with auto-scaling, multiple control node.s

PVC, access mode, limit how pvc work in deployment replica set like with all multiple pod which one will access while access the other will see the data or not which access mode should I use, we have to look at this architecture, and in multi control node env how this attached ebs for volume is work
How to traffic flow from user to app to database, statefull set

how whole dns works in k8s, args variable env

# below is the example with no auto mode

eksctl create cluster \
  --name test-cluster \
  --region us-east-1 \
  --version 1.32 \
  --nodegroup-name private-ng \
  --nodes 2 \
  --node-type t2.medium \
  --node-private-networking \
  --with-oidc \
  --asg-access \
  --full-ecr-access \
  --alb-ingress-access

 then give this oidc IAM PERMISSION

 eksctl utils associate-iam-oidc-provider --cluster my-cluster --approve
 eksctl create addon --name vpc-cni --cluster my-cluster --force
 eksctl create addon --name vpc-cni --cluster my-cluster --force
  


# below is the example with auto mode

✅ Final Command with Auto Mode (Auto-Scaling Enabled):

eksctl create cluster \
  --name my-cluster \
  --region us-east-1 \
  --version 1.33 \
  --nodegroup-name private-ng \
  --nodes 2 \
  --nodes-min 2 \
  --nodes-max 4 \
  --node-private-networking \
  --with-oidc

  ## note the below will be the IAM role with policies that by default create by eksctl

  ✅ 1. IAM Role for EKS Control Plane
🎯 Policy: AmazonEKSClusterPolicy
📌 Attached To: EKS Control Plane IAM Role (used by AWS-managed EKS service)

🔐 What it does:
Allows EKS to:

Create and manage cluster-related resources (ENIs, security groups, etc.)

Interact with AWS services like EC2, IAM, CloudWatch, etc.

✅ 2. IAM Role for Node Group (EC2 Worker Nodes)
This IAM role is attached to each EC2 worker node (the instance profile).

🛡️ Attached Policies:
a. AmazonEKSWorkerNodePolicy
🔐 Grants:

Join the EKS cluster

Communicate with the EKS control plane (via API server)

Pull config maps & secrets needed for kubelet

b. AmazonEC2ContainerRegistryReadOnly
🔐 Grants:

Read-only access to ECR (Elastic Container Registry)

Allows nodes to pull Docker container images from ECR

c. AmazonEKS_CNI_Policy
🔐 Grants:

Permission to manage ENIs (Elastic Network Interfaces)

Used by the Amazon VPC CNI plugin for networking/pod IP assignment

📌 Summary Table:
IAM Role	Attached To	Policy	Purpose
Control Plane Role	EKS control plane	AmazonEKSClusterPolicy	Manage and operate the cluster
Node Instance Role	EC2 worker nodes	AmazonEKSWorkerNodePolicy	Join cluster, run kubelet
AmazonEKS_CNI_Policy	Handle networking (ENIs)
AmazonEC2ContainerRegistryReadOnly	Pull images from ECR
