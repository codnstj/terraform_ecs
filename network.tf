resource "aws_vpc" "ecs_vpc" {
  tags = {
    "Name" = "ecs_vpc"
  }
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "pub" {
  vpc_id = aws_vpc.ecs_vpc.id
  count = 2
  cidr_block = "10.30.${count.index}.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    "Name" = "ecs_subnet_${1 + count.index}"
  }
}

resource "aws_subnet" "priv" {
  vpc_id = aws_vpc.ecs_vpc.id
  count = 2
  cidr_block = "10.30.${10 + count.index}.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    "Name" = "ecs_subnet_${2 + count.index}"
  }
}
 resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id
  tags = {
    "Name" = "ecs_igw"
  }
}

resource "aws_eip" "eip_nat" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_nat_gateway" "ecs_ngw" {
  allocation_id = aws_eip.eip_nat.id
  connectivity_type = "private"
  subnet_id = element(aws_subnet.pub.*.id ,0)
}

resource "aws_route_table" "priv_route" {
  vpc_id = aws_vpc.ecs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ecs_ngw.id
  }
  tags = {
    "Name" = "priv_route_table"
  }  
}
resource "aws_default_route_table" "default_route" {
  default_route_table_id = "${aws_vpc.ecs_vpc.default_route_table_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }
}

resource "aws_route_table_association" "public_subnets_association" {
  count = length(aws_subnet.pub.*.id)
  subnet_id = element(aws_subnet.pub.*.id, count.index)
  route_table_id = aws_default_route_table.default_route.id
}

resource "aws_route_table_association" "private_subnets_association" {
  count = length(aws_subnet.priv.*.id)
  subnet_id = element(aws_subnet.priv.*.id, count.index)
  route_table_id = aws_route_table.priv_route.id
}
