output "ec2_ssh_pub_key"{
    value = var.ec2_ssh_pub_key
}
output "vault_enterprise_license"{
    value = var.vault_enterprise_license
}
output "vault_version"{
    value = var.vault_version
}
output "vault_cluster_instance_type"{
    value = var.vault_cluster_instance_type
}
output "vault_cluster_min_size"{
    value = var.vault_cluster_min_size
}
output "vault_cluster_max_size"{
    value = var.vault_cluster_max_size
}
output "vault_cluster_desired_capacity"{
    value = var.vault_cluster_desired_capacity
}
output "name_prefix"{
    value = var.name_prefix
}

output "region"{
    value = var.region
}
output "asg_arn"{
    value = aws_autoscaling_group.vault.arn
  
}
output "asg_name" {
  value = aws_autoscaling_group.vault.name
}