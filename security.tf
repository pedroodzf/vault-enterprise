# IAM Role for EC2 instances
resource "aws_iam_role" "vault_ec2_role" {
  name = "vault_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# # IAM Policy to allow access to the KMS Key
# resource "aws_iam_policy" "vault_kms_policy" {
#   name        = "vault_kms_policy"
#   description = "Policy to allow Vault operations and EC2 instances discovery"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         Effect   = "Allow",
#         Resource = aws_kms_key.vault_unseal.arn
#       },
#       {
#         Action   = "ec2:DescribeInstances",
#         Effect   = "Allow",
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Attach the policy to the role
# resource "aws_iam_role_policy_attachment" "vault_kms_attach" {
#   role       = aws_iam_role.vault_ec2_role.name
#   policy_arn = aws_iam_policy.vault_kms_policy.arn
# }

# Instance Profile to attach the role to EC2 instances
resource "aws_iam_instance_profile" "vault_instance_profile" {
  name = "vault_instance_profile2"
  role = aws_iam_role.vault_ec2_role.name
}

resource "aws_security_group" "vault_sg" {
  name        = "vault-enterprise-sg"
  description = "Allow inbound web traffic and SSH for management"
  vpc_id      = aws_vpc.vault_vpc.id

  ingress {
    description      = "Inbound TLS from all"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Vault API"
    from_port        = 8200
    to_port          = 8200
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Raft, replication, request forwarding"
    from_port        = 8201
    to_port          = 8201
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Inbound SSH for management"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}