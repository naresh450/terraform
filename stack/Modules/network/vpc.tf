resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"

  tags = {
    Name        = "${var.proj}-VPC"
    Application = "${var.application}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.proj}-IGW"
    Application = "${var.application}"
  }
}

### Peering connection
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = "${aws_vpc.main.id}"
  peer_vpc_id   = "vpc-4271752b"
  peer_owner_id = "${data.aws_caller_identity.peer.account_id}"
  peer_region   = "us-east-2"
  auto_accept   = true

  tags = {
    Name = "Default-to-Student-"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id    = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name        = "${var.proj}-Public-RT"
    Application = "${var.application}"
  }
}

resource "aws_route_table" "priv-rt" {
  vpc_id    = "${aws_vpc.main.id}"

  tags = {
    Name        = "${var.proj}-Private-RT"
    Application = "${var.application}"
  }
}

resource "aws_subnet" "public" {
    count       = "${length(var.pub-subnets)}"
    vpc_id      = "${aws_vpc.main.id}"
    cidr_block  = "${element(var.pub-subnets, count.index)}"
    availability_zone = "${data.aws_availability_zones.az.names[count.index]}"
  tags = {
    Name        = "Subnet-Public-${var.proj}-${element(var.az-single-char, count.index)}"
    Application = "${var.application}"
  }
}

resource "aws_subnet" "private" {
    count       = "${length(var.priv-subnets)}"
    vpc_id      = "${aws_vpc.main.id}"
    cidr_block  = "${element(var.priv-subnets, count.index)}"
    availability_zone = "${data.aws_availability_zones.az.names[count.index]}"
  tags = {
    Name        = "Subnet-Private-${var.proj}-${element(var.az-single-char, count.index)}"
    Application = "${var.application}"
  }
}

resource "aws_route_table_association" "pub-rta" {
    count           = "${length(var.pub-subnets)}"
    subnet_id       = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id  = "${aws_route_table.pub-rt.id}"
}

resource "aws_route_table_association" "priv-rta" {
    count           = "${length(var.priv-subnets)}"
    subnet_id       = "${element(aws_subnet.private.*.id, count.index)}"
    route_table_id  = "${aws_route_table.priv-rt.id}"
}