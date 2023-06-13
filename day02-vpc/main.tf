resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "terraform21"
    }
}

resource "aws_subnet" "public-0" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "public-0"
    }
}

resource "aws_subnet" "public-1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "public-1"
     }
}

resource "aws_subnet" "private-2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "private-2"
     }
}

resource "aws_subnet" "private-3" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "private-3"
     }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    
    tags = {
        Name = "main"
    }
}

resource "aws_eip" "nat0" {
    vpc = true

    tags = {
        Name = "nat0"
    }
}

resource "aws_eip" "nat1" {
    vpc = true

    tags = {
        Name = "nat1"
    }
}

resource "aws_nat_gateway" "main0" {
    allocation_id = aws_eip.nat0.id
    subnet_id = aws_subnet.public-0.id

    tags = {
        Name = "main0"
    }
}

resource "aws_nat_gateway" "main1" {
    allocation_id = aws_eip.nat1.id
    subnet_id = aws_subnet.public-1.id

    tags = {
        Name = "main1"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "public"
    }
}

resource "aws_route_table" "private0" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.main0.id
    }

    tags = {
        Name = "private0"
    }
}

resource "aws_route_table" "private1" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.main1.id
    }

    tags = {
        Name = "private1"
    }
}

resource "aws_route_table_association" "public0" {
    subnet_id = aws_subnet.public-0.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public1" {
    subnet_id = aws_subnet.public-1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private2" {
    subnet_id = aws_subnet.private-2.id
    route_table_id = aws_route_table.private0.id
}

resource "aws_route_table_association" "private3" {
    subnet_id = aws_subnet.private-3.id
    route_table_id = aws_route_table.private1.id
}
