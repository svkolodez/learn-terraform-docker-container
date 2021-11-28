variable "whitelist" {
  type = list(string)
  default = ["0.0.0.0/0"]
}
variable "nginx_image_id" {
  type = string
  default = "ami-01b9dc827d1e2d177"
}
variable "web_instance_type" {
  type = string
  default = "t2.nano"
}

provider "aws" {
  profile = "default"
  region = "eu-central-1"
}

resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "svkolodez-tf-course-20211126"
  acl    = "private"
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "eu-central-1a"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "eu-central-1b"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.whitelist
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = var.whitelist
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" : "true"
  }
}

module "web_app" {
  source = "./modules/web_app"

  whitelist            = var.whitelist
  web_image_id         = var.nginx_image_id
  web_instance_type    = "t2.micro"
  web_desired_capacity = 2
  web_max_size         = 2
  web_min_size         = 1
  subnets              = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  security_groups      = [aws_default_security_group.default.id]
  web_app              = "prod"
}
