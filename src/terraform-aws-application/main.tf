# Retrieve current VPC
data "aws_vpc" "test_vpc" {
  id = var.vpc_id
}

# Retrieve IDs from all subnets in current VPC 
data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.test_vpc.id]
  }
}

# Create a new Security Group in the current VPC
resource "aws_security_group" "test_security_group" {
  # name      = "" # Random name
  vpc_id      = data.aws_vpc.test_vpc.id

  egress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    self            = true
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    self            = true
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Create the Elastic Load Balancer
resource "aws_lb" "test_app_lb" {
  # name             = "" # Random name
  internal           = var.lb_is_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_security_group.id]
  subnets            = data.aws_subnets.vpc_subnets.ids

  tags = var.tags
}

# Create 
resource "aws_lb_target_group" "test_lb_target_group" {
  # name                             = "" # Random name
  port                               = 80
  protocol                           = "HTTP"
  vpc_id                             = data.aws_vpc.test_vpc.id
  target_type                        = "instance"
  deregistration_delay               = var.lb_deregistration_delay

  tags = var.tags
}

# Create a Load Balancer Listener for https requests
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.test_app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.lb_ssl_policy
  certificate_arn   = var.lb_certificate_arn
  default_action {
    target_group_arn = aws_lb_target_group.test_lb_target_group.arn
    type             = "forward"
  }

  tags = var.tags
}

# Create a Load Balancer Listener for http requests
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.test_app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  
  tags = var.tags
}

# Retrieve SSM IAM Policy
data "aws_iam_policy" "ssm_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create IAM Role
resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"
  description = "Allows to use AWS Systems Manager service core functionality."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

# Attach SSM Policy to Role
resource "aws_iam_role_policy_attachment" "role_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = data.aws_iam_policy.ssm_policy.arn
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "iam_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

# Create a template with the cloudinit script
data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    #!/bin/bash
    curl -o /usr/local/bin/testapp-autoupdater -u ${var.autoupdater_server_username}:${var.autoupdater_server_pass} https://server.com/testapp-autoupdater
    chmod +x /usr/local/bin/testapp-autoupdater
    echo Hello
    EOF
  }
}

# Create a Launch Template for the EC2 instances
resource "aws_launch_template" "test_launch_template" {
  # name                 = "" # Random name
  image_id               = var.ami_id
  instance_type          = var.ec2_instance_type
  user_data              = data.template_cloudinit_config.config.rendered

  credit_specification {
    cpu_credits = "unlimited"
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.iam_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.test_security_group.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }
  
  tags = var.tags
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "test_asg" {
  vpc_zone_identifier = data.aws_subnets.vpc_subnets.ids
  desired_capacity    = var.asg_desired != 0 ? var.asg_desired : var.asg_min
  max_size            = var.asg_max
  min_size            = var.asg_min
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.test_launch_template.id
    version = aws_launch_template.test_launch_template.latest_version
  }

  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns
    ]
  }
}

# Create Auto Scaling Policy
resource "aws_autoscaling_policy" "asg_policy" {
  name                   = "asg_cpu_policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.test_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.asg_policy_target
  }
}

# Attach Auto Scaling Group to the Load Balancer Target Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.test_asg.id
  alb_target_group_arn   = aws_lb_target_group.test_lb_target_group.arn
}
