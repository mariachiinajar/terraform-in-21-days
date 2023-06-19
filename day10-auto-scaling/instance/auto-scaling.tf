resource "aws_launch_configuration" "tf-launch-config" {
  name_prefix     = "${var.env_code}-${var.progress}"
  image_id        = data.aws_ami.amazonlinux.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.tf-private-sg.id]
  user_data       = file("user-data.sh")
  key_name        = "terraform"
}

resource "aws_autoscaling_group" "tf-asg" {
  name             = var.env_code
  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  # point autoscaling groups to our target group.
  # so that every time a new instance is created, 
  # it is added to the target group automatically. 
  target_group_arns    = [aws_lb_target_group.tf-load-balancer-tg.arn]
  launch_configuration = aws_launch_configuration.tf-launch-config.name
  # list of subnets wherein the ASGs run.
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.private_subnet_id

  # With this tag, we are not tagging the ASG but the instances that are created by the ASG.
  tag {
    key                 = "Name"
    value               = var.env_code
    propagate_at_launch = true
  }
}