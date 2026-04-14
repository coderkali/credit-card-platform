resource "aws_eks_cluster" "main" {
    name= "credit-card-eks"
    role_arn = aws_iam_role.eks_cluster.arn
    version = "1.29"

    vpc_config {
        subnet_ids = [
           aws_subnet.private_subnet_1.id,
           aws_subnet.private_subnet_2.id
      ]

      security_group_ids = [aws_security_group.private.id]

      endpoint_private_access = true
      endpoint_public_access = true
    }

    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

    tags = {
        Name = "credit-card-eks"
        Environment = var.environment
    }

    depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy, 
                  aws_iam_role_policy_attachment.eks_vpc_resource_controller  ]

}

output "eks_cluster_id" {
  value = aws_eks_cluster.main.id
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.main.arn
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
  value = aws_eks_cluster.main.version
}