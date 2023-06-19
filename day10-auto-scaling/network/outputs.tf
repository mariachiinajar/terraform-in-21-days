output "vpc_id" {
    value = aws_vpc.terraform21.id
}

output "public_subnet_id" {
    value = aws_subnet.tf-public-sn[*].id
}

output "private_subnet_id" {
    value = aws_subnet.tf-private-sn[*].id
}

output "vpc_cidr" {
    value = var.vpc_cidr
}

