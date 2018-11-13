provider "aws" {
  region = "us-east-1"
}

data "aws_instance" "DNS-Test" {
  instance_tags {
    Name = "DNS-Test"
  }

  state = "running"
}

resource "aws_security_group_rule" "allow_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${data.aws_instance.DNS-Test.security_group}"
}

output "info" {
  value = "${aws_security_group_rule.allow_all.security_group_id}"
}
