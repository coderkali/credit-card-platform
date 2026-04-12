data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = "sts:AssumeRole"
  }
}

resource "aws_iam_role" "eks_clsuter" {
    name = "eks_cluster-role"
    assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role

    tags = {
        Name = "eks-cluster-role"
        Environment = var.environment
    }
}


resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    policy_arn = "arn:aws:iam:aws:policy//AmazonEKSClusterPolicy"
    role = aws_iam_role.eks_clsuter.name
}

# Attach VPC Resource Controller policy
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

# Output
output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}


