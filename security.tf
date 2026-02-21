resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "local" {
  key_name   = "terraform-test"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

resource "local_file" "tf_private_key" {
  content  = tls_private_key.rsa-4096.private_key_pem
  filename = "${path.root}/keys/rsa-4096.pem"
  file_permission = "0600"
}

resource "local_file" "tf_public_key" {
  content  = tls_private_key.rsa-4096.public_key_openssh
  filename = "${path.root}/keys/rsa-4096.pub"
  file_permission = "0644"
}