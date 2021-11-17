# Global variables
variable "aws_region" {
  description = "AWS Region to store tfstate"
  type        = string
}

variable "vpc_id" {
  description = "The id of the specific VPC to retrieve."
  type        = string
  default     = "vpc-12345"
}

variable "ami_id" {
  description = "The ID of the AMI to be used in EC2 instances."
  type        = string
  default     = "i-1234567890"
}

variable "tags" {
  description = "Custom tags to be added to the created resources."
  type        = map
  default     = {
    Application = "testapp-autoupdater"
    Environment = "Production"
  }
}

# Elastic Load Balancer variables
variable "lb_is_internal" {
  description = "If true, the LB will be internal."
  type        = bool
  default     = false
}

variable "lb_deregistration_delay" {
  description = "Amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused."
  type        = number
  default     = 300
}

variable "lb_ssl_policy" {
  description = "Name of the SSL Policy for the listener."
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "lb_certificate_arn" {
  description = "ARN of the default SSL server certificate."
  type        = string
  default     = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
}

# Launch Template variables
variable "ec2_instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.medium"
}

variable "autoupdater_server_username" {
  description = "Username used to download 'testapp-autoupdater' script."
  type        = string
  sensitive   = true
}

variable "autoupdater_server_pass" {
  description = "Password used to download 'testapp-autoupdater' script."
  type        = string
  sensitive   = true
}

# Auto Scaling Group variables
variable asg_min {
  description = "The minimum size of the Auto Scaling Group."
  type        = number
  default     = 3
}

variable asg_max {
  description = "The maximum size of the Auto Scaling Group."
  type        = number
  default     = 6
}

variable asg_desired {
  description = "The number of Amazon EC2 instances that should be running in the group."
  type        = number
  default     = 0
}

variable asg_policy_target {
  description = "The target value for the metric. If the current metric value is greater than the target, a new EC2 instance is created."
  type        = number
  default     = 40.0
}
