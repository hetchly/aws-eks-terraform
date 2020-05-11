# Terraform module to provision an AWS EKS Cluster, Node Group and VPC with Public and Private Subnets

## This creates the following resources:
- VPC
- Internet Gateway
- Route Table: Gateway
- Route Table: Application
- Route Table: Database
- NAT Gateway
- Elastic IP
- Subnet: Gateway
- Subnet: Application
- Subnet: Database
- Route Table Association: Gateway
- Route Table Association: Application
- Route Table Association: Database
- Amazon EKS Service Role
- EKS Cluster
- kubeconfig file
- Managed Node Group

## Architecture Diagram: https://www.draw.io/#G1I1q3XWw3KAdFl1bfwG3AbW_tR6GKMXsB

![Image description](https://github.com/jrdalino/aws-eks-terraform/blob/master/images/aws_vpc_architecture_diagram.png)

- TODO: Add EKS Cluster and Node Group to diagram

## Prerequisites
- Provision an S3 bucket to store Terraform State and DynamoDB for state-lock
using https://github.com/jrdalino/aws-tfstate-backend-terraform

- kubectl
```
$ brew install kubectl 
$ kubectl version
```

- AWS CLI
```
$ brew install awscli
$ aws --version
```

- aws-iam-authenticator
```
$ brew install aws-iam-authenticator
```

## Usage
- Replace variables in state_config.tf
- Replace variables in terraform.tfvars
- Initialize, Review Plan and Apply
```
$ terraform init
$ terraform plan
$ terraform apply
```

- Use the AWS CLI update-kubeconfig command to create or update your kubeconfig for your cluster.
```
$ aws eks update-kubeconfig --name myproject-eks
```

- Test your configuration
```
$ kubectl get svc
```
```
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   3m30s
```

```
$ kubectl get nodes
```
```
NAME                                             STATUS   ROLES    AGE     VERSION
ip-10-0-20-144.ap-southeast-2.compute.internal   Ready    <none>   5m8s    v1.14.7-eks-1861c5
ip-10-0-21-183.ap-southeast-2.compute.internal   Ready    <none>   5m10s   v1.14.7-eks-1861c5
ip-10-0-22-114.ap-southeast-2.compute.internal   Ready    <none>   5m2s    v1.14.7-eks-1861c5
```

- To add IAM users, Ask the EKS cluster owner or admin to add your IAM user or role to aws-auth ConfigMap. To edit aws-auth ConfigMap in a text editor, the cluster owner or admin must run the following command. https://aws.amazon.com/premiumsupport/knowledge-center/eks-api-server-unauthorized-error/
```
$ aws sts get-caller-identity
$ kubectl edit configmap aws-auth -n kube-system
$ aws eks update-kubeconfig --name eks-cluster-name --region aws-region
```
```
mapUsers: |
  - userarn: arn:aws:iam::707538076348:user/jrdalino@gmail.com(opens in new tab)
    username: testuser
    groups:
      - system:masters
```

## Inputs
| Name | Description |
|------|-------------|
| | |

## Outputs
| Name | Description |
|------|-------------|
| | |

## (In progress) Terraform Module Usage
Include this repository as a module in your existing terraform code:
```
module "eks" {
  source = "git::https://github.com/jrdalino/aws-eks-terraform.git?ref=master"
}
```

## References
