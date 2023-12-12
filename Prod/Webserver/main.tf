terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "acs730-group6-s3bucket1"          
    key    = "prod/network/terraform.tfstate"
    region = "us-east-1"                 
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_key_pair" "shh_key" {
  key_name   = "projectkey"
  public_key = file ("projectkey.pub") 
}

resource "aws_instance" "publicinstance" {
  count                  = 1
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = lookup(var.instance_type, var.env)
  key_name               = aws_key_pair.shh_key.key_name
  security_groups        = [aws_security_group.publicsg.id]
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  associate_public_ip_address = true  
  user_data  = file("${path.module}/install_httpd.sh")
  root_block_device {
   encrypted = var.env == "prod" ? true : false
  }
  lifecycle {
  create_before_destroy = true
  }  
  tags    = merge(
    var.default_tags,{
    Name = "${var.prefix}-${var.env}-pulbic-${count.index + 1}"   
    }
  )
}

resource "aws_instance" "bastion" {
  count                  = 1
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = lookup(var.instance_type, var.env)
  key_name               = aws_key_pair.shh_key.key_name
  security_groups        = [aws_security_group.bastionsg.id]
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnet_ids[1]
  associate_public_ip_address = true   
  user_data  = file("${path.module}/install_httpd.sh")
  root_block_device {
   encrypted = var.env == "prod" ? true : false
   }
  lifecycle {
  create_before_destroy = true
  }  
  tags    = merge(
    var.default_tags,{
    Name = "${var.prefix}-${var.env}-public-bastion-${count.index + 2}"
    }
  )
}

resource "aws_instance" "ansibleinstance" {
  count                  = 2
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = lookup(var.instance_type, var.env)
  key_name               = aws_key_pair.shh_key.key_name
  security_groups        = [aws_security_group.publicsg.id]
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnet_ids[count.index + 2]
  associate_public_ip_address = true  
  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }
  lifecycle {
    create_before_destroy = true
  }  
  tags    = merge(
    var.ansible_tags,{
    Name = "${var.prefix}-${var.env}-public-ansible-${count.index + 3}"
    }
  )
}

resource "aws_instance" "privateinstance" {
  count                  = 2
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = lookup(var.instance_type, var.env)
  key_name               = aws_key_pair.shh_key.key_name
  security_groups        = [aws_security_group.privatesg.id]
  subnet_id              = data.terraform_remote_state.network.outputs.private_subnet_ids[count.index]
  associate_public_ip_address = false
  root_block_device {
   encrypted = var.env == "prod" ? true : false
  }
  lifecycle {
    create_before_destroy = true
  }  
  tags   = merge(
    var.default_tags,{
    Name = "${var.prefix}-${var.env}-private-${count.index +1}"
    }
  )
}

resource "aws_security_group" "publicsg" {
  name        = "allow_http_ssh_public"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id 
  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "bastionsg" {
  name        = "allow_http_ssh_bastion"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id 
  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "privatesg" {
  name        = "allow_http_ssh_private"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id 
 ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = ["${aws_security_group.bastionsg.id}"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}