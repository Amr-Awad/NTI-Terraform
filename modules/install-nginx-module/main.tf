# install reverse proxy nginx on public instances to forward requests to private load balancer dns that is passed as variable
# install apache on private instances through bastion host that is public instance
resource "null_resource" "install_nginx" {
   for_each = { for idx, ip in var.public-instance-ips : idx => ip }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.ec2-private-key
    host        = each.value
    
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "echo 'server { listen 80; location / { proxy_pass http://${var.private-lb-dns}; } }' | sudo tee /etc/nginx/sites-available/default",
      "sudo systemctl restart nginx"
    ]
  }
  #depends on the 4 ec2 instances and the 2 alb not modules
  depends_on = [var.public-ec2-instance-ids, var.private-ec2-instance-ids, var.lb-ids]
}