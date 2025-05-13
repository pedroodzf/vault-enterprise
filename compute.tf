resource "aws_launch_template" "vault" {
  name_prefix   = var.name_prefix
  key_name      = var.ec2_ssh_pub_key
  image_id      = data.aws_ami.ubuntu-ami.id
  instance_type = var.vault_cluster_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.vault_instance_profile.name
  }

  user_data = base64encode(templatefile("utils/userdata.sh.tftpl", {
    vault_version   = var.vault_version,
    vault_license   = var.vault_enterprise_license,
    vault_service   = filebase64("${path.module}/utils/vault.service"),
    cert_gen_script = filebase64("${path.module}/utils/cert-gen.sh"),
    ca_cert         = filebase64("${path.module}/utils/vault-ca/vault-ca.pem"),
    ca_key          = filebase64("${path.module}/utils/vault-ca/vault-ca.key")
  }))

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 30
    }
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.vault_sg.id]
  }

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.name_prefix
    }
  }

}
data "aws_ami" "ubuntu-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}


resource "aws_autoscaling_group" "vault" {

  name                = "${var.name_prefix}-asg-1"
  min_size            = var.vault_cluster_min_size
  max_size            = var.vault_cluster_max_size
  desired_capacity    = var.vault_cluster_desired_capacity
  vpc_zone_identifier = [aws_subnet.vault_subnet[0].id, aws_subnet.vault_subnet[1].id, aws_subnet.vault_subnet[2].id]

  launch_template {
    id      = aws_launch_template.vault.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-1"
    propagate_at_launch = true
  }

  termination_policies = ["OldestLaunchTemplate"]
}

# Fetch all instances created by the ASG using the tag applied during launch
data "aws_instances" "vault_nodes" {
  instance_tags = {
    Name = "${var.name_prefix}-*"
  }
}

