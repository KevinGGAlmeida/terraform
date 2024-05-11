locals {
    common_tags = {
        "Teams" = "Devops"
        "Scope" = "Infraestrutura"
        "CC" = "11502"
    }
}

#Criando VPC
resource "aws_vpc" "vpc_kevin-clc11" {
  cidr_block       = var.range
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}


#Criando pública Subnet 1a
resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.vpc_kevin-clc11.id
  cidr_block        = var.public_subnet_1a_range
  availability_zone = "us-east-1a"


  tags = {
    Name = "iac-public_subnet-1a"
  }
}

#Criando privada subnet 1c
resource "aws_subnet" "private_subnet_1a" {
  vpc_id            = aws_vpc.vpc_kevin-clc11.id
  cidr_block        = var.private_subnet_1a_range
  availability_zone = "us-east-1a"

  tags = {
    Name = "iac-private_subnet-1a"
  }
}


#Criando pública Subnet 1c
resource "aws_subnet" "public_subnet_1c" {
  vpc_id            = aws_vpc.vpc_kevin-clc11.id
  cidr_block        = var.public_subnet_1c_range
  availability_zone = "us-east-1c"

  tags = {
    Name = "iac-public_subnet-1c"
  }
}


#Criando privada Subnet 1c
resource "aws_subnet" "private_subnet_1c" {
  vpc_id            = aws_vpc.vpc_kevin-clc11.id
  cidr_block        = var.private_subnet_1c_range
  availability_zone = "us-east-1c"

  tags = {
    Name = "iac-private_subnet-1c"
  }
}

#Criando internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_kevin-clc11.id

  tags = {
    Name = "igw-vpc-iac-clc11"
  }
}

#Criando route table Pública
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_kevin-clc11.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_iac_rt"
  }
}

#Associando route table à subnet publica 1-a
resource "aws_route_table_association" "public-1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

#Associando route table à subnet publica 1-c
resource "aws_route_table_association" "public-1c" {
  subnet_id      = aws_subnet.public_subnet_1c.id
  route_table_id = aws_route_table.public_rt.id
}


#Criando Elastic IP (EIP)
resource "aws_eip" "ip_nat_1a" {
  domain           = "vpc"
}

resource "aws_eip" "ip_nat_1c" {
  domain           = "vpc"
}

#Criando NAT GATEWAY -1a
resource "aws_nat_gateway" "natgateway_1a" {
  allocation_id = aws_eip.ip_nat_1a.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = {
    Name = "iac-natgateway-1a"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
}

#Criando NAT GATEWAY -1c
resource "aws_nat_gateway" "natgateway_1c" {
  allocation_id = aws_eip.ip_nat_1c.id
  subnet_id     = aws_subnet.public_subnet_1c.id

  tags = {
    Name = "iac-natgateway-1c"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
}




#Criando route table privada 1-a
resource "aws_route_table" "private_rt_1a" {
  vpc_id = aws_vpc.vpc_kevin-clc11.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_1a.id
  }
    tags = {
    Name = "private-rt-1a"
  }

}
 

#Criando route table privada 1-c
resource "aws_route_table" "private_rt_1c" {
  vpc_id = aws_vpc.vpc_kevin-clc11.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_1c.id
  }
  tags = {
    Name = "private-rt-1c"
  }
}


resource "aws_route_table_association" "private-1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_rt_1a.id
}

resource "aws_route_table_association" "private-1c" {
  subnet_id      = aws_subnet.private_subnet_1c.id
  route_table_id = aws_route_table.private_rt_1c.id
}