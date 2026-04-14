resource "aws_instance" "myserver" {
    ami = "ami-0ea87431b78a82070"
    instance_type = "t3.nano"

    subnet_id = aws_subnet.public_subnet.id

    tags = {
      Name = "myserver"
    }
}


