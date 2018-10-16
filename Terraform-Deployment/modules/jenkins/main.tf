
resource "aws_instance" "my-test-instance" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_pair}"

  security_groups = ["${var.security_groups}"]

  # the VPC subnet
  subnet_id = "subnet-0d9a829c6559b3a75"

  # the security group
#  vpc_security_group_ids = "sg-020701bc0cf383575"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080  &
              EOF

  provisioner "file" {
    source = "script.sh"
    destination = "/tmp/script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh"
    ]
  }


    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = "${file("${var.key_pair_key}")}"
    }

  tags {
    Name = "${var.name}"
  }
}
