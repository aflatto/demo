variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGIONY" {}
variable "SSH_KEY_NAME" {}
variable "SSH_PRIVATE_KEY" {}


provider "aws" {
  region = "${var.AWS_REGION}"
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
}

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "CENTOS 7 HVM *",
    ]
  }

  filter {
      name   = "architecture"
      values = ["x86_64"]
    }
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

resource "null_resource" "inventory" {
  provisioner "local-exec" {
       command = "echo [monitoring_servers] > Hosts"
    }
}

resource "aws_instance" "server" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "t2.micro"
  key_name =  "${var.SSH_KEY_NAME}"
  vpc_security_group_ids = ["${aws_security_group.icinga.id}"]
  tags {
      Name = "icinga-server"
  }
  provisioner "local-exec" {
       command = "echo ${aws_instance.server.public_ip} >> Hosts"
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
  provisioner "local-exec" {
       command = "echo [webservers] >> Hosts"
    }
  depends_on = ["aws_instance.server"]
}

resource "aws_instance" "node1" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "t2.micro"
  key_name =  "${var.SSH_KEY_NAME}"
  vpc_security_group_ids = ["${aws_security_group.nodes.id}"]
  tags {
      Name = "node1"
  }
  provisioner "local-exec" {
       command = "echo ${aws_instance.node1.public_ip} >>  Hosts"
    }
}

resource "aws_instance" "node2" {
ami           = "${data.aws_ami.centos.id}"
  instance_type = "t2.micro"
  key_name =  "${var.SSH_KEY_NAME}"
  vpc_security_group_ids = ["${aws_security_group.nodes.id}"]
  tags {
      Name = "node2"
  }
  provisioner "local-exec" {
       command = "echo ${aws_instance.node2.public_ip} >>  Hosts"
    }

  provisioner "local-exec" {
    command = "ansible-playbook -i Hosts -u centos -b --private-key=${var.SSH_PRIVATE_KEY} site.yml"
  }
}