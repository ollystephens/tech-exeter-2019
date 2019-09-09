resource "aws_vpc" "my-vpc" {
  cidr_block         = "10.10.0.0/16"
  tags = {
    "Name" = "my-special-vpc"
    "cost_code" = "123"
  }
}

resource "aws_internet_gateway" "my-vpc-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "my-special-vpc-internet-gw"
  }
}

resource "aws_instance" "micros" {
  count = 12
  ami = "abc123"
  instance_type = "t2.micro"
  tags = {
    "cost_code" = "123"
  }
}
