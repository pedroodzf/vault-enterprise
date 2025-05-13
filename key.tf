locals {
  private_key_exists = fileexists("${path.module}/../${var.ec2_ssh_pub_key}.pem")
}

data "aws_key_pair" "pk" {
    count      = local.private_key_exists ? 1 : 0
    key_name   = var.ec2_ssh_pub_key
}

resource "tls_private_key" "pk" {
    count      = local.private_key_exists ? 0 : 1
    algorithm = "RSA"
    rsa_bits  = 4096
}
resource "aws_key_pair" "kp" {
    count      = local.private_key_exists ? 0 : 1
    key_name   = var.ec2_ssh_pub_key # Create a "myKey" to AWS!!
    public_key = tls_private_key.pk[0].public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
command = <<EOT
  echo '${tls_private_key.pk[0].private_key_pem}' > ./${var.ec2_ssh_pub_key}.pem
EOT  
}
}

