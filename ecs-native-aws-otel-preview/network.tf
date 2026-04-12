resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  for_each       = aws_subnet.main
  subnet_id      = each.value.id
  route_table_id = aws_route_table.main.id
}

resource "aws_subnet" "main" {
  for_each = {
    for idx, az in data.aws_availability_zones.available.names :
    az => cidrsubnet(aws_vpc.main.cidr_block, 8, idx)
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "main" {
  name   = "allow_http"
  vpc_id = aws_vpc.main.id

  # Allow HTTP traffic to access app
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
