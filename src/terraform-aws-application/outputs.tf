output "load_balancer_dns_name" {
  value = aws_lb.test_app_lb.dns_name
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.test_asg.name
}