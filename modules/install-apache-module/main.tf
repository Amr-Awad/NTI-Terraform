# install apache on private instances through bastion host that is public instance
# update the index.html file with the instance ip
resource "null_resource" "install_apache" {
  for_each = { for idx, ip in var.private-instance-ips : idx => ip }

  connection {
    type        = "ssh"
    host        = each.value
    user        = "ec2-user"
    private_key = var.ec2-private-key
    bastion_host = var.public-instance-ips[0]
    bastion_user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "echo '<h1>Welcome to private instance ${each.value}</h1>' | sudo tee /var/www/html/index.html"
    ]
  }
  depends_on = [var.private-ec2-instance-ids, var.public-ec2-instance-ids]
}

resource "null_resource" "print_public_ip" {
  provisioner "local-exec" {
    command = <<EOT
      echo "public instance 1 IP: ${var.public-instance-ips[0]}" >> ip.txt
      echo "public instance 2 IP: ${var.public-instance-ips[1]}" >> ip.txt
    EOT
  }
  depends_on = [var.public-ec2-instance-ids, var.private-ec2-instance-ids]
}

resource "null_resource" "print_private_ip" {
  provisioner "local-exec" {
    command = <<EOT
      echo "private instance 1 IP: ${var.private-instance-ips[0]}" >> ip.txt
      echo "private instance 2 IP: ${var.private-instance-ips[1]}" >> ip.txt
    EOT
  }
  depends_on = [var.private-ec2-instance-ids, var.public-ec2-instance-ids]
}

