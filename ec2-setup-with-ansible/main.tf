data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners = ["099720109477"] # Canonical
}

# terraform destroy -target aws_instance.my-machine
resource "aws_instance" "my-machine" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano"

  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.local.key_name

  tags = local.default-tags
}
