# IAM Role - Node Group
resource "aws_iam_role" "node_group" {
  name = var.aws_iam_role_node_group_name
 
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# IAM Policy Attachment - Node Group Policy 
resource "aws_iam_role_policy_attachment" "node_group_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

# IAM Policy Attachment - EKS CNI Policy
resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}
 
# IAM Policy Attachment - Container Registry Read Only
resource "aws_iam_role_policy_attachment" "ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

# IAM Policy Attachment - DynamoDB Policy
resource "aws_iam_role_policy_attachment" "dynamodb_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.node_group.name
}

# IAM Policy Attachment - XRay Policy
resource "aws_iam_role_policy_attachment" "xray_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.node_group.name
}

# Node Group
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.aws_eks_node_group_name
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.application_subnet_ids

  scaling_config {
    desired_size = var.subnet_count
    max_size     = var.subnet_count * 2
    min_size     = var.subnet_count
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_group_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy,
    aws_iam_role_policy_attachment.dynamodb_policy,
  ]

  ami_type = "AL2_x86_64" # (Optional) Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to AL2_x86_64. Valid values: AL2_x86_64, AL2_x86_64_GPU. Terraform will only perform drift detection if a configuration value is provided.   

  disk_size = 20 # (Optional) Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided. 

  instance_types = ["t3.small"] # (Optional) Set of instance types associated with the EKS Node Group. Defaults to ["t3.medium"]. Terraform will only perform drift detection if a configuration value is provided. Currently, the EKS API only accepts a single value in the set. 

  # labels - (Optional) Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed. 

  release_version = "1.15.10-20200228" # (Optional) AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version. https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html

  # remote_access - (Optional) Configuration block with remote access settings. Detailed below. 

  # tags - (Optional) Key-value mapping of resource tags. 

  version = "1.15" # (Optional) Kubernetes version. Defaults to EKS Cluster Kubernetes version. Terraform will only perform drift detection if a configuration value is provided. 
}
