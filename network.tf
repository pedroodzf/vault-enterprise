
resource "aws_vpc" "vault_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VaultVPC"
  }
}

resource "aws_subnet" "vault_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.vault_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2${element(["a", "b", "c"], count.index)}"
  tags = {
    Name = "VaultSubnet-${count.index}"
  }
}

resource "aws_internet_gateway" "vault_igw" {
  vpc_id = aws_vpc.vault_vpc.id
  tags = {
    Name = "VaultIGW"
  }
}

resource "aws_route_table" "vault_rt" {
  vpc_id = aws_vpc.vault_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vault_igw.id
  }

  tags = {
    Name = "VaultRouteTable"
  }
}

resource "aws_route_table_association" "vault_rta" {
  count          = 3
  subnet_id      = aws_subnet.vault_subnet[count.index].id
  route_table_id = aws_route_table.vault_rt.id
}

resource "aws_lb_target_group" "vault_tg" {
  name                 = "vault-cluster-1-tg"
  port                 = 8200
  protocol             = "TCP"
  vpc_id               = aws_vpc.vault_vpc.id
  deregistration_delay = 60

  health_check {
    protocol            = "HTTPS"
    path                = "/v1/sys/health?perfstandbyok=true"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
    matcher             = "200"
  }
}

resource "aws_lb" "vault_nlb" {
  name               = "vault-cluster-1-nlb"
  load_balancer_type = "network"
  subnets            = aws_subnet.vault_subnet[*].id
  security_groups    = [aws_security_group.vault_sg.id]

  enable_deletion_protection = false

  tags = {
    Name = "VaultNLB"
  }
}

resource "aws_lb_listener" "vault_listener" {
  load_balancer_arn = aws_lb.vault_nlb.arn
  port              = 8200
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault_tg.arn
  }
}

resource "aws_autoscaling_attachment" "vault_asg_attachment" {
  autoscaling_group_name = "vault-cluster-asg-1"
  lb_target_group_arn    = aws_lb_target_group.vault_tg.arn

  depends_on = [aws_autoscaling_group.vault]
}
