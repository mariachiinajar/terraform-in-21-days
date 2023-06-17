resource "aws_vpc" "terraform21" {
  cidr_bloc = var.vpc_cidr

  tags = {
    Name = "terraform21-${var.progress}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "tf-public-sn" {
  count = length(var.public_subnet_cidr)

  vpc_id            = aws_vpc.terraform21.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "tf-public-sn-${var.public_subnet_cidr[count.index]}-${var.progress}"
  }
}

resource "aws_subnet" "tf-private-sn" {
  count = length(var.private_subnet_cidr)

  vpc_id            = aws_vpc.terraform21.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "tf-private-sn-${var.private_subnet_cidr[count.index]}-${var.progress}"
  }
}

resource "aws_internet_gateway" "tf-igw" {
  vpc_id = aws_vpc.terraform21.id

  tags = {
    Name = "tf-igw"
  }
}

resource "aws_eip" "tf-nat" {
  count = length(var.private_subnet_cidr)

  vpc = true
  tags = {
    Name = "tf-nat-${count.index}-${var.progress}"
  }
}

resource "aws_nat_gateway" "tf-nat-gw" {
  count = length(var.public_subnet_cidr)

  allocation_id = aws_eip.tf-nat[count.index].id
  subnet_id     = aws_subnet.tf-public-sn[count.index].id

  tags = {
    Name = "tf-nat-gw-${count.index}-${var.progress}"
  }
}

resource "aws_route_table" "tf-public-rt" {
  vpc_id = aws_vpc.terraform21.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-igw.id
  }
  tags = {
    Name = "tf-public-rt-${var.progress}"
  }
}

resource "aws_route_table" "tf-private-rt" {
  count = length(var.private_subnet_cidr)

  vpc_id = aws_vpc.terraform21.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tf-nat-gw[count.index].id
  }

  tags = {
    Name = "tf-private-rt-${var.progress}"
  }
}

resource "aws_route_table_association" "tf-public-rta" {
  count = length(var.public_subnet_cidr)

  subnet_id      = aws_subnet.tf-public-sn[count.index].id
  route_table_id = aws_route_table.tf-public-rt.id
}

resource "aws_route_table_association" "tf-private-rta" {
  count = length(var.private_subnet_cidr)

  subnet_id      = aws_subnet.tf-private-sn[count.index].id
  route_table_id = aws_route_table.tf-private-rt[count.index].id
}

output "subnet-count" {
  value = length(var.public_subnet_cidr)
}

