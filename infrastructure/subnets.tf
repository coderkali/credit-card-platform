resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    map_public_ip_on_launch = true

    tags = {
        Name = "public-subnet-1"
        Environment = var.environment
        Tier = "Public"
    }
}

# Public Subnet 2 (us-east-1b)
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-2"
    Environment = var.environment
    Tier        = "Public"
  }
}

# ===== PRIVATE SUBNETS =====

# Private Subnet 1 (us-east-1a)
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "private-subnet-1"
    Environment = var.environment
    Tier        = "Private"
  }
}

# Private Subnet 2 (us-east-1b)
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name        = "private-subnet-2"
    Environment = var.environment
    Tier        = "Private"
  }
}

# ===== DATABASE SUBNETS =====

# Database Subnet 1 (us-east-1a)
resource "aws_subnet" "database_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "database-subnet-1"
    Environment = var.environment
    Tier        = "Database"
  }
}

# Database Subnet 2 (us-east-1b)
resource "aws_subnet" "database_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name        = "database-subnet-2"
    Environment = var.environment
    Tier        = "Database"
  }
}



