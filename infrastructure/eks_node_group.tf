data "aws_ami" "eks_ami" {
    most_recent = true
    owners = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.main.version}-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}


resource "aws_launch_template" "eks_node" {
  name_prefix   = "eks-node-"
  image_id      = data.aws_ami.eks_ami.id
  instance_type = "t3.medium"

  iam_instance_profile {
    arn = aws_iam_instance_profile.eks_node.arn
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [aws_security_group.private.id]
    delete_on_termination = true
  }

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "eks-worker-node"
      Environment = var.environment
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "eks-worker-volume"
      Environment = var.environment
    }
  }
}

resource "aws_eks_node_group" "primary" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "credit-card-primary"
  node_role_arn   = aws_iam_role.eks_node.arn
  
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
  
  version = aws_eks_cluster.main.version

  scaling_config {
    desired_size = 2
    max_size = 4
    min_size = 2
  }

  instance_types = ["t3.medium"]

  launch_template {
    id      = aws_launch_template.eks_node.id
    version = aws_launch_template.eks_node.latest_version_number
  }

  tags = {
    Name        = "credit-card-primary"
    NodeGroup   = "primary"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}

resource "aws_eks_node_group" "batch" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "credit-card-batch"
  node_role_arn   = aws_iam_role.eks_node.arn
  
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
  
  version = aws_eks_cluster.main.version

  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 2
  }

  instance_types = ["t3.medium"]

  launch_template {
    id      = aws_launch_template.eks_node.id
    version = aws_launch_template.eks_node.latest_version_number
  }

  tags = {
    Name        = "credit-card-batch"
    NodeGroup   = "batch"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}

output "primary_node_group_id" {
  description = "Primary node group ID"
  value       = aws_eks_node_group.primary.id
}

output "batch_node_group_id" {
  description = "Batch node group ID"
  value       = aws_eks_node_group.batch.id
}

output "primary_node_group_status" {
  description = "Primary node group status"
  value       = aws_eks_node_group.primary.status
}

output "batch_node_group_status" {
  description = "Batch node group status"
  value       = aws_eks_node_group.batch.status
}

output "launch_template_id" {
  description = "Launch template ID used by node groups"
  value       = aws_launch_template.eks_node.id
}