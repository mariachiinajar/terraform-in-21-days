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

resource "aws_security_grou1p" "tf-public-sg" {
    name        = "tf-public-sg-${var.progress}"
    description = "allows public traffic"
    vpc_id      = aws_vpc.terraform21.id

    ingress {
        description = "SSH from home office"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = ["119.206.110.22/32"]
    }

    ingress {
        description = "HTTP from home office"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = ["119.206.110.22/32"]
    }

    egress {
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_block = ["0.0.0.0/0"]
    }

    tags = {
        Name = "tf-public-sg-${var.progress}"
    }
}

resource "aws_security_group" "tf-private-sg" {
    name        = "tf-private-sg-${var.progress}"
    description = "allows private traffic"
    vpc_id      = aws_vpc.terraform21.id

    ingress {
        description = "SSH from VPC"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr]
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
    subnet_id                   = aws_subnet.tf-public-sn[0].id
    vpc_security_group_ids      = [aws_security_group.aws_subnet.tf-public-sn.id]
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
    subnet_id              = aws_subnet.tf-private-sn[0].id
    vpc_security_group_ids = [aws_security_group.aws_subnet.tf-private-sn.id]
    key_name               = "terraform"

    tags = {
        Name = "tf-private-instance-${var.progress}"
    }
}

output "public_ip_address" {
    value = aws_instance.tf-public-instance.public_ip
}