data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_security_group" "tf-public-sg" {
  name        = "tf-public-sg-${var.progress}"
  description = "allows public traffic"
  vpc_id      = data.terraform_remote_state.level1-network.outputs.vpc_id

  ingress {
    description = "SSH from home office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP_ADDRESS/32"]
  }

  ingress {
    description = "HTTP from home office"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP_ADDRESS/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-public-sg-${var.progress}"
  }
}

resource "aws_security_group" "tf-private-sg" {
  name        = "tf-private-sg-${var.progress}"
  description = "allows private traffic"
  vpc_id      = data.terraform_remote_state.level1-network.outputs.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.level1-network.outputs.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-private-sg-${var.progress}"
  }
}

resource "aws_instance" "tf-public-instance" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.terraform_remote_state.level1-network.outputs.public_subnet_id[0]
  vpc_security_group_ids      = [aws_security_group.tf-public-sg.id]
  key_name                    = "terraform"
  associate_public_ip_address = true
  user_data                   = file("user-data.sh")

  tags = {
    Name = "tf-public-instance-${var.progress}"
  }
}

resource "aws_instance" "tf-private-instance" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t3.micro"
  subnet_id              = data.terraform_remote_state.level1-network.outputs.private_subnet_id[0]
  vpc_security_group_ids = [aws_security_group.tf-private-sg.id]
  key_name               = "terraform"

  tags = {
    Name = "tf-private-instance-${var.progress}"
  }
}

output "public_ip_address" {
  value = aws_instance.tf-public-instance.public_ip
}

