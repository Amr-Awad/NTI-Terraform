# Generate SSH Key Pair
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  filename        = "${var.key-name}.pem"
  content         = tls_private_key.my_key.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.key-name}"
  public_key = tls_private_key.my_key.public_key_openssh
}