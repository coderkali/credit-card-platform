data "aws_iam_policy_document" "eks_node_assume_role" {
   statement {
     effect = "Allow"

     principals {
       type = "Service"
       identifiers = ["ec2.amazonaws.com"]
     }
     actions = ["sts:AssumeRole"]
   }
}

resource "aws_iam_role" "eks_node" {
    name = "eks-node-role"
    assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

     tags = {
       Name        = "eks-node-role"
       Environment = var.environment
    }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_instance_profile" "eks_node" {
  name_prefix = "eks-node-"
  role        = aws_iam_role.eks_node.name
}

output "eks_node_role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = aws_iam_role.eks_node.arn
}

output "eks_node_instance_profile_arn" {
  description = "ARN of the EKS node instance profile"
  value       = aws_iam_instance_profile.eks_node.arn
}



