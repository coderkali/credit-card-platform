# ===== PUBLIC SECURITY GROUP (Load Balancer) =====

resource "aws_security_group" "public" {
  name        = "public-sg"
  description = "Allow internet traffic (HTTP/HTTPS)"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "public-sg"
    Environment = var.environment
    Tier        = "Public"
  }
}

# ===== PRIVATE SECURITY GROUP (EKS) =====

resource "aws_security_group" "private" {
  name        = "private-sg"
  description = "Allow traffic from Load Balancer only"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.public.id]
    description     = "From Load Balancer"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.11.0/24", "10.0.12.0/24"]
    description = "Pod-to-pod communication"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
    description = "To VPC"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS to internet (via NAT)"
  }

  tags = {
    Name        = "private-sg"
    Environment = var.environment
    Tier        = "Private"
  }
}

# ===== DATABASE SECURITY GROUP (RDS) =====

resource "aws_security_group" "database" {
  name        = "database-sg"
  description = "Allow PostgreSQL from EKS only"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.private.id]
    description     = "From EKS pods"
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    description     = "RDS replication"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["127.0.0.1/32"]
    description = "Blocked (internal only)"
  }

  tags = {
    Name        = "database-sg"
    Environment = var.environment
    Tier        = "Database"
  }
}

# ===== OUTPUTS =====

output "public_sg_id" {
  value = aws_security_group.public.id
}

output "private_sg_id" {
  value = aws_security_group.private.id
}

output "database_sg_id" {
  value = aws_security_group.database.id
}