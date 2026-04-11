# ===== ELASTIC IP (for NAT Gateway) =====

resource "aws_eip" "nat" {
    domain = "vpc"

    tags= {
        Name = "nat-eip",
        Environment = var.environment
    }

    depends_on = [ aws_internet_gateway.main ]
  
}

# ===== NAT GATEWAY =====

resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public_subnet_1.id

    tags = {
        Name = "nat-gatewqay",
        Environment = var.environment
    }

    depends_on = [aws_internet_gateway.main]
}

# ===== PUBLIC ROUTE TABLE =====

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
       Name        = "public-rt"
       Environment = var.environment
       Tier        = "Public"
    }
}

# Associate Public Subnets to Public Route Table

resource "aws_route_table_association" "public_1" {
    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

# ===== PRIVATE ROUTE TABLE =====

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main.id
    }
    tags = {
    Name        = "private-rt"
    Environment = var.environment
    Tier        = "Private"
  }
  
}

# Associate private Subnets to private Route Table

resource "aws_route_table_association" "private_1" {
    subnet_id = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
    subnet_id = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.private.id
}

# ===== DATABASE ROUTE TABLE =====

resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id

    tags = {
    Name        = "database-rt"
    Environment = var.environment
    Tier        = "Database"
  }
  
}

# Associate Database Subnets to Database Route Table
resource "aws_route_table_association" "database_1" {
  subnet_id      = aws_subnet.database_subnet_1.id
  route_table_id = aws_route_table.database.id
}

resource "aws_route_table_association" "database_2" {
  subnet_id      = aws_subnet.database_subnet_2.id
  route_table_id = aws_route_table.database.id
}






