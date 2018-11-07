variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-west-2"
}
variable "name" {
  default = "vCommander - Terraform"
}

provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_instance" "example" {
  ami           = "ami-7172b611"
  instance_type = "t2.micro"
  subnet_id	= "subnet-5d6fbd04"
  tags {
    Name = "${var.name}"
  }
}
