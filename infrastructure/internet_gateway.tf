resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "credit-card-igw"
        Environment = var.environment
    }
}