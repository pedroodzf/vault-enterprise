variable "ec2_ssh_pub_key" {
  type        = string
  description = "value of the public key to be used for SSH access to the EC2 instances"
}
variable "region" {
  type = string
  description = "AWS region to deploy the Vault cluster"
}

variable "vault_enterprise_license" {
  type        = string
  description = "Vault Enterprise license string"
}

variable "vault_version" {
  type        = string
  description = "Version of Vault Enterprise to install"

  validation {
    condition     = can(regex("^(?:\\d{1,2}\\.){2}\\d{1,2}\\+ent$", var.vault_version))
    error_message = "The Vault Enterprise version does not match the naming convention. Example version: \"1.15.6+ent\"."
  }
}

variable "vault_cluster_instance_type" {
  type        = string
  description = "Instance type to be used for Vault servers"

}

variable "vault_cluster_min_size" {
  type        = number
  description = "Minimum number of Vault servers in the cluster"
}

variable "vault_cluster_max_size" {
  type        = number
  description = "Maximum number of Vault servers in the cluster"
}

variable "vault_cluster_desired_capacity" {
  type        = number
  description = "Desired number of Vault servers in the cluster"
}

variable "name_prefix" {
  type        = string
  description = "Prefix to be used for naming resources"
}