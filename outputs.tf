output "instance-ip" {
  value = aws_instance.my-machine.public_ip
}

output "private-key-path" {
  value = local_file.tf_private_key.filename
}
