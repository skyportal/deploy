variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "skyportal" {
  ami = "ami-560c3836"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.stefanv.key_name}"

  vpc_security_group_ids = ["${aws_security_group.skyportal-web.id}",
                            "${aws_security_group.skyportal-ssh.id}"]

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/www_root
              cd /home/www_root
              python3 -m http.server "${var.server_port}" &
              EOF

  tags {
    Name = "skyportal"
  }
}

output "public_ip" {
  value = "${aws_instance.skyportal.public_ip}"
}

resource "aws_key_pair" "stefanv" {
  key_name   = "stefanv-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCz/wX8V/z5DKoBRqHBUJO6um/KJIV6OsGzTSXEJLyPmVOKyxW+sbSvlm9uwXN10Fl/qO6f6UI91sKkAMKA4qIJuPVxr4/lVRm7fA/gDd+3V5+C2J+p414ssJGT1WPNAUv48akiCiq0yQ7H0enRXgy0666ZFE5qhpEDxboSCxqoBPUjAVwRqQARdLyziVOIK754ixl9I1S9uaWsha/BKH0aezG/S0OZw07SNuVKwWcYxsEHrurO9a34bh299/KhySTMmTMzctg8/Bs7Q+yKMchwQT0gYR1fsO6g3RgHxjhxM//NxQYxqWLlOdDc32ag3RNKGtui2+SIvWxauIsQR3Tf stefan@shinobi"
}

resource "aws_security_group" "skyportal-web" {
  name = "skyportal-web"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
}
