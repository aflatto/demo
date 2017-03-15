provider "aws" {
  access_key = ""
  secret_key = "f"
  region     = ""
}

resource "aws_security_group" "icinga" {
  name        = "Icinga security Group"
  description = "Used in the Icina Demo"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server" {
  ami           = "ami-d2c924b2"
  instance_type = "t2.micro"
  key_name =  ""
  vpc_security_group_ids = ["${aws_security_group.icinga.id}"]
  tags {
      Name = "icinga-server"
  }
}

resource "aws_security_group" "nodes" {
  name        = "Remote nodes security Group"
  description = "Used in the Icina Demo"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # All traffic from icinga server
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    security_groups = ["${aws_security_group.icinga.id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "node1" {
  ami           = "ami-d2c924b2"
  instance_type = "t2.micro"
  key_name =  ""
  vpc_security_group_ids = ["${aws_security_group.nodes.id}"]
  tags {
      Name = "node1"
  }
}

resource "aws_instance" "node2" {
ami           = "ami-d2c924b2"
  instance_type = "t2.micro"
  key_name =  ""
  vpc_security_group_ids = ["${aws_security_group.nodes.id}"]
  tags {
      Name = "node2"
  }
}
