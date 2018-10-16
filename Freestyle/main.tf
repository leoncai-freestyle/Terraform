resource "aws_instance" "my-test-instance" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "t2.micro"
  key_name = "${aws_key_pair.pubkey.key_name}"


  # the VPC subnet
  subnet_id = "${aws_subnet.main-public-1.id}"

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-http.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.SERVER_PORT}" &
              EOF

  tags {
    Name = "test-instance"
  }

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
    user = "${var.INSTANCE_USERNAME}"
    private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
  }

}

output "ip" {
    value = "${aws_instance.my-test-instance.public_ip}"
}

#Using https://registry.terraform.io/modules/terraform-aws-modules

module "ec2_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name           = "my-cluster"
  instance_count = 1

  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.pubkey.key_name}"
  monitoring             = true
  associate_public_ip_address = true

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-http.id}"]

  # the VPC subnet
  subnet_id = "${aws_subnet.main-public-1.id}"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              EOF

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = "${module.ec2_cluster.id[0]}"
}

output "instance_public_dns" {
  description = "Public DNS name assigned to the EC2 instance"
  value       = "${module.ec2_cluster.public_dns[0]}"
}

output "instance_public_ip" {
  description = "EC2 instance PublicIP"
  value       = "${module.ec2_cluster.public_ip[0]}"
}
