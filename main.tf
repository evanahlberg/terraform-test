provider "aws" {
  region     = var.region
}

resource "aws_instance" "example" {
  count = 3

  ami           = var.ami_id
  instance_type = "t2.micro"
}

resource "aws_elb" "testelb" {
  name               = "test-elb"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = aws_instance.example.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "example-terraform-elb"
  }
}