data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
}
resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
}
resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
}
resource "aws_subnet" "private_3" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_3_cidr
  availability_zone = data.aws_availability_zones.available.names[2]
}
resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
}
resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
}
resource "aws_subnet" "public_3" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_3_cidr
  availability_zone = data.aws_availability_zones.available.names[2]
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}
resource "aws_eip" "natgw" {
  vpc = true
}
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw.id
  subnet_id = aws_subnet.public_1.id
  depends_on = [ 
    aws_internet_gateway.igw
   ]
}
resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table" "rt-private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
}
resource "aws_route_table_association" "private_1" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.rt-private.id
}
resource "aws_route_table_association" "private_2" {
  subnet_id = aws_subnet.private_2.id
  route_table_id = aws_route_table.rt-private.id
}
resource "aws_route_table_association" "private_3" {
  subnet_id = aws_subnet.private_3.id
  route_table_id = aws_route_table.rt-private.id
}
resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.rt-public.id
}
resource "aws_route_table_association" "public_2" {
  subnet_id = aws_subnet.public_2.id
  route_table_id = aws_route_table.rt-public.id
}
resource "aws_route_table_association" "public_3" {
  subnet_id = aws_subnet.public_3.id
  route_table_id = aws_route_table.rt-public.id
}