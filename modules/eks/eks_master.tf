# IAM Role - EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = var.aws_iam_role_eks_cluster_name
 
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# IAM Policy Attachment - EKS Cluster Policy
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# IAM Policy Attachment - EKS Service Policy
resource "aws_iam_role_policy_attachment" "service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Security Group
resource "aws_security_group" "this" {
  name        = var.aws_security_group_name
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group Rule
resource "aws_security_group_rule" "this" {
  cidr_blocks       = ["${var.accessing_computer_ip}/32"] # Todo: Add /32
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  to_port           = 443
  type              = "ingress"
}

# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.aws_eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
 
  vpc_config {
    subnet_ids         = var.app_gtwy_subnet_ids
    security_group_ids = ["${aws_security_group.this.id}"]
  }

  enabled_cluster_log_types = ["api", "audit"]

  # TODO: encryption_config

  # TODO: tags
 
  version  = "1.15" # (Optional) Desired Kubernetes master version. If you do not specify a value, the latest available version at resource creation is used and no upgrades will occur except those automatically triggered by EKS. The value must be configured and increased to upgrade the version when desired. Downgrades are not supported by EKS. 

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.service_policy,
    aws_cloudwatch_log_group.this,
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/${var.aws_eks_cluster_name}/cluster"
  retention_in_days = 7
}
