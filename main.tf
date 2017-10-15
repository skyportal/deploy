variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = "8080"
}

variable "elb_cname" {
  description = "CNAME for the elastic load balancer"
  default = "alpha.skyportal.io"
}

resource "aws_route53_zone" "skyportal_io" {
  name = "skyportal.io"
}

resource "aws_route53_record" "alpha" {
  zone_id = "${aws_route53_zone.skyportal_io.zone_id}"
  name = "alpha.skyportal.io"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.skyportal-elb.dns_name}"]
}

resource "aws_route53_record" "skyportal-elb-cname" {
  zone_id = "${aws_route53_zone.skyportal_io.zone_id}"
  name = "${var.elb_cname}"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.skyportal-elb.dns_name}"]
}

data "aws_availability_zones" "allzones" {}

provider "aws" {
  region = "us-west-1"
}

resource "aws_elb" "skyportal-elb" {
  name = "skyportal"
  availability_zones = ["${data.aws_availability_zones.allzones.names}"]
  security_groups = ["${aws_security_group.skyportal-elb.id}"]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }

  connection_draining = true
  connection_draining_timeout = 400
  cross_zone_load_balancing = true
}

resource "aws_launch_configuration" "instance" {
  image_id = "ami-560c3836"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.stefanv.key_name}"
  security_groups = ["${aws_security_group.skyportal-ssh.id}",
                     "${aws_security_group.skyportal-instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/www_root
              cd /home/www_root
              python3 -m http.server "${var.server_port}" &
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "skyportal" {
  launch_configuration = "${aws_launch_configuration.instance.id}"
  availability_zones = ["${data.aws_availability_zones.allzones.names}"]
  load_balancers    = ["${aws_elb.skyportal-elb.name}"]
  health_check_type = "ELB"
  health_check_grace_period = 300

  min_size = 1
  max_size = 2

  tag {
    key                 = "Name"
    value               = "skyportal-asg"
    propagate_at_launch = true
  }
}

resource "aws_key_pair" "stefanv" {
  key_name   = "stefanv-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCz/wX8V/z5DKoBRqHBUJO6um/KJIV6OsGzTSXEJLyPmVOKyxW+sbSvlm9uwXN10Fl/qO6f6UI91sKkAMKA4qIJuPVxr4/lVRm7fA/gDd+3V5+C2J+p414ssJGT1WPNAUv48akiCiq0yQ7H0enRXgy0666ZFE5qhpEDxboSCxqoBPUjAVwRqQARdLyziVOIK754ixl9I1S9uaWsha/BKH0aezG/S0OZw07SNuVKwWcYxsEHrurO9a34bh299/KhySTMmTMzctg8/Bs7Q+yKMchwQT0gYR1fsO6g3RgHxjhxM//NxQYxqWLlOdDc32ag3RNKGtui2+SIvWxauIsQR3Tf stefan@shinobi"
}

resource "aws_security_group" "skyportal-instance" {
  name = "instance"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # So that we can run Debian updates
  egress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "skyportal-elb" {
  name = "elb"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Needed to make health check connections
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "skyportal-ssh" {
  name = "skyportal-ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "elb_dns_name" {
  value = "${aws_elb.skyportal-elb.dns_name}"
}

output "route53_name_servers" {
  value = [
    "${aws_route53_zone.skyportal_io.name_servers.0}",
    "${aws_route53_zone.skyportal_io.name_servers.1}",
    "${aws_route53_zone.skyportal_io.name_servers.2}",
    "${aws_route53_zone.skyportal_io.name_servers.3}"
  ]
}
