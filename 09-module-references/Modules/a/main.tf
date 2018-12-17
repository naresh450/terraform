variable "aws_vpc" {
    cidr_block = "10.5.0.0/22"
}

resource "aws_vpc" "main" {
  cidr_block       = "${var.aws}"
}