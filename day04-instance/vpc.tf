resource "aws_vpc" "terraform21" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "terraform21"
  }
}

resource "aws_subnet" "tf-public" {
  count = length(var.public_subnet_cidr)

  vpc_id            = aws_vpc.terraform21.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "tf-public-${var.availability_zone[count.index]}"
  }
}

resource "aws_subnet" "tf-private" {
  count = length(var.private_subnet_cidr)

  vpc_id            = aws_vpc.terraform21.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "tf-private-${var.availability_zone[count.index]}"
  }
}

resource "aws_internet_gateway" "tf-ig" {
  vpc_id = aws_vpc.terraform21.id

  tags = {
    Name = "tf-ig"
  }
}

resource "aws_eip" "tf-nat" {
  count = length(var.private_subnet_cidr)

  vpc = true
  tags = {
    Name = "tf-nat-${count.index}"
  }
}

resource "aws_nat_gateway" "tf-nat-g" {
  count = length(var.public_subnet_cidr)

  allocation_id = aws_eip.tf-nat[count.index].id
  subnet_id     = aws_subnet.tf-public[count.index].id

  tags = {
    Name = "tf-nat-g-{count.index}"
  }
}


resource "aws_route_table" "tf-public-rt" {
  vpc_id = aws_vpc.terraform21.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig.id
  }

  tags = {
    Name = "tf-public-rt"
  }
}

resource "aws_route_table" "tf-private-rt" {
  count = length(var.private_subnet_cidr)

  vpc_id = aws_vpc.terraform21.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tf-nat-g[count.index].id
  }

  tags = {
    Name = "tf-private-rt"
  }
}

resource "aws_route_table_association" "tf-public-rta" {
  count = length(var.public_subnet_cidr)

  subnet_id      = aws_subnet.tf-public[count.index].id
  route_table_id = aws_route_table.tf-public-rt.id
}

resource "aws_route_table_association" "tf-private-rta" {
  count = length(var.private_subnet_cidr)

  subnet_id      = aws_subnet.tf-private[count.index].id
  route_table_id = aws_route_table.tf-private-rt[count.index].id
}

output "subnet-count" {
  value = length(var.public_subnet_cidr)
}

